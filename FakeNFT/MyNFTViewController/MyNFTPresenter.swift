import Foundation
import ProgressHUD

protocol MyNFTPresenterProtocol: AnyObject {
    func loadNFTData()
}

final class MyNFTPresenter: MyNFTPresenterProtocol {
    // MARK: - Public Properties
    var filteredNFTs: [String] = []
    var user: Profile?

    // MARK: - Private Properties
    private let defaultNetworkClient = DefaultNetworkClient()
    private var onNFTCountUpdate: ((Int) -> Void)?
    private weak var view: MyNFTViewProtocol?
    private var likedNFTs: [String] = []

    init(view: MyNFTViewProtocol) {
        self.view = view
    }

    init(onNFTCountUpdate: ((Int) -> Void)?) {
        self.onNFTCountUpdate = onNFTCountUpdate
    }

    // MARK: - Public Methods
    func toggleLike(for nftId: String) {
        ProgressHUD.show()
        if var user = user {
            if user.likes?.contains(nftId) == true {
                user.likes = user.likes?.filter { $0 != nftId }
            } else {
                user.likes?.append(nftId)
            }
            likedNFTs = user.likes ?? []
            user.likes = likedNFTs
            self.user = user

            sendUpdatedProfileToServer()
        }
    }

    func loadNFTData() {
        ProgressHUD.show()
        loadUserProfile()
    }

    // MARK: - Private Methods
    private func loadUserProfile() {
        defaultNetworkClient.send(request: ProfileRequest(), completionQueue: .main) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let userProfile = try JSONDecoder().decode(Profile.self, from: data)

                    self?.user = userProfile
                    self?.likedNFTs = userProfile.likes ?? []

                    DispatchQueue.main.async {
                        self?.fetchNFTData()
                    }
                } catch {
                    print("Error decoding user profile JSON: \(error)")
                }
            case .failure(let error):
                print("Error fetching user profile: \(error)")
            }
        }
    }

    private func filterNFTsForUser(_ nftData: [MyNFTViewModel], userNFTIds: [String]) -> [MyNFTViewModel] {
        return nftData.filter { nft in
            return userNFTIds.contains(nft.id)
        }
    }

    private func fetchNFTData() {
        _ = defaultNetworkClient.send(request: MyNFTRequest(), completionQueue: .main) { [weak self] result in
            ProgressHUD.dismiss()

            switch result {
            case .success(let data):
                do {
                    let nftData = try JSONDecoder().decode([MyNFTViewModel].self, from: data)
                    let userNFTIds = self?.user?.nfts ?? []
                    let filteredNFTs = self?.filterNFTsForUser(nftData, userNFTIds: userNFTIds) ?? []

                    self?.updateNFTs(filteredNFTs)
                } catch {
                    print("Error decoding JSON: \(error)") }

            case .failure(let error):
                print("Error fetching NFT data: \(error)")
            }
        }
    }

    private func updateNFTs(_ nftData: [MyNFTViewModel]) {
        let nftCount = nftData.count
        onNFTCountUpdate?(nftCount)

        let updatedNFTs = nftData.map { nft in
            var updatedNFT = nft
            updatedNFT.isFavorite = likedNFTs.contains(nft.id)
            return updatedNFT
        }
        view?.updateNFT(viewModel: updatedNFTs)
    }

    private func updateProfileData(updatedProfile: Profile, completion: @escaping (Result<Data, Error>) -> Void) {
        let putRequest = PutProfileRequest(updatedProfile: updatedProfile)

        guard let urlRequest = createURLRequest(for: putRequest, with: updatedProfile) else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: nil)))
            return
        }
        let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let data = data {
                print("Response data: \(String(data: data, encoding: .utf8) ?? "No data")")
                completion(.success(data))
            } else {
                let noDataError = NSError(domain: "NoData", code: 0, userInfo: nil)
                completion(.failure(noDataError))
            }
        }
        task.resume()
    }

    private func createURLRequest(for request: NetworkRequest, with profile: Profile) -> URLRequest? {
        guard let endpointURL = request.endpoint else {
            return nil
        }
        var urlRequest = URLRequest(url: endpointURL)
        urlRequest.httpMethod = request.httpMethod.rawValue

        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(RequestConstants.accessToken, forHTTPHeaderField: "X-Practicum-Mobile-Token")

        if let parameters = createParameters(for: profile) {
            let parameterString = parameters
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: "&")
            urlRequest.httpBody = parameterString.data(using: .utf8)
        }
        return urlRequest
    }

    private func createParameters(for profile: Profile) -> [String: Any]? {
        var parameters: [String: Any] = [:]

        parameters["name"] = profile.name
        parameters["description"] = profile.description
        parameters["website"] = profile.website
        parameters["avatar"] = profile.avatar
        parameters["nfts"] = profile.nfts?.joined(separator: ",")

        if !likedNFTs.isEmpty {
            parameters["likes"] = likedNFTs.joined(separator: ",")
        }
        return parameters
    }

    private func sendUpdatedProfileToServer() {
        guard let userId = self.user?.id else {
            print("Error: User ID is missing")
            return
        }
        let updatedProfile = Profile(
            name: user?.name ?? "",
            description: user?.description ?? "",
            website: user?.website ?? "",
            avatar: user?.avatar ?? "",
            nfts: self.filteredNFTs,
            likes: likedNFTs,
            id: userId
        )
        self.user?.likes = likedNFTs

        updateProfileData(updatedProfile: updatedProfile) { [weak self] result in
            switch result {
            case .success:
                self?.fetchNFTData()
            case .failure(let error):
                print("Error updating the profile: \(error)")
            }
            ProgressHUD.dismiss()
        }
    }
}
