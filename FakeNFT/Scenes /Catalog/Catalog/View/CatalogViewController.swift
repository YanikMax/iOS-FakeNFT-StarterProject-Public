//
//  CatalogViewController.swift
//  FakeNFT
//
//  Created by Ян Максимов on 11.12.2023.
//

import UIKit
import ProgressHUD
import Kingfisher

protocol CatalogView: AnyObject {
    func reloadCatalogTableView()
    func addRowsToCatalogTableView(indexPaths: [IndexPath])
    func displayAlert(title: String, message: String?, actions: [UIAlertAction])
}

protocol CatalogPresenterProtocol: AnyObject {
    var view: CatalogView? { get set }
    var collections: [NFTCollectionInfo] { get }
    func onViewDidLoad()
    func viewDidDisappear()
    func handleFilterButtonTap()
    func willDisplayCell(_ indexPath: IndexPath)
    func setUserDefaultsData(by type: Int, for key: String)
}

final class CatalogViewController: UIViewController, CatalogView {

    // MARK: - Public Properties
    var catalogPresenter: CatalogPresenterProtocol?

    init(presenter: CatalogPresenterProtocol) {
        self.catalogPresenter = presenter
        super.init(nibName: nil, bundle: nil)
        self.catalogPresenter?.view = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Properties
    private lazy var catalogTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.accessibilityIdentifier = "catalogTableView"
        return tableView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTransparentNavigationBar()
        setupTabBarAppearance()
        catalogPresenter?.onViewDidLoad()
        setupScreen()
        setupTableView()
        setupNavigationBar()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        catalogPresenter?.viewDidDisappear()
    }

    // MARK: Screen Setup
    private func setupScreen() {
        view.backgroundColor = .white

        addSubviews()
        constraintSubviews()
    }

    // MARK: TableView Setup
    private func setupTableView() {
        catalogTableView.dataSource = self
        catalogTableView.delegate = self
        catalogTableView.translatesAutoresizingMaskIntoConstraints = false
        catalogTableView.separatorStyle = .none
        catalogTableView.showsVerticalScrollIndicator = false
        catalogTableView.backgroundColor = .clear
        catalogTableView.isScrollEnabled = true
        catalogTableView.alwaysBounceVertical = false
        catalogTableView.allowsSelection = true
        catalogTableView.allowsMultipleSelection = false
        catalogTableView.register(CatalogCell.self)
    }

    // MARK: Adding Subviews
    private func addSubviews() {
        view.addSubview(catalogTableView)
    }

    // MARK: Subviews Constraints
    private func constraintSubviews() {
        NSLayoutConstraint.activate([
            catalogTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            catalogTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            catalogTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            catalogTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }

    // MARK: - Private methods
    private func setupNavigationBar() {
        guard let navigationBar = self.navigationController?.navigationBar else { return }

        let rightButton = UIBarButtonItem(image: UIImage(named: "buttonSort"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(displayFilterOptions))
        rightButton.tintColor = .black
        navigationBar.topItem?.setRightBarButton(rightButton, animated: true)
    }

    private func setupTransparentNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
    }

    private func setupTabBarAppearance() {
        guard let tabBar = tabBarController?.tabBar else { return }
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.isTranslucent = true
    }

    private func configCell(for cell: CatalogCell, indexPath: IndexPath) {
        guard let collection = catalogPresenter?.collections[indexPath.row] else { return }
        cell.collectionImageView.kf.indicatorType = .activity
        cell.collectionImageView.kf.setImage(with: collection.cover)
        cell.collectionLabelView.text = "\(collection.name) (\(collection.nfts.count))"
    }

    private func showCollectionInfo(for collection: NFTCollectionInfo) {
        let viewController = CollectionViewController()
        let presenter = CollectionPresenter(collection: collection)

        viewController.presenter = presenter
        presenter.view = viewController
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc private func displayFilterOptions() {
        let sortByNameAction = UIAlertAction(title: "По названию", style: .default) { [weak self] _ in
            self?.catalogPresenter?.setUserDefaultsData(by: FilterType.byName.rawValue, for: "CatalogFilterType")
            self?.catalogPresenter?.handleFilterButtonTap()
        }
        let sortByCountAction = UIAlertAction(title: "По количеству NFT", style: .default) { [weak self] _ in
            self?.catalogPresenter?.setUserDefaultsData(by: FilterType.NFTcount.rawValue, for: "CatalogFilterType")
            self?.catalogPresenter?.handleFilterButtonTap()
        }

        AlertFactory.shared.showActionSheet(from: self,
                                            title: "Сортировка",
                                            message: nil,
                                            actions: [sortByNameAction, sortByCountAction]
        )
    }
}

// MARK: - Public methods
extension CatalogViewController {
    func reloadCatalogTableView() {
        catalogTableView.reloadData()
    }

    func addRowsToCatalogTableView(indexPaths: [IndexPath]) {
        catalogTableView.performBatchUpdates {
            catalogTableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }

    func displayAlert(title: String, message: String?, actions: [UIAlertAction]) {
        let viewModel = AlertModel(alertControllerStyle: .alert,
                                   alertTitle: title,
                                   alertMessage: message,
                                   alertActions: actions)
        let presenter = AlertPresenter(delegate: self)
        presenter.presentAlert(result: viewModel)
    }
}

// MARK: - UITableViewDelegate
extension CatalogViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 179
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        catalogPresenter?.willDisplayCell(indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let collection = catalogPresenter?.collections[indexPath.row] {
            showCollectionInfo(for: collection)
        }
    }
}

// MARK: - UITableViewDataSource
extension CatalogViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catalogPresenter?.collections.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CatalogCell = tableView.dequeueReusableCell()
        configCell(for: cell, indexPath: indexPath)
        return cell
    }
}
