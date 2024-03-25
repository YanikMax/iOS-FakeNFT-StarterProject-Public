//
//  UsersListDecoding.swift
//  FakeNFT
//
//  Created by Андрей Асланов on 12.12.23.
//

import Foundation

// MARK: - UsersListElement
struct UsersListElement: Codable {
    let name, avatar: String
    let description: String
    let website: String
    let nfts: [String]
    let rating, id: String
}

typealias UsersList = [UsersListElement]
