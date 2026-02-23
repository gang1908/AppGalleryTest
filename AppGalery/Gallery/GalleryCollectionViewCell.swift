//
//  GalleryCollectionViewCell.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 17.02.26.
//

import UIKit

final class GalleryCollectionViewCell: UICollectionViewCell {
    static let identifier = "GalleryCollectionViewCell"
    
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

            favoriteIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            favoriteIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            favoriteIndicator.widthAnchor.constraint(equalToConstant: 20),
            favoriteIndicator.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with photo: Photo, isFavorite: Bool) {
        favoriteIndicator.isHidden = !isFavorite
        if let url = URL(string: photo.urls.thumb) {
            imageView.loadImage(from: url)
        }
    }
    
    func updateFavorite(isFavorite: Bool) {
        favoriteIndicator.isHidden = !isFavorite
        
        if isFavorite {
            UIView.animate(withDuration: 0.2, animations: {
                self.favoriteIndicator.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    self.favoriteIndicator.transform = .identity
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        favoriteIndicator.isHidden = true
    }
}

