import UIKit

final class ProfileEditViewController: UIViewController {
    var presenter: ProfilePresenter!
    
    private var exitButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let closeImage = UIImage(named: "closeButton")
        button.setImage(closeImage, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var changeAvatar: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "avatar")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var editProfileLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor(named: "NFTBackgroundUniversal")?.withAlphaComponent(0.6)
        label.text = "Сменить фото"
        label.textAlignment = .center
        label.textColor = UIColor(named:"NFTWhite")
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
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameDescription: UITextView = {
        let textView = UITextView()
        textView.text = "Joaquin Phoenix"
        textView.textColor = .black
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
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var userDescription: UITextView = {
        let textView = UITextView()
        textView.text = "Дизайнер из Казани, люблю цифровое искусство и бейглы. В моей коллекции уже 100+ NFT, и еще больше — на моём сайте. Открыт к коллаборациям."
        textView.textColor = .black
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
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var userWebsite: UITextView = {
        let textView = UITextView()
        textView.text = "Joaquin Phoenix.com"
        textView.textColor = .black
        textView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.cornerRadius = 12
        textView.layer.masksToBounds = true
        textView.backgroundColor = UIColor(named: "NFTLightGray")
        textView.textContainerInset = UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 16)
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        
        setupUI()
        setupConstraints()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        view.bringSubviewToFront(editProfileLabel)
    }
    
    private func setupUI() {
        view.addSubview(name)
        view.addSubview(nameDescription)
        view.addSubview(descriptionUser)
        view.addSubview(userDescription)
        view.addSubview(website)
        view.addSubview(userWebsite)
        view.addSubview(changeAvatar)
        view.addSubview(exitButton)
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
            
            exitButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exitButton.widthAnchor.constraint(equalToConstant: 42),
            exitButton.heightAnchor.constraint(equalToConstant: 42),
            
            changeAvatar.heightAnchor.constraint(equalToConstant: 70),
            changeAvatar.widthAnchor.constraint(equalToConstant: 70),
            changeAvatar.topAnchor.constraint(equalTo: view.topAnchor, constant: 94),
            changeAvatar.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            editProfileLabel.heightAnchor.constraint(equalToConstant: 70),
            editProfileLabel.widthAnchor.constraint(equalToConstant: 70),
            editProfileLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 94),
            editProfileLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            
        ])
        
    }
    
    @objc func exitButtonTapped() {
        presenter.updateProfile(name: nameDescription.text, bio: userDescription.text, link: userWebsite.text)
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func profileImageEdit(_ sender: UITapGestureRecognizer) {
        print("Image change")
    }
}
