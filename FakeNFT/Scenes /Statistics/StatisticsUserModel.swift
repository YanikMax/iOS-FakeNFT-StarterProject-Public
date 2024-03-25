//
//  StatisticsUserModel.swift
//  FakeNFT
//
//  Created by Андрей Асланов on 10.12.23.
//

import Foundation

struct StatisticsUserModel: Decodable {
    let avatar: String?
    let username: String?
    let nfts: [String]?
    let nftCount: String?
    let description: String?
    let website: String?
    let rating: String?
    let id: String?

    private enum CodingKeys: String, CodingKey {
        case avatar
        case username
        case nfts
        case nftCount
        case description
        case website
        case rating
        case id
    }

    init(avatar: String? = nil,
         username: String? = nil,
         nfts: [String]? = nil,
         nftCount: String? = nil,
         description: String? = nil,
         website: String? = nil,
         rating: String? = nil,
         id: String? = nil
    ) {
        self.avatar = avatar
        self.username = username
        self.nfts = nfts
        self.nftCount = nftCount
        self.description = description
        self.website = website
        self.rating = rating
        self.id = id
    }
}
