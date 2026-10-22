import Foundation

struct OfflineGuidancePackage: Codable, Equatable, Sendable {
    let schemaVersion: Int
    let contentVersion: String
    let countryCode: String
    let reviewedAt: Date
    let templates: [EmergencyPlanTemplate]
}

enum OfflineGuidanceValidationError: Error, Equatable {
    case unsupportedSchema
    case unsupportedCountry
    case incompleteTemplates
    case invalidTemplate
    case unresolvedSource
}

enum OfflineGuidanceCatalog {
    static let supportedSchemaVersion = 1
    static let contentVersion = "2026.10.22.1"

    static let bundled = OfflineGuidancePackage(
        schemaVersion: supportedSchemaVersion,
        contentVersion: contentVersion,
        countryCode: "NO",
        reviewedAt: reviewedAt,
        templates: NorwayEmergencyTemplates.all
    )

    static func validate(_ package: OfflineGuidancePackage) throws {
        guard package.schemaVersion == supportedSchemaVersion else {
            throw OfflineGuidanceValidationError.unsupportedSchema
        }
        guard package.countryCode == "NO" else {
            throw OfflineGuidanceValidationError.unsupportedCountry
        }

        let expectedTypes = Set(EmergencyType.allCases)
        let providedTypes = Set(package.templates.map(\.type))
        guard providedTypes == expectedTypes, package.templates.count == expectedTypes.count else {
            throw OfflineGuidanceValidationError.incompleteTemplates
        }

        for template in package.templates {
            guard template.id == "no.\(template.type.rawValue)",
                  !template.actions.isEmpty,
                  !template.shelterGuidance.isEmpty,
                  !template.sourceIDs.isEmpty else {
                throw OfflineGuidanceValidationError.invalidTemplate
            }
            guard template.sourceIDs.allSatisfy({ GuidanceSourceRegistry.source(for: $0) != nil }) else {
                throw OfflineGuidanceValidationError.unresolvedSource
            }
        }
    }

    private static let reviewedAt: Date = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar.date(from: DateComponents(year: 2026, month: 10, day: 22)) ?? .distantPast
    }()
}

actor OfflineGuidanceStore {
    private let fileURL: URL

    init(fileURL: URL? = nil) {
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? FileManager.default.temporaryDirectory
            self.fileURL = directory.appendingPathComponent("offline-guidance-v1.json")
        }
    }

    func loadLastValidPackage() -> OfflineGuidancePackage {
        guard let data = try? Data(contentsOf: fileURL),
              let package = try? Self.decoder.decode(OfflineGuidancePackage.self, from: data),
              (try? OfflineGuidanceCatalog.validate(package)) != nil else {
            return OfflineGuidanceCatalog.bundled
        }
        return package
    }

    /// Validates completely before replacing the last valid package. Callers can
    /// safely keep using `loadLastValidPackage()` after any decoding or validation error.
    func installCandidate(_ data: Data) throws {
        let candidate = try Self.decoder.decode(OfflineGuidancePackage.self, from: data)
        try OfflineGuidanceCatalog.validate(candidate)
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try data.write(to: fileURL, options: .atomic)
    }

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
