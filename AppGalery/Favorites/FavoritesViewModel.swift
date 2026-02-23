//
//  FavoritesViewModel.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 17.02.26.
//

import Foundation

@MainActor
final class FavoritesViewModel {
    
    private var allPhotos: [Photo] = []
    private var favoritePhotos: [Photo] = []
    private let favoritesManager = FavoritesManager.shared
    
    var didUpdate: (() -> Void)?
    
    var numberOfItems: Int { favoritePhotos.count }
    
    func photo(at index: Int) -> Photo? {
        guard index >= 0 && index < favoritePhotos.count else { return nil }
        return favoritePhotos[index]
    }
    
    func isFavorite(photoId: String) -> Bool {
        favoritesManager.isFavorite(photoId)
    }
    
    func toggleFavorite(photoId: String) {
        favoritesManager.toggleFavorite(photoId)
        loadFavorites(from: allPhotos)
    }
    
    func loadFavorites(from photos: [Photo]) {
        allPhotos = photos
        let favoriteIds = favoritesManager.favoriteIds()
        favoritePhotos = allPhotos.filter { favoriteIds.contains($0.id) }
        didUpdate?()
    }
}
