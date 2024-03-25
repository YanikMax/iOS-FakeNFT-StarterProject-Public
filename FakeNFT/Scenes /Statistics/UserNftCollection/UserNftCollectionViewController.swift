//
//  File.swift
//  FakeNFT
//
//  Created by Андрей Асланов on 22.12.23.
//

protocol NftViewOutput: AnyObject {
    func fetchDataForNftArray(_ nftArray: [String])
    func handleLikeButtonTap(for nftId: String)
    func handleCartButtonTap(for nftId: String)
    var likedNftIds: [String] { get set }
    var cartItemIds: [String] { get set }
}

import UIKit

final class UserNftCollectionViewController: UIViewController {

    private var nftArray: [String] = []
    private var nftsInfo: [NftModel] = []
    private var networkClient: StatisticsNetworkClientProtocol
    private var presenter: NftViewOutput?
    private var userId: String

    init(userId: String, nftArray: [String], networkClient: StatisticsNetworkClientProtocol = StatisticsNetworkClient()) {
        self.userId = userId
        self.nftArray = nftArray
        self.networkClient = networkClient
        super.init(nibName: nil, bundle: nil)
        self.presenter = NftPresenter(view: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var backButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
                                     style: .plain, target: self,
                                     action: #selector(leftBarButtonItemTapped))
        button.tintColor = .black
        return button
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(NftCollectionViewCell.self, forCellWithReuseIdentifier: "NftCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        return collectionView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .black
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupNavigationBar()
        setupUI()

        presenter?.fetchDataForNftArray(nftArray)
    }

    func displayNftInfo(_ nftInfo: [NftModel]) {
        nftsInfo = nftInfo
        collectionView.reloadData()
    }

    private func setupNavigationBar() {
        navigationItem.title = "Коллекция NFT"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)
        ]
        navigationItem.leftBarButtonItem = backButton
    }

    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func leftBarButtonItemTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension UserNftCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nftsInfo.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NftCollectionViewCell",
                                                            for: indexPath) as? NftCollectionViewCell
        else {
            return UICollectionViewCell()
        }

        let nftInfo = nftsInfo[indexPath.item]

        if let nftId = nftInfo.id {
            let isLiked = presenter?.likedNftIds.contains(nftId) ?? false
            let isInCart = presenter?.cartItemIds.contains(nftId) ?? false

            cell.likeButtonTappedHandler = { [weak self] in
                guard let self = self else { return }
                self.presenter?.handleLikeButtonTap(for: nftId)
            }

            cell.cartButtonTappedHandler = { [weak self] in
                guard let self = self else { return }
                self.presenter?.handleCartButtonTap(for: nftId)
            }

            cell.configure(with: nftInfo, isLiked: isLiked, isInCart: isInCart)
        }
        return cell
    }
}

extension UserNftCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - 16 * 2 - 9 * 2
        let itemWidth = availableWidth / 3
        return CGSize(width: itemWidth, height: 192)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 16, bottom: 16, right: 16)
    }
}

// MARK: - Presenter
extension UserNftCollectionViewController: NftViewInput {
    func showErrorAlert(for nftId: String, context: RequestContext) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let alertController = UIAlertController(
                title: "Не удалось получить\nданные",
                message: nil,
                preferredStyle: .alert
            )

            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)

            let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
                guard let self = self else { return }

                switch context {
                case .like:
                    self.presenter?.handleLikeButtonTap(for: nftId)
                case .cart:
                    self.presenter?.handleCartButtonTap(for: nftId)
                case .fetchTftData:
                    self.presenter?.fetchDataForNftArray(self.nftArray)
                }
            }

            alertController.addAction(retryAction)
            alertController.preferredAction = retryAction
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func showActivityIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.startAnimating()
        }
    }

    func hideActivityIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
        }
    }
}
