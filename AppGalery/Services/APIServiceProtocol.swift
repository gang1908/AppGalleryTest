//
//  APIServiceProtocol.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 2.03.26.
//

import Foundation

protocol APIServiceProtocol {
    func fetchPhotos(
        page: Int,
        completion: @escaping (Result<[Photo], PhotoError>) -> Void
    )
}
