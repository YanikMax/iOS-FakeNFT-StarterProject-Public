//
//  CollectionNFTViewController.swift
//  FakeNFT
//
//  Created by Ян Максимов on 16.12.2023.
//

import UIKit
import Kingfisher
import SafariServices

protocol CollectionViewControllerProtocol: AnyObject {
    var presenter: CollectionPresenterProtocol? { get set }
    func showErrorAlert(_ message: String, repeatAction: Selector?, target: AnyObject?)
    func updateData()
}

final class CollectionViewController: UIViewController, CollectionViewControllerProtocol {

    // MARK: - Constants
    private enum Constants {
        static let cellIdentifier = "NFTCell"
        static let contentInsets: CGFloat = 16
        static let spacing: CGFloat = 10
    }

    // MARK: - Public Properties
    var presenter: CollectionPresenterProtocol?

    // MARK: - Private Properties
    private lazy var contentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .white
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()

    private lazy var coverImage: UIImageView = {
        var image = UIImageView()
        image.clipsToBounds = true
        image.layer.cornerRadius = 12
        image.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        image.heightAnchor.constraint(equalToConstant: 310).isActive = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    private lazy var collectionName: UILabel = {
        var label = UILabel()
        label.textColor = .black
        label.font = .headline3
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var collectionAuthor: UILabel = {
        var label = UILabel()
        label.textColor = .black
        label.font = .caption2
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var collectionAuthorLink: UILabel = {
        var label = UILabel()
        label.textColor = UIColor(hexString: "#0A84FF")
        label.font = .caption1
        label.translatesAutoresizingMaskIntoConstraints = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.linkLabelTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        return label
    }()

    private lazy var collectionDescription: UILabel = {
        var label = UILabel()
        label.textColor = .black
        label.font = .caption2
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var nftsCollectionView: ResizableCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Constants.spacing
        layout.minimumLineSpacing = Constants.spacing
        let collectionView = ResizableCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.register(NFTCell.self, forCellWithReuseIdentifier: Constants.cellIdentifier)
        collectionView.contentInset = UIEdgeInsets(top: 0,
                                                   left: Constants.contentInsets,
                                                   bottom: Constants.contentInsets,
                                                   right: Constants.contentInsets)
        collectionView.isScrollEnabled = false

        // Добавляем UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshCollection(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl

        return collectionView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
        presenter?.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cartDeleteButtonTapped),
            name: .cartItemRemoved,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.refreshData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public methods
    func showErrorAlert(_ message: String, repeatAction: Selector? = nil, target: AnyObject? = nil) {
        let actionCancel = UIAlertAction(title: "Отменить", style: .cancel) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }

        var actions = [actionCancel]

        if let repeatAction = repeatAction, let target = target {
            let actionOK = UIAlertAction(title: "Повторить", style: .default) { _ in
                _ = target.perform(repeatAction)
            }
            actions.append(actionOK)
        }

        let viewModel = AlertModel(alertControllerStyle: .alert,
                                   alertTitle: "Что-то пошло не так",
                                   alertMessage: message,
                                   alertActions: actions)
        let presenter = AlertPresenter(delegate: self)
        presenter.presentAlert(result: viewModel)
    }

    // MARK: - Private methods
    private func setupScreen() {
        view.backgroundColor = .white
        setupNavigationBar()
        addSubviews()
        setData()
    }

    private func addSubviews() {
        let authorStack = createAuthorStack()
        let nameAndAuthorStack = createNameAndAuthorStack(with: authorStack)
        let infoStack = createInfoStack(with: nameAndAuthorStack)
        let mainStack = createMainStack(with: [coverImage, infoStack, nftsCollectionView])

        view.addSubview(contentScrollView)
        contentScrollView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            contentScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            contentScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            mainStack.centerXAnchor.constraint(equalTo: contentScrollView.centerXAnchor),
            mainStack.topAnchor.constraint(equalTo: contentScrollView.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor),
            mainStack.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor)
        ])
    }

    private func setupNavigationBar() {
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.backIndicatorImage = UIImage(named: "backButton")
        navigationBar.topItem?.backButtonTitle = ""
        navigationBar.tintColor = .black
    }

    func updateData() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionAuthorLink.text = strongSelf.presenter?.authorProfile?.name
            strongSelf.nftsCollectionView.reloadData()
        }
    }

    private func setData() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionName.text = strongSelf.presenter?.collection.name
            strongSelf.coverImage.kf.setImage(with: strongSelf.presenter?.collection.cover)
            strongSelf.collectionAuthor.text = "Автор коллекции:"
            strongSelf.collectionDescription.text = strongSelf.presenter?.collection.description
        }
    }

    @objc private func linkLabelTapped() {
        if let url = presenter?.authorProfile?.website {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true, completion: nil)
        }
    }

    @objc private func refreshCollection(_ sender: UIRefreshControl) {
        presenter?.refreshData()

        sender.endRefreshing()
    }

    @objc private func cartDeleteButtonTapped() {
        presenter?.refreshData()
    }

    private func createStackView(
        axis: NSLayoutConstraint.Axis,
        alignment: UIStackView.Alignment,
        distribution: UIStackView.Distribution,
        spacing: CGFloat,
        margins: UIEdgeInsets,
        applyMargins: Bool
    ) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.spacing = spacing
        stackView.layoutMargins = margins
        stackView.isLayoutMarginsRelativeArrangement = applyMargins
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    private func addArrangedSubviews(stackView: UIStackView, views: [UIView]) {
        for view in views {
            stackView.addArrangedSubview(view)
        }
    }

    private func createAuthorStack() -> UIStackView {
        let stack = createStackView(
            axis: .horizontal,
            alignment: .bottom,
            distribution: .fill,
            spacing: 4,
            margins: .zero,
            applyMargins: false
        )
        addArrangedSubviews(stackView: stack, views: [collectionAuthor, collectionAuthorLink])
        return stack
    }

    private func createNameAndAuthorStack(with authorStack: UIStackView) -> UIStackView {
        let stack = createStackView(
            axis: .vertical,
            alignment: .leading,
            distribution: .fill,
            spacing: 15,
            margins: .zero,
            applyMargins: false
        )
        addArrangedSubviews(stackView: stack, views: [collectionName, authorStack])
        return stack
    }

    private func createInfoStack(with nameAndAuthorStack: UIStackView) -> UIStackView {
        let stack = createStackView(
            axis: .vertical,
            alignment: .leading,
            distribution: .fill,
            spacing: 5,
            margins: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16),
            applyMargins: true
        )
        addArrangedSubviews(stackView: stack, views: [nameAndAuthorStack, collectionDescription])
        return stack
    }

    private func createMainStack(with views: [UIView]) -> UIStackView {
        let stack = createStackView(
            axis: .vertical,
            alignment: .fill,
            distribution: .fill,
            spacing: 16,
            margins: .zero,
            applyMargins: false
        )
        addArrangedSubviews(stackView: stack, views: views)
        return stack
    }
}

extension CollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter?.nfts.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NFTCell",
                                                            for: indexPath
        ) as? NFTCell else {
            return UICollectionViewCell()
        }
        if let nft = presenter?.nfts[indexPath.row] {
            cell.viewModel = nft
            cell.delegate = self
            cell.isLikedNFT = presenter?.isLikedNFT(nft.id) ?? false
            cell.isAddedToCart = presenter?.isInCart(nft.id) ?? false
        }
        return cell
    }
}

extension CollectionViewController: UICollectionViewDelegate {

}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - Constants.contentInsets * 2 - Constants.spacing * 2) / 3
        return CGSize(width: width,
                      height: width + 90)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return Constants.spacing
    }
}

extension CollectionViewController: NFTCellDelegate {
    func didTapLikeButton(_ id: String) {
        presenter?.setLikeForNFT(id)

        if let index = presenter?.nfts.firstIndex(where: { $0.id == id }) {
            let indexPath = IndexPath(item: index, section: 0)
            nftsCollectionView.reloadItems(at: [indexPath])
        }
    }

    func didTapCartButton(_ id: String) {
        presenter?.addNFTToCart(id)
    }
}
