import Foundation

enum ShelterServiceError: Error {
    case invalidCoordinate
    case invalidRequest
    case invalidResponse
    case decodingFailed
}

struct GeonorgeShelterService: ShelterService {
    private let session: URLSession
    private let radiusKilometers = 25.0

    init(session: URLSession = .shared) {
        self.session = session
    }

    func nearbyShelters(latitude: Double, longitude: Double) async throws -> [Shelter] {
        guard (-90...90).contains(latitude), (-180...180).contains(longitude) else {
            throw ShelterServiceError.invalidCoordinate
        }

        let request = try makeRequest(latitude: latitude, longitude: longitude)
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ShelterServiceError.invalidResponse
        }

        return try ShelterGMLDecoder.decode(data)
            .map { shelter in
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
