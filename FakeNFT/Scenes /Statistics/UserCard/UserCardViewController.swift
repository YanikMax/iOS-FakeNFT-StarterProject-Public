//
//  UserCard.swift
//  FakeNFT
//
//  Created by Андрей Асланов on 12.12.23.
//

protocol UserCardViewInput: AnyObject {
    func updateUI(avatarURL: String, username: String, description: String)
}

import UIKit

final class UserCardViewController: UIViewController, UserCardViewInput {
    private var presenter: UserCardViewOutput?

    init(user: StatisticsUserModel) {
        super.init(nibName: nil, bundle: nil)
        self.presenter = UserCardPresenter(user: user, view: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .lightGray
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.caption2
        label.numberOfLines = 0
        return label
    }()

    private let websiteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Перейти на сайт пользователя", for: .normal)
        button.titleLabel?.font = UIFont.caption1
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(websiteButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var nftButton: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8

        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = .black

        let arrowImage = UIImage(systemName: "chevron.right",
                                 withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold))
        let tintedImage = arrowImage?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: tintedImage)
        imageView.tintColor = .black

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(imageView)

        let nftCount = presenter?.getUserInfo().nftCount ?? "0"
        titleLabel.text = "Коллекция NFT (\(nftCount))"

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(nftButtonTapped))
        stackView.addGestureRecognizer(tapGesture)

        return stackView
    }()

    private lazy var backBarButtonItem: UIBarButtonItem = {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
                                         style: .plain, target: self,
                                         action: #selector(leftBarButtonItemTapped))
        backButton.tintColor = .black
        return backButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupUI()
        setupConstraints()
        navigationItem.leftBarButtonItem = backBarButtonItem
    }

    private func setupUI() {
        [avatarImageView, nameLabel, descriptionLabel, websiteButton, nftButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        presenter?.updateUI()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 29),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),

            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            websiteButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 28),
            websiteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            websiteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            websiteButton.heightAnchor.constraint(equalToConstant: 40),

            nftButton.topAnchor.constraint(equalTo: websiteButton.bottomAnchor, constant: 40),
            nftButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nftButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nftButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    func updateUI(avatarURL: String, username: String, description: String) {
        if let avatarURL = URL(string: avatarURL) {
            avatarImageView.kf.setImage(with: avatarURL, placeholder: UIImage(named: "placeholder"))
        } else {
            avatarImageView.image = UIImage(named: "placeholder")
        }

        nameLabel.text = username
        descriptionLabel.text = description
    }

    @objc private func websiteButtonTapped() {
        if let websiteString = presenter?.getUserInfo().website, let websiteURL = URL(string: websiteString) {
            let webViewController = StatisticsWebViewController()
            webViewController.url = websiteURL
            navigationController?.pushViewController(webViewController, animated: true)
        } else {
            print("Invalid website URL")
        }
    }

    @objc private func nftButtonTapped() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.nftButton.alpha = 0.5
        }) { [weak self] _ in
            UIView.animate(withDuration: 0.2) {
                self?.nftButton.alpha = 1.0
            }

            if let userId = self?.presenter?.getUserId(), let nftArray = self?.presenter?.getNfts() {
                let userNftCollectionVC = UserNftCollectionViewController(userId: userId, nftArray: nftArray)
                self?.navigationController?.pushViewController(userNftCollectionVC, animated: true)
            }
        }
    }

    @objc private func leftBarButtonItemTapped() {
        navigationController?.popViewController(animated: true)
    }
}
