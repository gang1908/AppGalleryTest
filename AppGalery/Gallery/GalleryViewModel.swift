//
//  GalleryViewModel.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 17.02.26.
//

import Foundation

@MainActor
final class GalleryViewModel {

    private let service: APIServiceProtocol
    private let favoritesStore: FavoritesProtocol

    private(set) var photos: [Photo] = []

    var didStartLoading: (() -> Void)?
    var didUpdate: (() -> Void)?
    var didFail: ((String) -> Void)?

    private var page = 1
    private var isLoading = false

    init(service: APIServiceProtocol, favoritesStore: FavoritesProtocol) {
        self.service = service
        self.favoritesStore = favoritesStore
    }

    var numberOfItems: Int { photos.count }

    func photo(at index: Int) -> Photo? {
        guard photos.indices.contains(index) else { return nil }
        return photos[index]
    }

    func isFavorite(photoId: String) -> Bool {
        favoritesStore.isFavorite(photoId)
    }

    func toggleFavorite(photo: Photo) {
        favoritesStore.toggle(photo: photo)
        didUpdate?()
    }

    func loadNextPage() {
        guard !isLoading else { return }

        isLoading = true
        didStartLoading?()

        service.fetchPhotos(page: page) { [weak self] result in
            guard let self else { return }

            Task { @MainActor in
                self.isLoading = false

                switch result {
                case .success(let newPhotos):
                    self.photos.append(contentsOf: newPhotos)
                    self.page += 1
                    self.didUpdate?()

                case .failure(let error):
                    self.didFail?(error.localizedDescription)
                }
            }
        }
    }

    func refresh() {
        guard !isLoading else { return }
        page = 1
        photos = []
        loadNextPage()
    }
}
