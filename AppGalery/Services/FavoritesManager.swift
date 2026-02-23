//
//  ModelFavoritesManager.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 17.02.26.
//

import Foundation

final class FavoritesManager {
    
    static let shared = FavoritesManager()
    private let key = "favorite_photos"

    private init() {}
    
    private var favorites: Set<String> {
        get {
            let array = UserDefaults.standard.stringArray(forKey: key) ?? []
            return Set(array)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: key)
        }
    }

    func favoriteIds() -> Set<String> {
        favorites
    }

    func toggleFavorite(_ id: String) {
        var current = favorites
        
        if current.contains(id) {
            current.remove(id)
        } else {
            current.insert(id)
        }
        favorites = current
    }

    func isFavorite(_ id: String) -> Bool {
        favorites.contains(id)
    }

    func all() -> [String] {
        Array(favorites)
    }
}
