//
//  ImageLoaderProtocol.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 2.03.26.
//

import UIKit

protocol ImageLoaderProtocol {
    func load(url: URL, into imageView: UIImageView)
    func prefetch(urls: [URL])
}
