import UIKit

final class FavoriteNFTCell: UICollectionViewCell {
    // MARK: - Public Properties
    var presenter: FavoriteNFTPresenter?

    // MARK: - Private Properties
    private lazy var nftImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private lazy var nftStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading
        stackView.spacing = 4
        stackView.backgroundColor = .white
        return stackView
    }()

    private lazy var nftName: UILabel = {
        let label = UILabel()
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

    private lazy var nftPriceValue: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .textPrimary
        label.text = "0 ETH"
        let attributedString = NSMutableAttributedString(string: label.text ?? "")
        attributedString.addAttribute(NSAttributedString.Key.kern,
                                      value: -0.24,
                                      range: NSRange(location: 0, length: attributedString.length))
        label.attributedText = attributedString
        return label
    }()

    private lazy var nftFavorite: FavouriteButton = {
        let favoriteButton = FavouriteButton()
        favoriteButton.addTarget(self, action: #selector(self.didTapFavoriteButton(sender:)), for: .touchUpInside)
        return favoriteButton
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods
    func configureCell(with model: FavoriteNFTViewModel) {
        if let firstImageURL = model.images?.first, let url = URL(string: firstImageURL.absoluteString) {
            nftImage.kf.setImage(with: url)
        } else {
            nftImage.image = UIImage(named: "NFTcard")
        }
        nftName.text = model.name
        nftRating.setStarsRating(rating: model.rating)
        nftPriceValue.text = "\(model.price) ETH"
        nftFavorite.isFavorite = model.isFavorite ?? false
        nftFavorite.nftID = model.id
    }

    // MARK: - Private Methods
    private func setupConstraints() {
        [nftImage, nftFavorite, nftStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        [nftName, nftRating, nftPriceValue].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            nftStack.addArrangedSubview($0)
        }

        NSLayoutConstraint.activate([
            nftImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            nftImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            nftImage.heightAnchor.constraint(equalToConstant: 80),
            nftImage.widthAnchor.constraint(equalToConstant: 80),

            nftFavorite.topAnchor.constraint(equalTo: nftImage.topAnchor, constant: -6),
            nftFavorite.trailingAnchor.constraint(equalTo: nftImage.trailingAnchor, constant: 6),
            nftFavorite.heightAnchor.constraint(equalToConstant: 42),
            nftFavorite.widthAnchor.constraint(equalToConstant: 42),

            nftStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            nftStack.leadingAnchor.constraint(equalTo: nftImage.trailingAnchor, constant: 12),
            nftStack.widthAnchor.constraint(equalToConstant: 92),

            nftRating.heightAnchor.constraint(equalToConstant: 12)
        ])
    }

    @objc
    private func didTapFavoriteButton(sender: FavouriteButton) {
        sender.isFavorite.toggle()
        if let presenter = presenter, let nftID = sender.nftID {
            presenter.toggleLike(for: nftID)
        }
    }
}
