import Foundation
import ProgressHUD

protocol ProfilePresenter: AnyObject {
    func updateUser(user: Profile?)
}

class ProfilePresenterImpl {
    // MARK: - Public Properties
    var user: Profile?
    var defaultNetworkClient = DefaultNetworkClient()
    var myNFTPresenter: MyNFTPresenter?
    // MARK: - Private Properties
    private weak var view: ProfilePresenter?
    // MARK: - Initializers
    init(view: ProfilePresenter) {
        self.view = view
    }
    // MARK: - Public Methods

    func fetchData() {
        ProgressHUD.show()
        _ = defaultNetworkClient.send(request: ProfileRequest(), completionQueue: .main) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let profile = try JSONDecoder().decode(Profile.self, from: data)

                    if let likes = profile.likes {
                        print("Liked NFTs IDs: \(likes)")
                    }

                    if let nfts = profile.nfts {
                        DispatchQueue.main.async {
                            self?.myNFTPresenter?.user = profile
                            self?.myNFTPresenter?.loadNFTData()
                        }
                    } else {
                        print("NFTs IDs is nil")
                    }
                    DispatchQueue.main.async {
                        self?.view?.updateUser(user: profile)
                        ProgressHUD.dismiss()
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                    ProgressHUD.dismiss()
                }
            case .failure(let error):
                print("Error fetching data: \(error)")
                ProgressHUD.dismiss()
            }
        }
    }

    func updateProfileData(updatedProfile: Profile, completion: @escaping (Result<Data, Error>) -> Void) {
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
    // MARK: - Private Methods

    private func getDataUser(completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1") else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: nil)))
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("\(RequestConstants.accessToken)", forHTTPHeaderField: "X-Practicum-Mobile-Token")

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

    private  func createURLRequest(for request: NetworkRequest, with profile: Profile) -> URLRequest? {
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
        let parameters: [String: Any] = [
            "name": profile.name,
            "description": profile.description ?? "",
            "website": profile.website ?? ""
        ]
        return parameters
    }
}
