import Foundation
import ProgressHUD

protocol FavoritePresenterProtocol: AnyObject {
    func nftViewDidLoad()
}

final class FavoriteNFTPresenter {
    // MARK: - Public Properties
    var user: Profile?

    // MARK: - Private Properties
    private weak var view: FavoriteViewProtocol?
    private let defaultNetworkClient = DefaultNetworkClient()
    private var onNFTCountUpdate: ((Int) -> Void)?
    private var likedNFTIds: [String] = []

    init(view: FavoriteViewProtocol) {
        self.view = view
    }

    func nftViewDidLoad() {
        ProgressHUD.show()
        fetchLikedNFTs()
    }

    // MARK: - Public Methods
    func toggleLike(for nftId: String) {
        ProgressHUD.show()
        var likedNFTsArray = likedNFTIds
        if let index = likedNFTsArray.firstIndex(of: nftId) {
            likedNFTsArray.remove(at: index)
        } else {
            likedNFTsArray.append(nftId)
        }
        likedNFTIds = likedNFTsArray

        updateNFTs()
        sendUpdatedProfileToServer()
    }

    // MARK: - Private Methods
    private func fetchLikedNFTs() {
        _ = defaultNetworkClient.send(request: ProfileRequest(), completionQueue: .main) { [weak self] result in
            ProgressHUD.dismiss()
            switch result {
            case .success(let data):
                do {
                    let profile = try JSONDecoder().decode(Profile.self, from: data)

                    if let likes = profile.likes {

                        self?.likedNFTIds = likes
                    } else {
                        print("Liked NFTs IDs is nil")
                    }
                    self?.updateNFTs()
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            case .failure(let error):
                print("Error fetching liked NFTs data: \(error)")
            }
        }
    }

    private func updateNFTs() {
        _ = defaultNetworkClient.send(request: MyNFTRequest(), completionQueue: .main) { [weak self] result in
            ProgressHUD.dismiss()

            switch result {
            case .success(let data):
                do {
                    let nftData = try JSONDecoder().decode([FavoriteNFTViewModel].self, from: data)

                    let likedNFTs = nftData.map { nft in
                        var updatedNFT = nft
                        updatedNFT.isFavorite = self?.likedNFTIds.contains(nft.id) ?? false
                        return updatedNFT
                    }.filter { self?.likedNFTIds.contains($0.id) ?? false }

                    let nftCount = likedNFTs.count
                    self?.onNFTCountUpdate?(nftCount)

                    self?.view?.updateFavNFT(viewModel: likedNFTs)

                } catch {
                    print("Error decoding JSON: \(error)")
                }
            case .failure(let error):
                print("Error fetching NFT data: \(error)")
            }
        }
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

        if !likedNFTIds.isEmpty {
            parameters["likes"] = likedNFTIds.joined(separator: ",")
        }

        return parameters
    }

    private func sendUpdatedProfileToServer() {

        let updatedProfile = Profile(
            name: "",
            description: "",
            website: "",
            avatar: "",
            nfts: nil,
            likes: likedNFTIds,
            id: ""
        )
        self.user?.likes = likedNFTIds

        updateProfileData(updatedProfile: updatedProfile) { [weak self] result in
            switch result {
            case .success:
                self?.fetchLikedNFTs()
            case .failure(let error):
                print("Error updating the profile: \(error)")
            }
            ProgressHUD.dismiss()
        }
    }
}
