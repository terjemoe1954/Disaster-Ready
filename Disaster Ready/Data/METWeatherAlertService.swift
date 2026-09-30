import Foundation

enum WeatherAlertServiceError: Error {
    case invalidCoordinate
    case invalidRequest
    case invalidResponse
    case noUsableData
}

actor WeatherAlertCache {
    struct Entry: Codable, Sendable {
        let alerts: [OfficialAlert]
        let updatedAt: Date
        let latitude: Double
        let longitude: Double
    }

    private let fileURL: URL

    init(fileURL: URL? = nil) {
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
                ?? FileManager.default.temporaryDirectory
            self.fileURL = base.appendingPathComponent("met-alerts-cache.json")
        }
    }

    func load(latitude: Double, longitude: Double) -> Entry? {
        guard let data = try? Data(contentsOf: fileURL),
              let entry = try? JSONDecoder().decode(Entry.self, from: data),
              abs(entry.latitude - latitude) < 0.01,
              abs(entry.longitude - longitude) < 0.01 else { return nil }
        return entry
    }

    func save(_ entry: Entry) throws {
        let data = try JSONEncoder().encode(entry)
        try data.write(to: fileURL, options: .atomic)
    }
}

struct METWeatherAlertService: WeatherAlertService {
    private let session: URLSession
    private let cache: WeatherAlertCache
    private let now: @Sendable () -> Date

    init(
        session: URLSession = .shared,
        cache: WeatherAlertCache = WeatherAlertCache(),
        now: @escaping @Sendable () -> Date = { .now }
    ) {
        self.session = session
        self.cache = cache
        self.now = now
    }

    func activeAlerts(latitude: Double, longitude: Double) async throws -> [OfficialAlert] {
        try await alertSnapshot(latitude: latitude, longitude: longitude, languageCode: "no").alerts
    }

    func alertSnapshot(latitude: Double, longitude: Double, languageCode: String) async throws -> WeatherAlertSnapshot {
        guard (-90...90).contains(latitude), (-180...180).contains(longitude) else {
            throw WeatherAlertServiceError.invalidCoordinate
        }
        let requestedAt = now()
        let roundedLatitude = roundedCoordinate(latitude)
        let roundedLongitude = roundedCoordinate(longitude)

        do {
            let request = try makeRequest(latitude: roundedLatitude, longitude: roundedLongitude, languageCode: languageCode)
            let (data, response) = try await session.data(for: request)
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                throw WeatherAlertServiceError.invalidResponse
            }
            let decoded = try METAlertsDecoder.decode(data)
            let entry = WeatherAlertCache.Entry(
                alerts: decoded,
                updatedAt: requestedAt,
                latitude: roundedLatitude,
                longitude: roundedLongitude
            )
            try? await cache.save(entry)
            return WeatherAlertSnapshot(
                alerts: METAlertsDecoder.activeAlerts(from: decoded, at: requestedAt),
                lastUpdated: requestedAt,
                isCached: false
            )
        } catch {
            guard let cached = await cache.load(latitude: roundedLatitude, longitude: roundedLongitude) else {
                throw error
            }
            return WeatherAlertSnapshot(
                alerts: METAlertsDecoder.activeAlerts(from: cached.alerts, at: requestedAt),
                lastUpdated: cached.updatedAt,
                isCached: true
            )
        }
    }

    func makeRequest(latitude: Double, longitude: Double, languageCode: String) throws -> URLRequest {
        var components = URLComponents(string: "https://api.met.no/weatherapi/metalerts/2.0/current.json")
        components?.queryItems = [
            URLQueryItem(name: "lat", value: String(format: "%.4f", roundedCoordinate(latitude))),
            URLQueryItem(name: "lon", value: String(format: "%.4f", roundedCoordinate(longitude))),
            URLQueryItem(name: "lang", value: languageCode == "no" ? "no" : "en"),
            URLQueryItem(name: "geographicDomain", value: "land")
        ]
        guard let url = components?.url else { throw WeatherAlertServiceError.invalidRequest }
        var request = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 20)
        request.setValue("DisasterReady/1.1 https://github.com/terjemoe1954/Disaster-Ready", forHTTPHeaderField: "User-Agent")
        request.setValue("application/geo+json", forHTTPHeaderField: "Accept")
        return request
    }

    private func roundedCoordinate(_ value: Double) -> Double {
        (value * 10_000).rounded() / 10_000
    }
}

enum METAlertsDecoder {
    private struct Collection: Decodable { let features: [Feature] }
    private struct Feature: Decodable {
        let properties: Properties
        let when: Validity
    }
    private struct Properties: Decodable {
        let id: String
        let title: String
        let event: String
        let area: String
        let description: String
        let instruction: String?
        let consequences: String?
        let riskMatrixColor: String?
        let severity: String?
        let status: String
        let type: String
        let web: URL?
    }
    private struct Validity: Decodable { let interval: [String] }

    static func decode(_ data: Data) throws -> [OfficialAlert] {
        let collection = try JSONDecoder().decode(Collection.self, from: data)
        return collection.features.compactMap { feature in
            guard feature.when.interval.count >= 2,
                  let startsAt = date(feature.when.interval[0]),
                  let expiresAt = date(feature.when.interval[1]),
                  let messageType = OfficialAlertMessageType(rawValue: feature.properties.type) else { return nil }
            let severity = OfficialAlertSeverity(rawValue: feature.properties.riskMatrixColor ?? "") ?? .unknown
            return OfficialAlert(
                id: feature.properties.id,
                title: feature.properties.title,
                event: feature.properties.event,
                area: feature.properties.area,
                alertDescription: feature.properties.description,
                instruction: feature.properties.instruction ?? "",
                consequences: feature.properties.consequences ?? "",
                severity: severity,
                messageType: messageType,
                status: feature.properties.status,
                startsAt: startsAt,
                expiresAt: expiresAt,
                webURL: feature.properties.web,
                sourceID: "met-norway-metalerts-2"
            )
        }
    }

    static func activeAlerts(from alerts: [OfficialAlert], at date: Date) -> [OfficialAlert] {
        let cancelledIDs = Set(alerts.filter { $0.messageType == .cancel }.map(\.id))
        return alerts
            .filter { $0.isActive(at: date) && !cancelledIDs.contains($0.id) }
            .sorted { severityRank($0.severity) > severityRank($1.severity) }
    }

    private static func severityRank(_ severity: OfficialAlertSeverity) -> Int {
        switch severity { case .red: 3; case .orange: 2; case .yellow: 1; case .unknown: 0 }
    }

    private static func date(_ value: String) -> Date? {
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return fractional.date(from: value) ?? ISO8601DateFormatter().date(from: value)
    }
}
