import UIKit
import ProgressHUD

final class ProfileEditViewController: UIViewController, ProfilePresenter {

    // MARK: - Public Properties
    var currentUser: Profile?
    var avatarImageURL: URL?
    var onProfileUpdate: ((String, String, String) -> Void)?
    var presenter: ProfilePresenterImpl?
    // MARK: - Private Properties
    private lazy var exitButton: UIBarButtonItem = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let closeImage = UIImage(named: "closeButton")
        button.accessibilityIdentifier = "exitButton"
        button.setImage(closeImage, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: button)
        return barButtonItem
    }()

    private lazy var changeAvatar: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "avatar")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var editProfileLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor(named: "NFTBackgroundUniversal")?.withAlphaComponent(0.6)
        label.text = "Сменить фото"
        label.textAlignment = .center
        label.textColor = UIColor(named: "NFTWhite")
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label.layer.cornerRadius = 35
        label.layer.masksToBounds = true
        label.numberOfLines = 0
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(profileImageEdit(_:)))
        label.addGestureRecognizer(tapAction)
        label.isUserInteractionEnabled = true
        return label
    }()

    private lazy var name: UILabel = {
        let label = UILabel()
        label.text = "Имя"
        label.textColor = .textPrimary
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var nameDescription: UITextView = {
        let textView = UITextView()
        textView.text = "Joaquin Phoenix"
        textView.textColor = .textPrimary
        textView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.cornerRadius = 12
        textView.layer.masksToBounds = true
        textView.backgroundColor = UIColor(named: "NFTLightGray")
        textView.textContainerInset = UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 16)
        return textView
    }()

    private lazy var descriptionUser: UILabel = {
        let label = UILabel()
        label.text = "Описание"
        label.textColor = .textPrimary
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var userDescription: UITextView = {
        let textView = UITextView()
        textView.text = "Дизайнер из Казани, люблю цифровое искусство и бейглы. В моей коллекции уже 100+ NFT, и еще больше — на моём сайте. Открыт к коллаборациям."
        textView.textColor = .textPrimary
        textView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.cornerRadius = 12
        textView.layer.masksToBounds = true
        textView.backgroundColor = UIColor(named: "NFTLightGray")
        textView.textContainerInset = UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 16)
        return textView
    }()

    private lazy var website: UILabel = {
        let label = UILabel()
        label.text = "Сайт"
        label.textColor = .textPrimary
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var userWebsite: UITextView = {
        let textView = UITextView()
        textView.text = "Joaquin Phoenix.com"
        textView.textColor = .textPrimary
        textView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.cornerRadius = 12
        textView.layer.masksToBounds = true
        textView.backgroundColor = UIColor(named: "NFTLightGray")
        textView.textContainerInset = UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 16)
        return textView
    }()

    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        presenter = ProfilePresenterImpl(view: self)
        setupUI()
        setupConstraints()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        navigationItem.rightBarButtonItem = exitButton

        nameDescription.text = currentUser?.name ?? ""
        userDescription.text = currentUser?.description ?? ""
        userWebsite.text = currentUser?.website ?? ""

        if let imageURL = avatarImageURL {
            changeAvatar.kf.setImage(with: imageURL)
        }
    }
    // MARK: - Public Methods
    func updateUser(user: Profile?) {
        DispatchQueue.main.async {
            if let currentUser = user {
                self.nameDescription.text = currentUser.name
                self.userDescription.text = currentUser.description
                self.userWebsite.text = currentUser.website
            }
        }
    }

    // MARK: - Private Methods
    private func setupUI() {
        view.addSubview(name)
        view.addSubview(nameDescription)
        view.addSubview(descriptionUser)
        view.addSubview(userDescription)
        view.addSubview(website)
        view.addSubview(userWebsite)
        view.addSubview(changeAvatar)
        view.addSubview(editProfileLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            name.widthAnchor.constraint(equalToConstant: 50),
            name.heightAnchor.constraint(equalToConstant: 28),
            name.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            name.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 174),

            nameDescription.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameDescription.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameDescription.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 8),
            nameDescription.heightAnchor.constraint(equalToConstant: 44),

            descriptionUser.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            descriptionUser.topAnchor.constraint(equalTo: nameDescription.bottomAnchor, constant: 24),
            descriptionUser.widthAnchor.constraint(equalToConstant: 117),
            descriptionUser.heightAnchor.constraint(equalToConstant: 28),

            userDescription.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            userDescription.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            userDescription.topAnchor.constraint(equalTo: descriptionUser.bottomAnchor, constant: 8),
            userDescription.heightAnchor.constraint(equalToConstant: 110),

            website.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            website.widthAnchor.constraint(equalToConstant: 57),
            website.heightAnchor.constraint(equalToConstant: 28),
            website.topAnchor.constraint(equalTo: userDescription.bottomAnchor, constant: 24),

            userWebsite.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            userWebsite.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            userWebsite.topAnchor.constraint(equalTo: website.bottomAnchor, constant: 8),
            userWebsite.heightAnchor.constraint(equalToConstant: 44),

            changeAvatar.heightAnchor.constraint(equalToConstant: 70),
            changeAvatar.widthAnchor.constraint(equalToConstant: 70),
            changeAvatar.bottomAnchor.constraint(equalTo: name.topAnchor, constant: -24),

            changeAvatar.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),

            editProfileLabel.heightAnchor.constraint(equalToConstant: 70),
            editProfileLabel.widthAnchor.constraint(equalToConstant: 70),
            editProfileLabel.bottomAnchor.constraint(equalTo: name.topAnchor, constant: -24),
            editProfileLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }

    private func updateProfile() {
        let updatedName = nameDescription.text ?? ""
        let updatedDescription = userDescription.text ?? ""
        let updatedWebsite = userWebsite.text ?? ""
        onProfileUpdate?(updatedName, updatedDescription, updatedWebsite)
    }

    private func createUpdatedProfile() -> Profile? {
        guard let updatedName = nameDescription.text,
              let updatedDescription = userDescription.text,
              let updatedWebsite = userWebsite.text,
              let userId = currentUser?.id,
              let likes = currentUser?.likes else {
            return nil
        }
        return Profile(name: updatedName,
                       description: updatedDescription,
                       website: updatedWebsite,
                       avatar: nil,
                       nfts: nil,
                       likes: likes,
                       id: userId)
    }

    @objc private func exitButtonTapped() {
        guard let updatedProfile = createUpdatedProfile() else {
            return
        }
        presenter?.updateProfileData(updatedProfile: updatedProfile) { [weak self ] result in
            switch result {
            case .success:
                self?.updateUser(user: updatedProfile)
            case .failure(let error):
                print("Ошибка при обновлении профиля на сервере:", error)
            }
            DispatchQueue.main.async {
                self?.updateUser(user: updatedProfile)
                self?.dismiss(animated: true, completion: nil)
            }
        }
        updateProfile()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func profileImageEdit(_ sender: UITapGestureRecognizer) {
        guard let currentAvatarURL = currentUser?.avatar else {
            return
        }
        print("Старая ссылка на аватар: \(currentAvatarURL)")
        // Имитация загрузки
        ProgressHUD.show()
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) { [weak self] in
            let randomString = String(Int(Date().timeIntervalSince1970))
            var components = URLComponents(string: currentAvatarURL)
            components?.path = "/avatars/\(randomString).jpg"
            guard let newAvatarURL = components?.url else {
                DispatchQueue.main.async {
                    ProgressHUD.dismiss()
                }
                return
            }
            DispatchQueue.main.async {
                print("Новая ссылка на аватар: \(newAvatarURL)")
                self?.changeAvatar.kf.setImage(with: newAvatarURL)
                ProgressHUD.dismiss()
            }
        }
    }
}
