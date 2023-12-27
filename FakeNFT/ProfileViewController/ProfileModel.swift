import Foundation

struct Profile: Decodable, Encodable {
    var name: String
    var description: String?
    var website: String?
    var avatar: String?
    var nfts: [Nft]?
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
    
    init(name: String, description: String?, website: String?, avatar: String?, nfts: [Nft]?, likes: [String]?, id: String) {
        self.name = name
        self.description = description
        self.website = website
        self.avatar = avatar
        self.nfts = nfts
        self.likes = likes
        self.id = id
    }
}
