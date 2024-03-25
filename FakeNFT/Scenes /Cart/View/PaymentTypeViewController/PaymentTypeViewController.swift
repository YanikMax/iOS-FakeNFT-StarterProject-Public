import UIKit
import ProgressHUD

final class PaymentTypeViewController: UIViewController, PaymentTypeViewControllerProtocol {

    // MARK: - Stored Properties

    private let params = GeometricParams(cellCount: 2, cellHeight: 46, cellSpacing: 7, lineSpacing: 7)
    private var selectedCell: String?
    private var presenter: PaymentPresenterProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    weak var delegate: PaymentTypeViewControllerDelegate?

    // MARK: - Computed Properties

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(PaymentTypeCollectionViewCell.self,
                                forCellWithReuseIdentifier: PaymentTypeCollectionViewCell.reuseIdentifier)
        collectionView.backgroundColor = .nftWhite
        collectionView.isUserInteractionEnabled = true
        collectionView.isScrollEnabled = false
        collectionView.allowsMultipleSelection = false
        collectionView.accessibilityIdentifier = "cartCollection"

        return collectionView
    }()

    private lazy var paymentLayerView: UIView = {
        let view = UIView()
        view.backgroundColor = .nftLightGray
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        return view
    }()

    private lazy var paymentButton: UIButton = {
        let button = UIButton()
        button.setTitle(LocalizedStrings.paymentButtonText, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.setTitleColor(.nftWhite, for: .normal)
        button.backgroundColor = .nftBlack
        button.layer.cornerRadius = 16
        button.addTarget(nil, action: #selector(paymentButtonDidTap), for: .touchUpInside)

        return button
    }()

    private lazy var informationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .nftBlack
        label.textAlignment = .left
        label.text = LocalizedStrings.informationLabelText

        return label
    }()

    private lazy var webViewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .nftBlueUniversal
        label.textAlignment = .left
        label.text = LocalizedStrings.webViewLabelText

        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(webViewLabelTapped))
        label.addGestureRecognizer(tapGesture)

        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .nftWhite

        collectionView.dataSource = self
        collectionView.delegate = self

        presenter = PaymentPresenter(paymentViewController: self)
        alertPresenter = CartAlertPresenter(delegate: self)
        presenter?.fetchCurrencies()

        addSubviews()
        constraintsSetup()
        navBarSetup()
    }

    // MARK: - Private methods

    private func navBarSetup() {
        if (navigationController?.navigationBar) != nil {
            title = LocalizedStrings.topTitleText

            let backButton = UIButton(type: .custom)
            backButton.setImage(UIImage(named: "chevronBackward"), for: .normal)
            backButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
            backButton.accessibilityIdentifier = "backButton"

            let imageBarButtonItem = UIBarButtonItem(customView: backButton)
            self.navigationItem.leftBarButtonItem = imageBarButtonItem
        }
    }

    private func addSubviews() {
        [paymentLayerView,
         collectionView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        [paymentButton,
         informationLabel,
         webViewLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            paymentLayerView.addSubview($0)
        }
    }

    private func constraintsSetup() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.heightAnchor.constraint(equalToConstant: 205),

            paymentLayerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            paymentLayerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            paymentLayerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            paymentLayerView.heightAnchor.constraint(equalToConstant: 186),

            paymentButton.leadingAnchor.constraint(equalTo: paymentLayerView.leadingAnchor, constant: 16),
            paymentButton.trailingAnchor.constraint(equalTo: paymentLayerView.trailingAnchor, constant: -16),
            paymentButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            paymentButton.heightAnchor.constraint(equalToConstant: 60),

            informationLabel.leadingAnchor.constraint(equalTo: paymentLayerView.leadingAnchor, constant: 16),
            informationLabel.trailingAnchor.constraint(equalTo: paymentLayerView.trailingAnchor, constant: -16),
            informationLabel.topAnchor.constraint(equalTo: paymentLayerView.topAnchor, constant: 16),
            informationLabel.heightAnchor.constraint(equalToConstant: 18),

            webViewLabel.leadingAnchor.constraint(equalTo: informationLabel.leadingAnchor),
            webViewLabel.trailingAnchor.constraint(equalTo: informationLabel.trailingAnchor),
            webViewLabel.topAnchor.constraint(equalTo: informationLabel.bottomAnchor, constant: 0),
            webViewLabel.heightAnchor.constraint(equalToConstant: 26)
        ])
    }

    // MARK: - Public methods

    func collectionViewUpdate() {
        self.collectionView.reloadData()
    }

    func setLoaderIsHidden(_ isHidden: Bool) {
        if isHidden {
            ProgressHUD.hideCustomLoader()
        } else {
            ProgressHUD.showCustomLoader()
        }
    }

    func showPaymentAlert(with error: String) {
        let model = CartAlertModel(
            title: LocalizedStrings.paymentErrorAlertTitleText,
            message: error,
            firstButtonText: LocalizedStrings.alertRetryButtonText,
            secondButtontext: LocalizedStrings.alertCancelButtonText,
            firstCompletion: { [weak self] in
                guard let self else { return }
                self.presenter?.fetchCurrencies()
            }
        )
        alertPresenter?.showCartAlert(with: model)
    }

    // MARK: - Handlers

    @objc func backButtonDidTap() {
        self.navigationController?.popToRootViewController(animated: true)
    }

    @objc func paymentButtonDidTap() {
        if selectedCell != nil {
            delegate?.cleanCart()
            let viewController = SuccessPaymentViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
            tabBarController?.tabBar.isHidden = true
        } else {
            let alert = UIAlertController(title: nil,
                                          message: LocalizedStrings.alertMessageText,
                                          preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: LocalizedStrings.alertCancelButtonText,
                                             style: .cancel)
            let retryAction = UIAlertAction(title: LocalizedStrings.alertRetryButtonText,
                                            style: .default) { _ in
                self.dismiss(animated: true)
            }

            alert.addAction(cancelAction)
            alert.addAction(retryAction)

            self.present(alert, animated: true, completion: nil)
        }
    }

    @objc func webViewLabelTapped() {
        guard let url = URL(string: "https://yandex.ru/legal/practicum_termsofuse/") else { return }

        let viewController = WebViewController(url: url)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension PaymentTypeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let presenter else { return .zero }
        return presenter.currencyArray.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PaymentTypeCollectionViewCell.reuseIdentifier,
            for: indexPath) as? PaymentTypeCollectionViewCell
        else {
            return UICollectionViewCell()
        }

        if let presenter {
            let currencyName = presenter.currencyArray[indexPath.item].title
            let shortCurrencyName = presenter.currencyArray[indexPath.item].id

            cell.configureCell(fullName: currencyName, shortName: shortCurrencyName)
            cell.updateCellImage(at: indexPath, with: presenter)
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PaymentTypeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth = availableWidth / CGFloat(params.cellCount)

        return CGSize(width: cellWidth, height: params.cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return params.lineSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }
}

// MARK: - UICollectionViewDelegate

extension PaymentTypeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCell = presenter?.currencyArray[indexPath.item].title
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedCell = nil
    }
}
