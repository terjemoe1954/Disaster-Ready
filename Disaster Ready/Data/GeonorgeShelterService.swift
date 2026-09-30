import Foundation

enum ShelterServiceError: Error {
    case invalidCoordinate
    case invalidRequest
    case invalidResponse
    case decodingFailed
}

actor ShelterCache {
    struct Entry: Codable, Sendable {
        let shelters: [Shelter]
        let updatedAt: Date
        let latitude: Double
        let longitude: Double
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

struct GeonorgeShelterService: ShelterService {
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

    func nearbyShelters(latitude: Double, longitude: Double) async throws -> [Shelter] {
        try await shelterSnapshot(latitude: latitude, longitude: longitude).shelters
    }

    func shelterSnapshot(latitude: Double, longitude: Double) async throws -> ShelterSnapshot {
        guard (-90...90).contains(latitude), (-180...180).contains(longitude) else {
            throw ShelterServiceError.invalidCoordinate
        }
        let roundedLatitude = roundedCoordinate(latitude)
        let roundedLongitude = roundedCoordinate(longitude)

        do {
            let request = try makeRequest(latitude: roundedLatitude, longitude: roundedLongitude)
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw ShelterServiceError.invalidResponse
            }
            let shelters = nearbyShelters(
                from: try ShelterGMLDecoder.decode(data),
                latitude: roundedLatitude,
                longitude: roundedLongitude
            )
            let updatedAt = now()
            try? await cache.save(.init(
                shelters: shelters,
                updatedAt: updatedAt,
                latitude: roundedLatitude,
                longitude: roundedLongitude
            ))
            return ShelterSnapshot(shelters: shelters, lastUpdated: updatedAt, isCached: false)
        } catch {
            guard let entry = await cache.load(latitude: roundedLatitude, longitude: roundedLongitude) else {
                throw error
            }
            return ShelterSnapshot(shelters: entry.shelters, lastUpdated: entry.updatedAt, isCached: true)
        }
    }

    private func nearbyShelters(from shelters: [Shelter], latitude: Double, longitude: Double) -> [Shelter] {
        shelters.map { shelter in
            (shelter, distanceKilometers(
                fromLatitude: latitude,
                longitude: longitude,
                toLatitude: shelter.latitude,
                longitude: shelter.longitude
            ))
        }
        .filter { $0.1 <= radiusKilometers }
        .sorted { $0.1 < $1.1 }
        .map(\.0)
    }

    private func makeRequest(latitude: Double, longitude: Double) throws -> URLRequest {
        let latitudeDelta = radiusKilometers / 111.0
        let longitudeScale = max(cos(latitude * .pi / 180), 0.2)
        let longitudeDelta = radiusKilometers / (111.0 * longitudeScale)
        let bbox = "\(latitude - latitudeDelta),\(longitude - longitudeDelta),\(latitude + latitudeDelta),\(longitude + longitudeDelta),urn:ogc:def:crs:EPSG::4258"

        var components = URLComponents(string: "https://wfs.geonorge.no/skwms1/wfs.tilfluktsrom_offentlige")
        components?.queryItems = [
            URLQueryItem(name: "service", value: "WFS"),
            URLQueryItem(name: "version", value: "2.0.0"),
            URLQueryItem(name: "request", value: "GetFeature"),
            URLQueryItem(name: "typeNames", value: "app:Tilfluktsrom"),
            URLQueryItem(name: "namespaces", value: "xmlns(app,http://skjema.geonorge.no/SOSI/produktspesifikasjon/TilfluktsromOffentlige/20191001)"),
            URLQueryItem(name: "srsName", value: "urn:ogc:def:crs:EPSG::4258"),
            URLQueryItem(name: "bbox", value: bbox),
            URLQueryItem(name: "count", value: "500")
        ]
        guard let url = components?.url else { throw ShelterServiceError.invalidRequest }

        var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 20)
        request.setValue("DisasterReady/1.1", forHTTPHeaderField: "User-Agent")
        return request
    }

    private func roundedCoordinate(_ value: Double) -> Double {
        (value * 10_000).rounded() / 10_000
    }

    private func distanceKilometers(
        fromLatitude: Double,
        longitude fromLongitude: Double,
        toLatitude: Double,
        longitude toLongitude: Double
    ) -> Double {
        let earthRadius = 6_371.0
        let latitudeDelta = (toLatitude - fromLatitude) * .pi / 180
        let longitudeDelta = (toLongitude - fromLongitude) * .pi / 180
        let originLatitude = fromLatitude * .pi / 180
        let destinationLatitude = toLatitude * .pi / 180
        let a = sin(latitudeDelta / 2) * sin(latitudeDelta / 2)
            + cos(originLatitude) * cos(destinationLatitude)
            * sin(longitudeDelta / 2) * sin(longitudeDelta / 2)
        return earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a))
    }
}

enum ShelterGMLDecoder {
    static func decode(_ data: Data) throws -> [Shelter] {
        let delegate = ShelterGMLParserDelegate()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        parser.shouldProcessNamespaces = true
        guard parser.parse() else { throw parser.parserError ?? ShelterServiceError.decodingFailed }
        return delegate.shelters
    }
}

private final class ShelterGMLParserDelegate: NSObject, XMLParserDelegate {
    private struct Builder {
        var id = ""
        var roomNumber = ""
        var address = ""
        var capacity: Int?
        var latitude: Double?
        var longitude: Double?
        var updatedAt: Date?
    }

    private var builder: Builder?
    private var text = ""
    fileprivate private(set) var shelters: [Shelter] = []

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
        case "romnr": builder?.roomNumber = value
        case "adresse": builder?.address = value
        case "plasser": builder?.capacity = Int(value)
        case "datauttaksdato": builder?.updatedAt = Self.dateFormatter.date(from: value)
        case "pos":
            let coordinates = value.split(separator: " ").compactMap { Double($0) }
            if coordinates.count == 2 {
                builder?.latitude = coordinates[0]
                builder?.longitude = coordinates[1]
            }
        case "Tilfluktsrom":
            if let builder, let latitude = builder.latitude, let longitude = builder.longitude {
                shelters.append(Shelter(
                    id: builder.id.isEmpty ? "room-\(builder.roomNumber)" : builder.id,
                    roomNumber: builder.roomNumber,
                    address: builder.address,
                    capacity: builder.capacity,
                    latitude: latitude,
                    longitude: longitude,
                    sourceID: "dsb-geonorge-public-shelters-wfs",
                    dataUpdatedAt: builder.updatedAt
                ))
            }
            builder = nil
        default: break
        }
        text = ""
    }

    private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
