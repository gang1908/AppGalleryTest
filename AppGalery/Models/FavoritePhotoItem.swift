//
//  FavoritePhotoItem.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 3.03.26.
//

import Foundation

struct FavoritePhotoItem: Hashable {
    let id: String
    let thumbURL: String?
    let regularURL: String?
    let authorName: String?
    let createdAt: String?
    let photoDescription: String?
    let altDescription: String?
}
