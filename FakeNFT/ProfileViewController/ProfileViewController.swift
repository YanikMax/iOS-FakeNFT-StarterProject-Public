import UIKit
import SafariServices

final class ProfileViewController: UIViewController, ProfilePresenter {

    // MARK: - Private Properties
    private var presenter: ProfilePresenterImpl!
    private var cellTexts = ["Мои NFT", "Избранные NFT", "О разработчике"]
    private var nftCount: Int?
    private var currentDisplayedUser: Profile?
    private var myNFTPresenter: MyNFTPresenter?

    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textPrimary
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var bioLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .textPrimary
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()

    private lazy var linkLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .blueUniversal
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.frame = label.frame.inset(by: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(linkLabelTapped))
        label.addGestureRecognizer(tapGesture)
        return label
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.accessibilityIdentifier = "profileTableView"
        tableView.separatorInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.isScrollEnabled = false
        return tableView
    }()
    private lazy var editButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem()
        barButtonItem.accessibilityIdentifier = "edit"
        barButtonItem.image = UIImage(named: "editButton")
        barButtonItem.tintColor = .black
        barButtonItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 9)
        barButtonItem.action = #selector(editButtonTapped)
        barButtonItem.target = self
        return barButtonItem
    }()

    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.topItem?.rightBarButtonItem = editButton

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        presenter = ProfilePresenterImpl(view: self)

        setupUI()
        setupConstraints()
        presenter.fetchData()

        setupNFTPresenter()
    }

    // MARK: - Public Methods
    func updateUser(user: Profile?) {
        guard let currentUser = user else { return }
        DispatchQueue.main.async {
            self.currentDisplayedUser = currentUser
            self.nameLabel.text = currentUser.name
            self.bioLabel.text = currentUser.description
            self.linkLabel.text = currentUser.website
        }
        if let imageURL = URL(string: currentUser.avatar ?? "") {
            avatarImageView.kf.setImage(with: imageURL)
        }

        tableView.reloadData()
    }

    // MARK: - Private Methods
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(bioLabel)
        view.addSubview(linkLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.bottomAnchor.constraint(equalTo: bioLabel.topAnchor, constant: -20),

            nameLabel.heightAnchor.constraint(equalToConstant: 28),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 41),

            bioLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
            bioLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            bioLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            bioLabel.bottomAnchor.constraint(equalTo: linkLabel.topAnchor, constant: -8),

            linkLabel.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 8),
            linkLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            linkLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            linkLabel.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -40),

            tableView.topAnchor.constraint(equalTo: linkLabel.bottomAnchor, constant: 40),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func setupNFTPresenter() {
        let updateNFTCountClosure: (Int) -> Void = { [weak self] count in
            self?.nftCount = count
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
        myNFTPresenter = MyNFTPresenter(onNFTCountUpdate: updateNFTCountClosure)
        myNFTPresenter?.loadNFTData()
    }

    private func createChevronImageView() -> UIImageView {
        let chevronImage = UIImage(systemName: "chevron.right")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        let chevronImageView = UIImageView(image: chevronImage)
        return chevronImageView
    }

    @objc private func editButtonTapped() {
        let profileEditViewController = ProfileEditViewController()
        profileEditViewController.currentUser = currentDisplayedUser
        profileEditViewController.avatarImageURL = URL(string: currentDisplayedUser?.avatar ?? "")

        profileEditViewController.onProfileUpdate = { [weak self] name, description, website in
            self?.currentDisplayedUser?.name = name
            self?.currentDisplayedUser?.description = description
            self?.currentDisplayedUser?.website = website
            DispatchQueue.main.async { [weak self] in
                self?.nameLabel.text = name
                self?.bioLabel.text = description
                self?.linkLabel.text = website
            }
        }

        let navigationController = UINavigationController(rootViewController: profileEditViewController)
        present(navigationController, animated: true, completion: nil)
    }

    @objc private func linkLabelTapped() {
        if let websiteURL = linkLabel.text, !websiteURL.isEmpty,
           let url = URL(string: websiteURL) {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true, completion: nil)
        }
    }
}

// MARK: - UITableViewDataSource
extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTexts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let chevronImageView = createChevronImageView()
        cell.accessoryView = chevronImageView
        cell.textLabel?.text = cellTexts[indexPath.row]
        if indexPath.row == 0 {
            if let count = nftCount {
                cell.textLabel?.text = "\(cellTexts[indexPath.row]) (\(count))"
            } else {
                cell.textLabel?.text = "\(cellTexts[indexPath.row])"
            }
        } else {
            cell.textLabel?.text = cellTexts[indexPath.row]
        }
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            // "Мои NFT"
            let myNFTViewController = MyNFTViewController()
            navigationController?.pushViewController(myNFTViewController, animated: true)
        case 1:
            // "Избранные NFT"
            let favoriteViewController = FavoriteViewController()
            navigationController?.pushViewController(favoriteViewController, animated: true)
        case 2:
            // "О разработчике"
            linkLabelTapped()
        default:
            break
        }
    }
}
