//
//  ImageCacheService.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 17.02.26.
//

import UIKit

final class ImageCacheService {

    static let shared = ImageCacheService()

    private let cache = NSCache<NSString, UIImage>()

    private init() {
    }

    func image(for key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    func save(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }

    func remove(for key: String) {
        cache.removeObject(forKey: key as NSString)
    }

    func clear() {
        cache.removeAllObjects()
    }
}
