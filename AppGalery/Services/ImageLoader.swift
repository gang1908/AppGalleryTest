//
//  ImageLoader.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 2.03.26.
//

import UIKit

final class ImageLoader: ImageLoaderProtocol {

    private let cache = NSCache<NSString, UIImage>()
    private let session: URLSession

    private var tasks: [ObjectIdentifier: URLSessionDataTask] = [:]

    private enum Constants {
        static let cacheCountLimit = 200
        static let cacheTotalCostLimit = 50 * 1024 * 1024
    }

    init(session: URLSession = .shared) {
        self.session = session
        cache.countLimit = Constants.cacheCountLimit
        cache.totalCostLimit = Constants.cacheTotalCostLimit
    }

    func load(url: URL, into imageView: UIImageView) {
        let key = url.absoluteString as NSString

        if let cached = cache.object(forKey: key) {
            imageView.image = cached
            return
        }

        let id = ObjectIdentifier(imageView)
        tasks[id]?.cancel()
        imageView.image = nil

        let task = session.dataTask(with: url) { [weak self, weak imageView] data, _, _ in
            guard let self else { return }
            defer { self.tasks[id] = nil }

            guard let imageView, let data, let image = UIImage(data: data) else { return }

            let cost = Int(image.size.width * image.size.height * image.scale * image.scale)
            self.cache.setObject(image, forKey: key, cost: cost)

            DispatchQueue.main.async {
                imageView.image = image
            }
        }

        tasks[id] = task
        task.resume()
    }

    func prefetch(urls: [URL]) {
        for url in urls {
            let key = url.absoluteString as NSString
            if cache.object(forKey: key) != nil { continue }

            session.dataTask(with: url) { [weak self] data, _, _ in
                guard let self, let data, let image = UIImage(data: data) else { return }
                let cost = Int(image.size.width * image.size.height * image.scale * image.scale)
                self.cache.setObject(image, forKey: key, cost: cost)
            }.resume()
        }
    }
}
