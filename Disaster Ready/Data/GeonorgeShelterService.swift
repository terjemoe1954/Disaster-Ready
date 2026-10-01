import Foundation

enum ShelterServiceError: Error {
    case invalidCoordinate
    case invalidRequest
    case invalidResponse
    case decodingFailed
}

actor ShelterCache {
    struct Entry: Codable, Sendable {
        let shelters: [CivilDefenceShelter]
        let updatedAt: Date
        let schemaVersion: Int = 2
    }

    private let fileURL: URL

    init(fileURL: URL? = nil) {
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
                ?? FileManager.default.temporaryDirectory
            self.fileURL = directory.appendingPathComponent("public-shelters-cache.json")
        }
    }

    func load() -> Entry? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        guard let entry = try? JSONDecoder().decode(Entry.self, from: data),
              entry.schemaVersion == 2 else {
            // Development builds before Milestone 8 cached a coordinate-bound subset
            // together with the lookup location. It is not valid as a national cache.
            try? FileManager.default.removeItem(at: fileURL)
            return nil
        }
        return entry
    }

    func save(_ entry: Entry) throws {
        let data = try JSONEncoder().encode(entry)
        try data.write(to: fileURL, options: .atomic)
    }
}

struct GeonorgeShelterService: ShelterService {
    static let sourceID = "dsb-geonorge-public-shelters-wfs"

    private let session: URLSession
    private let cache: ShelterCache
    private let now: @Sendable () -> Date
    private let radiusKilometers = 25.0

    init(
        session: URLSession = .shared,
        cache: ShelterCache = ShelterCache(),
        now: @escaping @Sendable () -> Date = { .now }
    ) {
        self.session = session
        self.cache = cache
        self.now = now
    }

    func nearbyShelters(latitude: Double, longitude: Double) async throws -> [CivilDefenceShelter] {
        try await shelterSnapshot(latitude: latitude, longitude: longitude).shelters
    }

    func shelterSnapshot(latitude: Double, longitude: Double) async throws -> ShelterSnapshot {
        let origin = ShelterCoordinate(latitude: latitude, longitude: longitude)
        guard origin.isValid else { throw ShelterServiceError.invalidCoordinate }
        let reference = try await referenceSnapshot()
        let nearby = try ShelterProximity.sorted(shelters: reference.shelters, from: origin)
            .filter { $0.kilometers <= radiusKilometers }
            .map(\.shelter)
        return ShelterSnapshot(
            shelters: nearby,
            lastUpdated: reference.lastUpdated,
            isCached: reference.isCached,
            datasetUpdatedAt: reference.datasetUpdatedAt,
            origin: origin
        )
    }

    /// Searches only official fields downloaded from the DSB/Geonorge register.
    /// It does not use a third-party point-of-interest database.
    func searchSnapshot(matching query: String) async throws -> ShelterSnapshot {
        let reference = try await referenceSnapshot()
        let matches = try ShelterRegisterSearch.results(matching: query, in: reference.shelters)

        return ShelterSnapshot(
            shelters: matches,
            lastUpdated: reference.lastUpdated,
            isCached: reference.isCached,
            datasetUpdatedAt: reference.datasetUpdatedAt
        )
    }

    func makeRequest() throws -> URLRequest {
        var components = URLComponents(string: "https://wfs.geonorge.no/skwms1/wfs.tilfluktsrom_offentlige")
        components?.queryItems = [
            URLQueryItem(name: "service", value: "WFS"),
            URLQueryItem(name: "version", value: "2.0.0"),
            URLQueryItem(name: "request", value: "GetFeature"),
            URLQueryItem(name: "typeNames", value: "app:Tilfluktsrom"),
            URLQueryItem(name: "namespaces", value: "xmlns(app,http://skjema.geonorge.no/SOSI/produktspesifikasjon/TilfluktsromOffentlige/20191001)"),
            URLQueryItem(name: "srsName", value: "urn:ogc:def:crs:EPSG::4258"),
            URLQueryItem(name: "count", value: "1000")
        ]
        guard let url = components?.url else { throw ShelterServiceError.invalidRequest }

        var request = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 30)
        request.setValue("DisasterReady/1.1", forHTTPHeaderField: "User-Agent")
        return request
    }

    private func referenceSnapshot() async throws -> ShelterSnapshot {
        do {
            let (data, response) = try await session.data(for: makeRequest())
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw ShelterServiceError.invalidResponse
            }
            let shelters = try ShelterGMLDecoder.decode(data)
            let refreshedAt = now()
            try? await cache.save(.init(shelters: shelters, updatedAt: refreshedAt))
            return ShelterSnapshot(
                shelters: shelters,
                lastUpdated: refreshedAt,
                isCached: false,
                datasetUpdatedAt: shelters.compactMap(\.dataUpdatedAt).max()
            )
        } catch {
            guard let entry = await cache.load() else { throw error }
            return ShelterSnapshot(
                shelters: entry.shelters,
                lastUpdated: entry.updatedAt,
                isCached: true,
                datasetUpdatedAt: entry.shelters.compactMap(\.dataUpdatedAt).max()
            )
        }
    }
}

enum ShelterGMLDecoder {
    static func decode(_ data: Data) throws -> [CivilDefenceShelter] {
        let delegate = ShelterGMLParserDelegate()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        parser.shouldProcessNamespaces = true
        guard parser.parse() else { throw parser.parserError ?? ShelterServiceError.decodingFailed }
        var seenIDs = Set<String>()
        return delegate.shelters.filter { seenIDs.insert($0.id).inserted }
    }
}

private final class ShelterGMLParserDelegate: NSObject, XMLParserDelegate {
    private struct Builder {
        var id = ""
        var roomNumber: String?
        var address: String?
        var capacity: Int?
        var latitude: Double?
        var longitude: Double?
        var updatedAt: Date?
    }

    private var builder: Builder?
    private var text = ""
    fileprivate private(set) var shelters: [CivilDefenceShelter] = []

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        text = ""
        if elementName == "Tilfluktsrom" { builder = Builder() }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        text += string
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        switch elementName {
        case "lokalId": builder?.id = value
        case "romnr": builder?.roomNumber = value.isEmpty ? nil : value
        case "adresse": builder?.address = value.isEmpty ? nil : value
        case "plasser": builder?.capacity = Int(value)
        case "datauttaksdato": builder?.updatedAt = Self.date(from: value)
        case "pos":
            let coordinates = value.split(separator: " ").compactMap { Double($0) }
            if coordinates.count == 2 {
                builder?.latitude = coordinates[0]
                builder?.longitude = coordinates[1]
            }
        case "Tilfluktsrom":
            if let builder,
               !builder.id.isEmpty,
               let latitude = builder.latitude,
               let longitude = builder.longitude,
               ShelterCoordinate(latitude: latitude, longitude: longitude).isValid {
                shelters.append(CivilDefenceShelter(
                    id: builder.id,
                    roomNumber: builder.roomNumber,
                    address: builder.address,
                    capacity: builder.capacity,
                    latitude: latitude,
                    longitude: longitude,
                    sourceID: GeonorgeShelterService.sourceID,
                    dataUpdatedAt: builder.updatedAt
                ))
            }
            builder = nil
        default: break
        }
        text = ""
    }

    private static func date(from value: String) -> Date? {
        fractionalDateFormatter.date(from: value) ?? dateFormatter.date(from: value)
    }

    private static let fractionalDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let dateFormatter = ISO8601DateFormatter()
}
