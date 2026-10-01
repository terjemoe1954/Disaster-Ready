import Foundation

enum WeatherAlertServiceError: Error, Equatable { case invalidCoordinate; case invalidRequest; case invalidResponse; case throttled; case noUsableData }

nonisolated protocol WeatherAlertHTTPClient: Sendable {
    func weatherAlertData(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: WeatherAlertHTTPClient {
    func weatherAlertData(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request)
    }
}

actor WeatherAlertCache {
    struct Entry: Codable, Sendable {
        let alerts: [OfficialAlert]
        let fetchedAt: Date
        let languageCode: String
        let lastModified: String?
        let expiresAt: Date?
        let cacheControl: String?
        let checkedAt: Date?
        let diagnostics: [WeatherAlertDiagnostic]?

        init(
            alerts: [OfficialAlert],
            fetchedAt: Date,
            languageCode: String,
            lastModified: String?,
            expiresAt: Date? = nil,
            cacheControl: String? = nil,
            checkedAt: Date? = nil,
            diagnostics: [WeatherAlertDiagnostic]? = nil
        ) {
            self.alerts = alerts
            self.fetchedAt = fetchedAt
            self.languageCode = languageCode
            self.lastModified = lastModified
            self.expiresAt = expiresAt
            self.cacheControl = cacheControl
            self.checkedAt = checkedAt
            self.diagnostics = diagnostics
        }
    }
    private let fileURL: URL
    init(fileURL: URL? = nil) {
        if let fileURL { self.fileURL = fileURL }
        else {
            let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory
            self.fileURL = base.appendingPathComponent("met-alerts-cache-v2.json")
        }
    }
    func load(languageCode: String) -> Entry? {
        guard let data = try? Data(contentsOf: fileURL), let entry = try? JSONDecoder().decode(Entry.self, from: data), entry.languageCode == languageCode else { return nil }
        return entry
    }
    func save(_ entry: Entry) throws { try JSONEncoder().encode(entry).write(to: fileURL, options: .atomic) }
}

struct METWeatherAlertService: WeatherAlertService {
    private let client: any WeatherAlertHTTPClient
    private let cache: WeatherAlertCache
    private let now: @Sendable () -> Date
    init(session: URLSession = .shared, cache: WeatherAlertCache = WeatherAlertCache(), now: @escaping @Sendable () -> Date = { .now }) {
        self.client = session; self.cache = cache; self.now = now
    }
    init(client: any WeatherAlertHTTPClient, cache: WeatherAlertCache, now: @escaping @Sendable () -> Date = { .now }) {
        self.client = client; self.cache = cache; self.now = now
    }
    func activeAlerts(latitude: Double, longitude: Double) async throws -> [OfficialAlert] {
        try await alertSnapshot(latitude: latitude, longitude: longitude, languageCode: "no").alerts
    }
    func alertSnapshot(latitude: Double, longitude: Double, languageCode: String) async throws -> WeatherAlertSnapshot {
        guard latitude.isFinite, longitude.isFinite, (-90...90).contains(latitude), (-180...180).contains(longitude) else { throw WeatherAlertServiceError.invalidCoordinate }
        let language = languageCode == "no" ? "no" : "en", requestedAt = now()
        let cached = await cache.load(languageCode: language)
        if let cached, let expiresAt = cached.expiresAt, requestedAt < expiresAt {
            return snapshot(from: cached, latitude: latitude, longitude: longitude, at: requestedAt, isCached: true)
        }
        do {
            let request = try makeRequest(languageCode: language, lastModified: cached?.lastModified)
            let (data, response) = try await client.weatherAlertData(for: request)
            guard let response = response as? HTTPURLResponse else { throw WeatherAlertServiceError.invalidResponse }
            if response.statusCode == 429 { throw WeatherAlertServiceError.throttled }

            let alerts: [OfficialAlert]
            let fetchedAt: Date
            var diagnostics = Set(cached?.diagnostics ?? [])
            if response.statusCode == 304, let cached {
                alerts = cached.alerts
                fetchedAt = cached.fetchedAt
            } else {
                guard response.statusCode == 200 || response.statusCode == 203 else { throw WeatherAlertServiceError.invalidResponse }
                alerts = try METAlertsDecoder.decode(data)
                fetchedAt = requestedAt
            }
            if response.statusCode == 203 {
                diagnostics.insert(.deprecatedProduct)
                print("MET Weather API diagnostic: HTTP 203 indicates product deprecation")
            }
            let entry = WeatherAlertCache.Entry(
                alerts: alerts,
                fetchedAt: fetchedAt,
                languageCode: language,
                lastModified: response.value(forHTTPHeaderField: "Last-Modified") ?? cached?.lastModified,
                expiresAt: cacheExpiry(from: response, receivedAt: requestedAt) ?? cached?.expiresAt,
                cacheControl: response.value(forHTTPHeaderField: "Cache-Control") ?? cached?.cacheControl,
                checkedAt: requestedAt,
                diagnostics: Array(diagnostics)
            )
            try? await cache.save(entry)
            return snapshot(from: entry, latitude: latitude, longitude: longitude, at: requestedAt, isCached: false)
        } catch {
            guard let cached else { throw error }
            var fallback = cached
            if let responseError = error as? WeatherAlertServiceError, responseError == .throttled {
                fallback = WeatherAlertCache.Entry(
                    alerts: cached.alerts, fetchedAt: cached.fetchedAt, languageCode: cached.languageCode,
                    lastModified: cached.lastModified, expiresAt: cached.expiresAt, cacheControl: cached.cacheControl,
                    checkedAt: cached.checkedAt, diagnostics: Array(Set(cached.diagnostics ?? []).union([.throttled]))
                )
            }
            return snapshot(from: fallback, latitude: latitude, longitude: longitude, at: requestedAt, isCached: true)
        }
    }
    func makeRequest(languageCode: String, lastModified: String? = nil) throws -> URLRequest {
        var components = URLComponents(string: "https://api.met.no/weatherapi/metalerts/2.0/current.json")
        components?.queryItems = [URLQueryItem(name: "lang", value: languageCode == "no" ? "no" : "en"), URLQueryItem(name: "geographicDomain", value: "land")]
        guard let url = components?.url else { throw WeatherAlertServiceError.invalidRequest }
        var request = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 20)
        request.setValue("DisasterReady/1.1 (+https://github.com/terjemoe1954/Disaster-Ready)", forHTTPHeaderField: "User-Agent")
        request.setValue("application/geo+json", forHTTPHeaderField: "Accept")
        if let lastModified { request.setValue(lastModified, forHTTPHeaderField: "If-Modified-Since") }
        return request
    }
    private func snapshot(from entry: WeatherAlertCache.Entry, latitude: Double, longitude: Double, at date: Date, isCached: Bool) -> WeatherAlertSnapshot {
        let relevant = entry.alerts.filter { $0.geometry?.contains(latitude: latitude, longitude: longitude) ?? false }
        return WeatherAlertSnapshot(
            alerts: METAlertsDecoder.activeAlerts(from: relevant, at: date),
            fetchedAt: entry.checkedAt ?? entry.fetchedAt,
            isCached: isCached,
            diagnostics: Set(entry.diagnostics ?? [])
        )
    }

    nonisolated func cacheExpiry(from response: HTTPURLResponse, receivedAt: Date) -> Date? {
        if let cacheControl = response.value(forHTTPHeaderField: "Cache-Control"),
           let maxAge = cacheControl.split(separator: ",").lazy
            .map({ $0.trimmingCharacters(in: .whitespaces) })
            .first(where: { $0.lowercased().hasPrefix("max-age=") })?
            .split(separator: "=").last.flatMap({ TimeInterval($0) }) {
            return receivedAt.addingTimeInterval(max(0, maxAge))
        }
        guard let expires = response.value(forHTTPHeaderField: "Expires") else { return nil }
        return Self.httpDateFormatter.date(from: expires)
    }

    nonisolated private static let httpDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss 'GMT'"
        return formatter
    }()
}

nonisolated enum METAlertsDecoder {
    private struct Collection: Decodable { let features: [Feature] }
    private struct Feature: Decodable { let geometry: Geometry?; let properties: Properties; let when: Validity? }
    private struct Properties: Decodable {
        let id: String; let title: String?; let event: String; let area: String?; let description: String?; let instruction: String?; let consequences: String?
        let riskMatrixColor: String?; let severity: String?; let status: String; let type: String; let web: URL?
    }
    private struct Validity: Decodable { let interval: [String] }
    private struct Geometry: Decodable {
        let type: String; let coordinates: Coordinates
        enum Coordinates: Decodable {
            case polygon([[[Double]]]); case multiPolygon([[[[Double]]]])
            init(from decoder: Decoder) throws {
                let c = try decoder.singleValueContainer()
                if let value = try? c.decode([[[[Double]]]].self) { self = .multiPolygon(value) }
                else { self = .polygon(try c.decode([[[Double]]].self)) }
            }
        }
    }
    nonisolated static func decode(_ data: Data) throws -> [OfficialAlert] {
        try JSONDecoder().decode(Collection.self, from: data).features.compactMap { feature in
            guard let messageType = OfficialAlertMessageType(rawValue: feature.properties.type) else { return nil }
            let interval = feature.when?.interval ?? []
            return OfficialAlert(id: feature.properties.id, source: "Norwegian Meteorological Institute (MET Norway)", event: feature.properties.event,
                severity: OfficialAlertSeverity(rawValue: feature.properties.riskMatrixColor ?? "") ?? .unknown, officialCAPSeverity: feature.properties.severity,
                headline: feature.properties.title, alertDescription: feature.properties.description, instruction: feature.properties.instruction,
                consequences: feature.properties.consequences, effectiveAt: nil, onsetAt: interval.first.flatMap(date),
                expiresAt: interval.count > 1 ? date(interval[1]) : nil, sentAt: nil, updatedAt: nil, geographicDescription: feature.properties.area,
                sourceID: "met-norway-metalerts-2", messageType: messageType, status: feature.properties.status, referencedAlertIDs: [],
                geometry: feature.geometry.flatMap(normalize), webURL: feature.properties.web)
        }
    }
    nonisolated static func activeAlerts(from alerts: [OfficialAlert], at date: Date) -> [OfficialAlert] {
        let lifecycleMessages = alerts.filter { $0.messageType == .update || $0.messageType == .cancel }
        let cancelled = Set(alerts.filter { $0.messageType == .cancel }.flatMap { [$0.id] + $0.referencedAlertIDs })
        let superseded = Set(lifecycleMessages.flatMap(\.referencedAlertIDs))
        var activeByID: [String: OfficialAlert] = [:]
        for alert in alerts where alert.isActive(at: date) && !cancelled.contains(alert.id) && !superseded.contains(alert.id) {
            activeByID[alert.id] = alert
        }
        return activeByID.values.sorted { severityRank($0.severity) > severityRank($1.severity) }
    }
    nonisolated private static func normalize(_ geometry: Geometry) -> OfficialAlertGeometry? {
        func point(_ values: [Double]) -> AlertCoordinate? { values.count >= 2 ? AlertCoordinate(longitude: values[0], latitude: values[1]) : nil }
        switch geometry.coordinates {
        case .polygon(let rings): return .polygon(rings.map { $0.compactMap(point) })
        case .multiPolygon(let polygons): return .multiPolygon(polygons.map { $0.map { $0.compactMap(point) } })
        }
    }
    nonisolated private static func date(_ value: String) -> Date? { ISO8601DateFormatter().date(from: value) }
    nonisolated private static func severityRank(_ value: OfficialAlertSeverity) -> Int { switch value { case .red: 4; case .orange: 3; case .yellow: 2; case .green: 1; case .unknown: 0 } }
}
