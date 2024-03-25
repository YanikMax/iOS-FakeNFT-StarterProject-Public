//
//  UserCardPresenter.swift
//  FakeNFT
//
//  Created by Андрей Асланов on 22.12.23.
//

protocol UserCardViewOutput {
    func updateUI()
    func getUserInfo() -> StatisticsUserModel
    func getNfts() -> [String]
    func getUserId() -> String
}

import Foundation

final class UserCardPresenter: UserCardViewOutput {

    private weak var view: UserCardViewInput?
    private let user: StatisticsUserModel

    init(user: StatisticsUserModel, view: UserCardViewInput) {
        self.user = user
        self.view = view
        self.updateUI()
    }

    func updateUI() {
        view?.updateUI(
            avatarURL: getUserInfo().avatar ?? "",
            username: getUserInfo().username ?? "",
            description: getUserInfo().description ?? ""
        )
    }

    func getUserInfo() -> StatisticsUserModel {
        return user
    }

    func getNfts() -> [String] {
        return user.nfts ?? []
    }

    func getUserId() -> String {
        return user.id ?? ""
    }
}
