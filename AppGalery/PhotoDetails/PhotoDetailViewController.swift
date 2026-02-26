//
//  PhotoDetailViewController.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 17.02.26.
//

import UIKit

final class PhotoDetailViewController: UIViewController {
    
    private let viewModel: PhotoDetailViewModel
    
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
        let infoView = UIView()
        infoView.backgroundColor = .secondarySystemBackground
        infoView.layer.cornerRadius = 12
        infoView.translatesAutoresizingMaskIntoConstraints = false
        return infoView
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
    
    init(viewModel: PhotoDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        configurePhoto(animated: false)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Детали"
        
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
            scrollView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            infoView.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 16),
            infoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            infoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: infoView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -16),
            
            authorLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 16),
            authorLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -16),
            authorLabel.bottomAnchor.constraint(equalTo: infoView.bottomAnchor, constant: -16),
            
            favoriteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            favoriteButton.bottomAnchor.constraint(equalTo: infoView.topAnchor, constant: -16),
            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        scrollView.addGestureRecognizer(swipeLeft)
        scrollView.addGestureRecognizer(swipeRight)
    }
    
    private func setupBindings() {
        viewModel.didUpdatePhoto = { [weak self] in
            self?.scrollView.setZoomScale(1, animated: false)
            self?.scrollView.contentOffset = .zero
            self?.configurePhoto(animated: true)
        }
        viewModel.didUpdateFavoriteStatus = { [weak self] isFav in
            self?.favoriteButton.isSelected = isFav
        }
    }
    
    private func configurePhoto(animated: Bool) {
        let details = viewModel.photoDetails
        let updateUI = {
            self.titleLabel.text = details.title
            self.descriptionLabel.text = details.description
            self.authorLabel.text = "Автор: \(details.author) • \(details.createdAt)"
            self.favoriteButton.isSelected = self.viewModel.isFavorite
            if let url = URL(string: self.viewModel.currentPhoto.urls.regular) {
                self.imageView.loadImage(from: url)
            }
        }
        if animated {
            UIView.transition(with: imageView, duration: 0.3, options: .transitionCrossDissolve, animations: updateUI)
        } else { updateUI() }
    }
    
    @objc private func favoriteTapped() { viewModel.toggleFavorite() }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left { _ = viewModel.nextPhoto() }
        else if gesture.direction == .right { _ = viewModel.previousPhoto() }
    }
}

extension PhotoDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }
}
