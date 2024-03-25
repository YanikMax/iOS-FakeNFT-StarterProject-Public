import Foundation

struct Profile: Decodable, Encodable {
    var name: String
    var description: String?
    var website: String?
    var avatar: String?
    var nfts: [String]?
    var likes: [String]?
    var id: String

    private enum CodingKeys: String, CodingKey {
        case name
        case description
        case website
        case avatar
        case nfts
        case likes
        case id
    }
}
