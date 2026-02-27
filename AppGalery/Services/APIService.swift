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
    case unauthorized
    case rateLimited
    case decoding
}

final class APIService {

    private let session: URLSession = .shared

    private var accessKey: String? {
        let value = Bundle.main.object(forInfoDictionaryKey: "UNSPLASH_ACCESS_KEY") as? String
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }

    func fetchPhotos(
        page: Int,
        completion: @escaping (Result<[Photo], PhotoError>) -> Void
    ) {
        guard let accessKey else {
            completion(.failure(.missingAccessKey))
            return
        }

        guard let request = buildRequest(page: page, accessKey: accessKey) else {
            completion(.failure(.invalidURL))
            return
        }

        session.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }

            let result = self.processResponse(data: data,
                                              response: response,
                                              error: error)
            completion(result)
        }.resume()
    }
    
    private func buildRequest(page: Int, accessKey: String) -> URLRequest? {
        guard let url = URL(
            string: "https://api.unsplash.com/photos?page=\(page)&per_page=30"
        ) else {
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)",
                         forHTTPHeaderField: "Authorization")

        return request
    }
    
    private func processResponse(
        data: Data?,
        response: URLResponse?,
        error: Error?
    ) -> Result<[Photo], PhotoError> {

        if error != nil {
            return .failure(.network)
        }

        guard let http = response as? HTTPURLResponse else {
            return .failure(.network)
        }

        switch http.statusCode {
        case 200...299:
            break
        case 401, 403:
            return .failure(.unauthorized)
        case 429:
            return .failure(.rateLimited)
        default:
            return .failure(.network)
        }

        guard let data else {
            return .failure(.network)
        }

        return decodePhotos(from: data)
    }
    
    private func decodePhotos(from data: Data) -> Result<[Photo], PhotoError> {
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

            return .success(photos)
        } catch {
            return .failure(.decoding)
        }
    }
}
