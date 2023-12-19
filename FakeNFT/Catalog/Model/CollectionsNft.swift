//
//  CatalogModel.swift
//  FakeNFT
//
//  Created by Ян Максимов on 11.12.2023.
//

import Foundation

struct NFTCollection: Codable {
    let name: String
    let cover: String
    let nfts: [String]
    let description: String
    let author: String
    let id: String
}

struct NFTCollectionInfo {
    let name: String
    let cover: URL?
    let nfts: [String]
    let description: String
    let author: String
    let id: String
    
    init(fromNFTCollection collection: NFTCollection) {
        self.name = collection.name
        self.cover = collection.cover.convertedURL()
        self.nfts = collection.nfts
        self.description = collection.description
        self.author = collection.author
        self.id = collection.id
    }
}

extension String {
    func convertedURL() -> URL? {
        if let url = URL(string: self) {
            return url
        }
        
        guard let encodedString = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedString) else {
            return nil
        }
        
        return url
    }
}
