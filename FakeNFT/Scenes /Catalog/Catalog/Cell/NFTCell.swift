//
//  CollectionCell.swift
//  FakeNFT
//
//  Created by Ян Максимов on 07.01.2024.
//

import UIKit
import Kingfisher

protocol NFTCellDelegate: AnyObject {
    func didTapLikeButton(_ id: String)
    func didTapCartButton(_ id: String)
}

final class NFTCell: UICollectionViewCell, ReuseIdentifying {

    // MARK: - Constants
    private enum Constants {
        static let starIcon = "Star"
        static let starFilledIcon = "StarYellow"
        static let favouriteIcon = "HeartRed"
        static let favouriteDefaultIcon = "Heart"
        static let cartIcon = "Cart"
        static let cartDeleteIcon = "CartDelete"
    }

    // MARK: - Public Properties
    weak var delegate: NFTCellDelegate?

    var isLikedNFT: Bool = false {
        didSet {
            updateLikedButton()
        }
    }

    var isAddedToCart: Bool = false {
        didSet {
            updateCartButton()
        }
    }

    var viewModel: NFTInformation? {
        didSet {
            guard let viewModel = viewModel else { return }
            setupViewModel(viewModel: viewModel)
        }
    }

    // MARK: - Private Properties
    private var stars: [UIImageView] = []

    private lazy var nftImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.heightAnchor.constraint(equalTo: image.widthAnchor, multiplier: 1).isActive = true
        image.layer.cornerRadius = 12
        image.layer.masksToBounds = true
        return image
    }()

    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "likeButton"
        button.addTarget(self, action: #selector(addToFavourites), for: .touchUpInside)
        button.accessibilityLabel = "Add to Favourites"
        return button
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .bodyBold
        label.numberOfLines = 2
        return label
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .caption3
        return label
    }()

    private lazy var cartButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addToCart), for: .touchUpInside)
        button.tintColor = .black
        button.accessibilityLabel = "Add to Cart"
        return button
    }()

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Private Methods
    private func setupView() {
        backgroundColor = .white
        addSubviews()
        updateLikedButton()
        updateCartButton()
        self.accessibilityIdentifier = "NFTCell"
    }

    private func addSubviews() {
        createStars()

        let nameAndPriceStack = createStackView(axis: .vertical,
                                                alignment: .leading,
                                                distribution: .fillProportionally,
                                                spacing: 4)
        addArrangedSubviews(stackView: nameAndPriceStack, views: [nameLabel, priceLabel])

        let infoAndCartStack = createStackView(axis: .horizontal,
                                               alignment: .top,
                                               distribution: .fill,
                                               spacing: 0)
        addArrangedSubviews(stackView: infoAndCartStack, views: [nameAndPriceStack, cartButton])

        let starsStack = createStackView(axis: .horizontal,
                                         alignment: .fill,
                                         distribution: .fill,
                                         spacing: 2)
        addArrangedSubviews(stackView: starsStack, views: stars + [UIView()])

        let starsAndInfoStack = createStackView(axis: .vertical,
                                                alignment: .fill,
                                                distribution: .fill,
                                                spacing: 4)
        addArrangedSubviews(stackView: starsAndInfoStack, views: [starsStack, infoAndCartStack])

        let mainStack = createStackView(axis: .vertical,
                                        alignment: .fill,
                                        distribution: .fill,
                                        spacing: 8)
        addArrangedSubviews(stackView: mainStack, views: [nftImage, starsAndInfoStack])

        addSubview(mainStack)
        addSubview(likeButton)

        NSLayoutConstraint.activate([
            likeButton.topAnchor.constraint(equalTo: nftImage.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: nftImage.trailingAnchor),

            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func createStackView(axis: NSLayoutConstraint.Axis,
                                 alignment: UIStackView.Alignment,
                                 distribution: UIStackView.Distribution,
                                 spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.spacing = spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    private func addArrangedSubviews(stackView: UIStackView, views: [UIView]) {
        for view in views {
            stackView.addArrangedSubview(view)
        }
    }

    private func createStars() {
        stars = (1...5).map { _ in createStarIcon() }
    }

    private func createStarIcon() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Constants.starIcon)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    private func updateLikedButton() {
        let imageName = isLikedNFT ? Constants.favouriteIcon : Constants.favouriteDefaultIcon
        likeButton.setImage(UIImage(named: imageName), for: .normal)
    }

    private func updateCartButton() {
        let imageName = isAddedToCart ? Constants.cartDeleteIcon : Constants.cartIcon
        cartButton.setImage(UIImage(named: imageName), for: .normal)
    }

    private func setupViewModel(viewModel: NFTInformation) {
        DispatchQueue.main.async {
            self.nftImage.kf.indicatorType = .activity
            self.nftImage.kf.setImage(with: viewModel.image)
            self.nameLabel.text = viewModel.name
            self.priceLabel.text = "\(viewModel.price) ETH"
            self.setRating(viewModel.rating)
        }
    }

    private func setRating(_ rating: Int) {
        stars.forEach { $0.image = UIImage(named: Constants.starIcon) }
        for index in 0..<min(rating, stars.count) {
            stars[index].image = UIImage(named: Constants.starFilledIcon)
        }
    }

    @objc private func addToFavourites() {
        guard let viewModel = viewModel else { return }
        isLikedNFT.toggle()
        delegate?.didTapLikeButton(viewModel.id)
    }

    @objc private func addToCart() {
        guard let viewModel = viewModel else { return }
        isAddedToCart.toggle()
        delegate?.didTapCartButton(viewModel.id)

        if isAddedToCart == false {
            NotificationCenter.default.post(name: .catalogItemRemoved, object: nil)
        }
    }
}
