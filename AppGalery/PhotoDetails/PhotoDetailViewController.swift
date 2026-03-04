//
//  PhotoDetailViewController.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 17.02.26.
//

import UIKit

final class PhotoDetailViewController: UIViewController {

    private let viewModel: PhotoDetailViewModel
    private let imageLoader: ImageLoaderProtocol

    private enum Constants {
        static let infoCornerRadius: CGFloat = 12
        static let sideInset: CGFloat = 16
        static let infoTopInset: CGFloat = 16
        static let textSpacing: CGFloat = 8
        static let imageHeightMultiplier: CGFloat = 0.5
        static let favoriteButtonSize: CGFloat = 44
    }

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 4
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemBackground
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = Constants.infoCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let authorLabel = UILabel()

    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.tintColor = .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(viewModel: PhotoDetailViewModel, imageLoader: ImageLoaderProtocol) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.detailsTitle
        setupUI()
        setupBindings()
        viewModel.start()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        scrollView.delegate = self

        view.addSubview(scrollView)
        scrollView.addSubview(imageView)

        view.addSubview(infoView)
        view.addSubview(favoriteButton)

        [titleLabel, descriptionLabel, authorLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.numberOfLines = 0
            infoView.addSubview($0)
        }

        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: Constants.imageHeightMultiplier),

            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),

            infoView.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: Constants.infoTopInset),
            infoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideInset),
            infoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideInset),

            titleLabel.topAnchor.constraint(equalTo: infoView.topAnchor, constant: Constants.sideInset),
            titleLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: Constants.sideInset),
            titleLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -Constants.sideInset),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.textSpacing),
            descriptionLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: Constants.sideInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -Constants.sideInset),

            authorLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: Constants.textSpacing),
            authorLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: Constants.sideInset),
            authorLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -Constants.sideInset),
            authorLabel.bottomAnchor.constraint(equalTo: infoView.bottomAnchor, constant: -Constants.sideInset),

            favoriteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideInset),
            favoriteButton.bottomAnchor.constraint(equalTo: infoView.topAnchor, constant: -Constants.sideInset),
            favoriteButton.widthAnchor.constraint(equalToConstant: Constants.favoriteButtonSize),
            favoriteButton.heightAnchor.constraint(equalToConstant: Constants.favoriteButtonSize)
        ])

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right

        scrollView.addGestureRecognizer(swipeLeft)
        scrollView.addGestureRecognizer(swipeRight)
    }

    private func setupBindings() {
        viewModel.didUpdatePhoto = { [weak self] photo, details, isFav in
            guard let self else { return }

            self.scrollView.setZoomScale(1, animated: false)
            self.scrollView.contentOffset = .zero

            let updateUI = {
                self.titleLabel.text = details.title
                self.descriptionLabel.text = details.description
                self.authorLabel.text = L10n.authorLine(details.author, details.createdAt)
                self.favoriteButton.isSelected = isFav

                if let url = URL(string: photo.urls.regular) {
                    self.imageLoader.load(url: url, into: self.imageView)
                } else {
                    self.imageView.image = nil
                }
            }

            UIView.transition(with: self.imageView, duration: 0.25, options: .transitionCrossDissolve, animations: updateUI)
        }

        viewModel.didUpdateFavoriteStatus = { [weak self] isFav in
            self?.favoriteButton.isSelected = isFav
        }
    }

    @objc private func favoriteTapped() {
        viewModel.toggleFavorite()
    }

    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            viewModel.nextPhoto()
        case .right:
            viewModel.previousPhoto()
        default:
            break
        }
    }
}

extension PhotoDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }
}
