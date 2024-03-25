import UIKit

protocol FavoriteViewProtocol: AnyObject {
    func updateFavNFT(viewModel: [FavoriteNFTViewModel])
}

final class FavoriteViewController: UIViewController, FavoriteViewProtocol {
    // MARK: - Private Properties
    private var presenter: FavoriteNFTPresenter!
    private var viewModel: [FavoriteNFTViewModel] = []

    private lazy var noFavNFTLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .textPrimary
        label.textAlignment = .center
        label.text = "У Вас еще нет избранных NFT"
        label.isHidden = true
        return label
    }()

    private lazy var favoriteNFTCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(FavoriteNFTCell.self, forCellWithReuseIdentifier: "FavoriteNFTCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        return collectionView
    }()

    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupConstraints()
        setupNavigationBar()
        presenter = FavoriteNFTPresenter(view: self)
        presenter.nftViewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Public Methods
    func updateFavNFT(viewModel: [FavoriteNFTViewModel]) {
        self.viewModel = viewModel
        favoriteNFTCollectionView.reloadData()

        if viewModel.isEmpty {
            noFavNFTLabel.isHidden = false
            favoriteNFTCollectionView.isHidden = true
            navigationController?.navigationBar.topItem?.title = ""
        } else {
            noFavNFTLabel.isHidden = true
            favoriteNFTCollectionView.isHidden = false
            navigationController?.navigationBar.topItem?.title = "Избранные NFT"
        }
    }

    // MARK: - Private Methods
    private func setupConstraints() {
        view.addSubview(noFavNFTLabel)
        view.addSubview(favoriteNFTCollectionView)
        NSLayoutConstraint.activate([
            noFavNFTLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noFavNFTLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            favoriteNFTCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            favoriteNFTCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            favoriteNFTCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            favoriteNFTCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        view.bringSubviewToFront(noFavNFTLabel)
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]
        title = "Избранные NFT"

        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension FavoriteViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: FavoriteNFTCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "FavoriteNFTCell",
            for: indexPath) as? FavoriteNFTCell else {
            return UICollectionViewCell()
        }
        let nftData = viewModel[indexPath.item]
        cell.configureCell(with: nftData)
        cell.presenter = self.presenter
        return cell

    }
}

extension FavoriteViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - 16 * 2 - 7
        return CGSize(width: availableWidth / 2, height: 80)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    }
}
