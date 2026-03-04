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
    private let favoritesStore: FavoritesProtocol

    var didUpdatePhoto: ((Photo, PhotoDetail, Bool) -> Void)?
    var didUpdateFavoriteStatus: ((Bool) -> Void)?

    init(photos: [Photo], initialIndex: Int, favoritesStore: FavoritesProtocol) {
        self.photos = photos
        self.currentIndex = initialIndex
        self.favoritesStore = favoritesStore
    }

    func start() {
        sendCurrent()
    }

    func toggleFavorite() {
        let photo = photos[currentIndex]
        favoritesStore.toggle(photo: photo)
        didUpdateFavoriteStatus?(favoritesStore.isFavorite(photo.id))
    }

    func nextPhoto() {
        guard currentIndex < photos.count - 1 else { return }
        currentIndex += 1
        sendCurrent()
    }

    func previousPhoto() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        sendCurrent()
    }

    private func sendCurrent() {
        let photo = photos[currentIndex]
        let details = PhotoDetail(
            title: photo.altDescription ?? L10n.detailsNoTitle,
            description: photo.description ?? L10n.detailsNoDescription,
            author: photo.user.name,
            createdAt: formatDate(photo.createdAt)
        )

        let isFav = favoritesStore.isFavorite(photo.id)
        didUpdatePhoto?(photo, details, isFav)
    }

    private func formatDate(_ dateString: String?) -> String {
        guard let dateString, !dateString.isEmpty else { return L10n.detailsUnknownDate }

        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return L10n.detailsUnknownDate }

        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.locale = Locale(identifier: "ru_RU")
        return displayFormatter.string(from: date)
    }
}
