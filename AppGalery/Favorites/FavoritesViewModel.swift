//
//  FavoritesViewModel.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 17.02.26.
//

import Foundation

@MainActor
final class FavoritesViewModel {

    private let favoritesStore: FavoritesProtocol
    private var items: [FavoritePhotoItem] = []

    var didUpdate: (() -> Void)?

    init(favoritesStore: FavoritesProtocol) {
        self.favoritesStore = favoritesStore
    }

    var numberOfItems: Int { items.count }

    func item(at index: Int) -> FavoritePhotoItem? {
        guard items.indices.contains(index) else { return nil }
        return items[index]
    }

    func reload() {
        items = favoritesStore.fetchAll()
        didUpdate?()
    }
}
