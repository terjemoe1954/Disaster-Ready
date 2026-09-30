import Foundation

struct GuidanceSource: Codable, Identifiable, Equatable, Sendable {
    let id: String
    let authority: String
    let title: String
    let url: URL
    let countryCode: String
    let lastReviewed: Date
}
