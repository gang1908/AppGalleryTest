//
//  UIImageViewCache.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 17.02.26.
//

import UIKit
import ObjectiveC

extension UIImageView {

    func loadImage(from url: URL) {
        if let cached = ImageCacheService.shared.image(for: url.absoluteString) {
            image = cached
            return
        }
        
        lastRequestedURL = url.absoluteString
        image = nil

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self,
                  let data,
                  let image = UIImage(data: data) else {
                return
            }

            ImageCacheService.shared.save(image, for: url.absoluteString)

            DispatchQueue.main.async {
                guard self.lastRequestedURL == url.absoluteString else { return }
                self.image = image
            }
        }.resume()
    }
}

private enum AssociatedKeys {
    static var lastURL = "appgalery.lastRequestedURL"
}

private extension UIImageView {
    var lastRequestedURL: String? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.lastURL) as? String }
        set { objc_setAssociatedObject(self, &AssociatedKeys.lastURL, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
