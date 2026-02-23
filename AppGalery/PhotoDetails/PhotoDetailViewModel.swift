//
//  PhotoDetailViewModel.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 17.02.26.
//

import Foundation

@MainActor
final class PhotoDetailViewModel {
    
    private let photos: [Photo]
    private var currentIndex: Int
    private let favoritesManager = FavoritesManager.shared
    
    var didUpdatePhoto: (() -> Void)?
    var didUpdateFavoriteStatus: ((Bool) -> Void)?
    
    var currentPhoto: Photo { photos[currentIndex] }
    
    var photoDetails: PhotoDetail {
        let photo = currentPhoto
        return PhotoDetail(
            title: photo.altDescription ?? "Без названия",
            description: photo.description ?? "Нет описания",
            author: photo.user.name,
            createdAt: formatDate(photo.createdAt ?? "")
        )
    }
    
    var isFavorite: Bool { favoritesManager.isFavorite(currentPhoto.id) }
    
    init(photos: [Photo], initialIndex: Int) {
        self.photos = photos
        self.currentIndex = initialIndex
    }
    
    func toggleFavorite() {
        favoritesManager.toggleFavorite(currentPhoto.id)
        didUpdateFavoriteStatus?(isFavorite)
    }
    
    func nextPhoto() -> Bool {
        guard currentIndex < photos.count - 1 else { return false }
        currentIndex += 1
        didUpdatePhoto?()
        return true
    }
    
    func previousPhoto() -> Bool {
        guard currentIndex > 0 else { return false }
        currentIndex -= 1
        didUpdatePhoto?()
        return true
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return "Дата неизвестна" }
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.locale = Locale(identifier: "ru_RU")
        return displayFormatter.string(from: date)
    }
}

