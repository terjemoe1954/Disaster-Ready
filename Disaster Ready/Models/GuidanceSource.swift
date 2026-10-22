import Foundation

struct GuidanceSource: Codable, Identifiable, Equatable, Sendable {
    let id: String
    let authority: String
    let title: String
    let url: URL
    let countryCode: String
    let lastReviewed: Date
    let contentVersion: String?

    init(
        id: String,
        authority: String,
        title: String,
        url: URL,
        countryCode: String,
        lastReviewed: Date,
        contentVersion: String? = nil
    ) {
        self.id = id
        self.authority = authority
        self.title = title
        self.url = url
        self.countryCode = countryCode
        self.lastReviewed = lastReviewed
        self.contentVersion = contentVersion
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        authority = try container.decode(String.self, forKey: .authority)
        title = try container.decode(String.self, forKey: .title)
        url = try container.decode(URL.self, forKey: .url)
        countryCode = try container.decode(String.self, forKey: .countryCode)
        lastReviewed = try container.decode(Date.self, forKey: .lastReviewed)
        contentVersion = try container.decodeIfPresent(String.self, forKey: .contentVersion)
    }
}
