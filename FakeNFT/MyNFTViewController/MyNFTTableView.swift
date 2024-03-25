import UIKit

final class MyNFTTableViewCell: UITableViewCell {
    var presenter: MyNFTPresenter?

    private lazy var nftStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading
        stackView.spacing = 4
        return stackView
    }()

    private lazy var nftImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private lazy var nftName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .textPrimary
        return label
    }()

    private lazy var nftRating: NFTRatingController = {
        let nftRating = NFTRatingController(starsRating: 5)
        nftRating.spacing = 2
        nftRating.translatesAutoresizingMaskIntoConstraints = false
        return nftRating
    }()

    private lazy var nftAuthor: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .textPrimary
        return label
    }()

    private lazy var nftPriceStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading
        stackView.spacing = 2
        return stackView
    }()

    private lazy var nftPriceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .textPrimary
        label.text = "Цена"
        return label
    }()

    private lazy var nftPriceValue: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .textPrimary
        label.text = "0 ETH"
        label.numberOfLines = 0
        return label
    }()

    private lazy var nftFavorite: FavouriteButton = {
        let button = FavouriteButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "like"
        button.addTarget(self, action: #selector(self.didTapFavoriteButton(sender:)), for: .touchUpInside)
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {

        [nftImage, nftFavorite, nftStack, nftPriceStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        [nftName, nftRating, nftAuthor].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            nftStack.addArrangedSubview($0)
        }

        [nftPriceLabel, nftPriceValue].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            nftPriceStack.addArrangedSubview($0)
        }
        NSLayoutConstraint.activate([
            nftImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            nftImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            nftImage.heightAnchor.constraint(equalToConstant: 108),
            nftImage.widthAnchor.constraint(equalToConstant: 108),

            nftFavorite.topAnchor.constraint(equalTo: nftImage.topAnchor),
            nftFavorite.trailingAnchor.constraint(equalTo: nftImage.trailingAnchor),
            nftFavorite.heightAnchor.constraint(equalToConstant: 42),
            nftFavorite.widthAnchor.constraint(equalToConstant: 42),

            nftStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            nftStack.leadingAnchor.constraint(equalTo: nftImage.trailingAnchor, constant: 20),
            nftStack.widthAnchor.constraint(equalToConstant: 117),
            nftRating.heightAnchor.constraint(equalToConstant: 12),

            nftPriceStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            nftPriceStack.leadingAnchor.constraint(equalTo: nftStack.trailingAnchor),
            nftPriceStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -39)
        ])
    }

    func configureCell(with model: MyNFTViewModel) {
        if let firstImageURL = model.images?.first, let url = URL(string: firstImageURL.absoluteString) {
            nftImage.kf.setImage(with: url)
        } else {
            nftImage.image = UIImage(named: "NFTcard")
        }
        nftName.text = model.name
        nftRating.setStarsRating(rating: model.rating)
        nftAuthor.text = "от \(model.author)"
        nftPriceValue.text = "\(model.price) ETH"
        nftFavorite.isFavorite = model.isFavorite ?? false
        nftFavorite.nftID = model.id
    }

    @objc private func didTapFavoriteButton(sender: FavouriteButton) {
        sender.isFavorite.toggle()

        if let presenter = presenter, let nftID = sender.nftID {
            presenter.toggleLike(for: nftID)
        }
    }
}
