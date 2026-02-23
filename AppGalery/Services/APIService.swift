//
//  APIService.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 17.02.26.
//

import Foundation

enum PhotoError: Error {
    case invalidURL
    case missingAccessKey
    case network
    case decoding
}

final class APIService {

    private let session: URLSession = .shared

    private var accessKey: String? {
        let value = Bundle.main.object(forInfoDictionaryKey: "UNSPLASH_ACCESS_KEY") as? String
        if let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return value
        }
        return nil
    }

    func fetchPhotos(page: Int, completion: @escaping (Result<[Photo], PhotoError>) -> Void) {

        guard let accessKey else {
            completion(.failure(.missingAccessKey))
            return
        }
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(page)&per_page=30") else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")

        session.dataTask(with: request) { data, _, error in
            if error != nil {
                completion(.failure(.network))
                return
            }
            guard let data else {
                completion(.failure(.network))
                return
            }
            do {
                let dto = try JSONDecoder().decode([UnsplashPhotoDTO].self, from: data)
                let photos = dto.map { item in
                    Photo(
                        id: item.id,
                        urls: PhotoURLs(
                            raw: item.urls.raw,
                            full: item.urls.full,
                            regular: item.urls.regular,
                            small: item.urls.small,
                            thumb: item.urls.thumb
                        ),
                        user: PhotoUser(
                            name: item.user.name,
                            username: item.user.username ?? ""
                        ),
                        description: item.description,
                        altDescription: item.altDescription,
                        createdAt: item.createdAt
                    )
                }
                completion(.success(photos))
            } catch {
                completion(.failure(.decoding))
            }

        }.resume()
    }
}
