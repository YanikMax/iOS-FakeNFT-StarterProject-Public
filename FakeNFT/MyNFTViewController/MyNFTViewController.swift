import UIKit

protocol MyNFTViewProtocol: AnyObject {
    func updateNFT(viewModel: [MyNFTViewModel])
}

final class MyNFTViewController: UIViewController, MyNFTViewProtocol {
    // MARK: - Private Properties
    private var presenter: MyNFTPresenter!
    private var viewModel: [MyNFTViewModel] = []

    private lazy var myNFTTable: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = false
        tableView.isUserInteractionEnabled = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.accessibilityIdentifier = "myNFTTable"
        tableView.register(MyNFTTableViewCell.self, forCellReuseIdentifier: "MyNFTTableViewCell")
        return tableView
    }()

    private lazy var noNFTLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .textPrimary
        label.textAlignment = .center
        label.text = "У Вас еще нет NFT"
        label.isHidden = true
        return label
    }()

    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        presenter = MyNFTPresenter(view: self)
        presenter.loadNFTData()
        myNFTTable.register(MyNFTTableViewCell.self, forCellReuseIdentifier: "MyNFTTableViewCell")
        setupConstraints()
        setupNavigationBar()
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
    func updateNFT(viewModel: [MyNFTViewModel]) {
        self.viewModel = viewModel
        myNFTTable.reloadData()

        if viewModel.isEmpty {
            noNFTLabel.isHidden = false
        } else {
            noNFTLabel.isHidden = true
        }
    }

    // MARK: - Private Methods
    private func setupConstraints() {
        view.addSubview(myNFTTable)
        view.addSubview(noNFTLabel)

        NSLayoutConstraint.activate([
            myNFTTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            myNFTTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            myNFTTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            myNFTTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            noNFTLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noNFTLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        view.bringSubviewToFront(noNFTLabel)
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]
        title = "Мои NFT"

        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .black
        backButton.accessibilityIdentifier = "backButton"
        navigationItem.leftBarButtonItem = backButton

        let sortButton = UIBarButtonItem(
            image: UIImage(named: "sortButton"),
            style: .plain,
            target: self,
            action: #selector(sortButtonTapped)
        )
        sortButton.tintColor = .black
        navigationItem.rightBarButtonItem = sortButton
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func sortButtonTapped() {
        let alertController = UIAlertController(title: "Сортировка", message: nil, preferredStyle: .actionSheet)

        let sortByPriceAction = UIAlertAction(title: "По цене", style: .default) { [weak self] (_) in
            self?.sortByPrice()
        }

        alertController.addAction(sortByPriceAction)

        let sortByRatingAction = UIAlertAction(title: "По рейтингу", style: .default) { [weak self] (_) in
            self?.sortByRating()
        }
        alertController.addAction(sortByRatingAction)

        let sortByNameAction = UIAlertAction(title: "По названию", style: .default) { [weak self] (_) in
            self?.sortByName()
        }
        alertController.addAction(sortByNameAction)

        let cancelAction = UIAlertAction(title: "Закрыть", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
}

extension MyNFTViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "MyNFTTableViewCell",
            for: indexPath) as? MyNFTTableViewCell else {
            return UITableViewCell()
        }
        let item = viewModel[indexPath.row]
        cell.configureCell(with: item)
        cell.presenter = self.presenter
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}

extension MyNFTViewController {
    private func sortByPrice() {
        viewModel.sort(by: { $0.price < $1.price })
        myNFTTable.reloadData()
    }

    private func sortByRating() {
        viewModel.sort(by: { $0.rating > $1.rating })
        myNFTTable.reloadData()
    }

    private func sortByName() {
        viewModel.sort(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })
        myNFTTable.reloadData()
    }
}
