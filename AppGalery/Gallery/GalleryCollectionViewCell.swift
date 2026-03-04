//
//  GalleryCollectionViewCell.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 17.02.26.
//

import UIKit

final class GalleryCollectionViewCell: UICollectionViewCell {

    static let identifier = "GalleryCollectionViewCell"

    private enum Constants {
        static let heartInset: CGFloat = 8
        static let heartSize: CGFloat = 20
    }

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let favoriteIndicator: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "heart.fill")
        imageView.tintColor = .systemRed
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(imageView)
        contentView.addSubview(favoriteIndicator)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            favoriteIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.heartInset),
            favoriteIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.heartInset),
            favoriteIndicator.widthAnchor.constraint(equalToConstant: Constants.heartSize),
            favoriteIndicator.heightAnchor.constraint(equalToConstant: Constants.heartSize)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with photo: Photo, isFavorite: Bool, imageLoader: ImageLoaderProtocol) {
        favoriteIndicator.isHidden = !isFavorite

        if let url = URL(string: photo.urls.thumb) {
            imageLoader.load(url: url, into: imageView)
        } else {
            imageView.image = nil
        }
    }

    func configure(with item: FavoritePhotoItem, imageLoader: ImageLoaderProtocol) {
        favoriteIndicator.isHidden = false

        if let urlString = item.thumbURL, let url = URL(string: urlString) {
            imageLoader.load(url: url, into: imageView)
        } else {
            imageView.image = nil
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        favoriteIndicator.isHidden = true
        favoriteIndicator.transform = .identity
    }
}
