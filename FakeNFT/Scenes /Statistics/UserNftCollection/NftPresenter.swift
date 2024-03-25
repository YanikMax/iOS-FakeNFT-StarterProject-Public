//
//  NftPresenter.swift
//  FakeNFT
//
//  Created by Андрей Асланов on 28.12.23.
//

import Foundation

protocol NftViewInput: AnyObject {
    func displayNftInfo(_ nftInfo: [NftModel])
    func showErrorAlert(for nftId: String, context: RequestContext)
    func showActivityIndicator()
    func hideActivityIndicator()
}

final class NftPresenter: NSObject, NftViewOutput {
    private weak var view: NftViewInput?
    private var networkClient: StatisticsNetworkClientProtocol
    private var userDefaultsManager: UserDefaultsManagerProtocol

    var likedNftIds: [String] {
        didSet {
            userDefaultsManager.saveLikedNftIds(likedNftIds)
        }
    }

    var cartItemIds: [String] {
        didSet {
            userDefaultsManager.saveCartItems(cartItemIds)
        }
    }

    override init() {
        self.networkClient = StatisticsNetworkClient()
        self.userDefaultsManager = UserDefaultsManager()
        self.likedNftIds = []
        self.cartItemIds = []

        self.likedNftIds = userDefaultsManager.loadLikedNftIds()
        self.cartItemIds = userDefaultsManager.loadCartItems()

        super.init()
    }

    convenience init(
        view: NftViewInput,
        networkClient: StatisticsNetworkClientProtocol = StatisticsNetworkClient(),
        userDefaultsManager: UserDefaultsManagerProtocol = UserDefaultsManager()
    ) {
        self.init()
        self.view = view
        self.networkClient = networkClient
        self.userDefaultsManager = userDefaultsManager
    }

    func fetchDataForNftArray(_ nftArray: [String]) {
        view?.showActivityIndicator()
        view?.displayNftInfo(MockNftData.nft)
        view?.hideActivityIndicator()
    }

    // MARK: - NFTs
    private func fetchТftData(forNftId nftId: String) {
        guard let url = URL(string: "\(RequestConstants.baseURL)/api/v1/nft/\(nftId)") else {
            return
        }
        view?.showActivityIndicator()
        getRequest(url, nftId: nftId, context: .fetchTftData)
    }

    private func getRequest(_ url: URL, nftId: String, context: RequestContext) {
        networkClient.fetchData(from: url) { [weak self] result in

            defer {
                self?.view?.hideActivityIndicator()
            }

            switch result {
            case .success(let data):
                self?.handleSuccess(data: data, nftId: nftId, context: context)

            case .failure(let error):
                self?.handleFailure(error: error, nftId: nftId, context: context)
            }
            self?.view?.hideActivityIndicator()
        }
    }

    private func handleSuccess(data: Data, nftId: String, context: RequestContext) {
        do {
            _ = try JSONDecoder().decode(NftModel.self, from: data)
        } catch {
            view?.showErrorAlert(for: nftId, context: context)
        }
    }

    private func handleFailure(error: Error, nftId: String, context: RequestContext) {
        view?.showErrorAlert(for: nftId, context: context)
    }

    // MARK: - Likes
    func handleLikeButtonTap(for nftId: String) {
        guard let url = URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1") else {
            return
        }

        view?.showActivityIndicator()

        if likedNftIds.contains(nftId) {
            likedNftIds = likedNftIds.filter { $0 != nftId }
        } else {
            likedNftIds.append(nftId)
        }

        let likesArray = likedNftIds.map { ["likes": $0] }
        let requestData: [String: Any] = [:]
        var parametersArray: [String] = []

        likesArray.forEach { like in
            let parameterString = like.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            parametersArray.append(parameterString)
        }

        let likesString = parametersArray.joined(separator: "&")

        let finalParameterString = requestData.map {
            "\($0.key)=\($0.value)"
        }.joined(separator: "&") + "&" + likesString

        let bodyData = finalParameterString.data(using: .utf8)

        sendRequestToURL(url, bodyData: bodyData, nftId: nftId, context: .like)
    }

    // MARK: - Cart
    func handleCartButtonTap(for nftId: String) {
        guard let url = URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1") else {
            return
        }

        view?.showActivityIndicator()

        if cartItemIds.contains(nftId) {
            cartItemIds = cartItemIds.filter { $0 != nftId }
        } else {
            cartItemIds.append(nftId)
        }

        let nftIdsArray = cartItemIds.map { ["nfts": $0] }
        let requestData: [String: Any] = ["id": "1"]
        var parametersArray: [String] = []

        nftIdsArray.forEach { nft in
            let parameterString = nft.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            parametersArray.append(parameterString)
        }

        let nftsString = parametersArray.joined(separator: "&")
        let finalParameterString = requestData.map { "\($0.key)=\($0.value)" }.joined(separator: "&") + "&" + nftsString
        let bodyData = finalParameterString.data(using: .utf8)

        sendRequestToURL(url, bodyData: bodyData, nftId: nftId, context: .cart)
    }

    private func sendRequestToURL(_ url: URL, bodyData: Data?, nftId: String, context: RequestContext) {
        networkClient.sendRequest(to: url, body: bodyData) { [weak self] result in

            defer {
                self?.view?.hideActivityIndicator()
            }

            switch result {
            case .success(let data):
                print("Received data from server: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")

            case .failure(let error):
                self?.handleFailure(error: error, nftId: nftId, context: context)
            }
        }
    }
}
