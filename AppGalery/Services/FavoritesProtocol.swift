//
//  FavoritesProtocol.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 2.03.26.
//

import Foundation

protocol FavoritesProtocol {
    func isFavorite(_ id: String) -> Bool
    func toggle(photo: Photo)
    func remove(_ id: String)
    func fetchAll() -> [FavoritePhotoItem]
}
