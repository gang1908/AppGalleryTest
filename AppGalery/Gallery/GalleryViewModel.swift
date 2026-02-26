//
//  GalleryViewModel.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 17.02.26.
//

import Foundation

@MainActor
final class GalleryViewModel {

    private let service = APIService()
    private let favoritesManager = FavoritesManager.shared

    private(set) var photos: [Photo] = []

    var didStartLoading: (() -> Void)?
    var didUpdate: (() -> Void)?
    var didFail: ((String) -> Void)?

    private var page = 1
    private var isLoading = false

    var numberOfItems: Int { photos.count }

    func photo(at index: Int) -> Photo? {
        guard index >= 0 && index < photos.count else { return nil }
        return photos[index]
    }

    func isFavorite(photoId: String) -> Bool {
        favoritesManager.isFavorite(photoId)
    }

    func loadNextPage() {
        guard !isLoading else { return }
        isLoading = true
        didStartLoading?()
        
        service.fetchPhotos(page: page) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let newPhotos):
                    self.photos.append(contentsOf: newPhotos)
                    self.page += 1
                    self.didUpdate?()
                case .failure(let error):
                    switch error {
                    case .missingAccessKey:
                        self.didFail?("Не найден UNSPLASH_ACCESS_KEY. Добавь ключ в Info.plist (см. README).")
                        
                    case .unauthorized:
                        self.didFail?("Ключ Unsplash неверный или нет доступа (401/403). Проверь UNSPLASH_ACCESS_KEY в Info.plist.")
                        
                    case .rateLimited:
                        self.didFail?("Слишком много запросов (429). Попробуй чуть позже.")
                        
                    case .invalidURL:
                        self.didFail?("Ошибка формирования запроса. Попробуй перезапустить приложение.")
                        
                    case .decoding:
                        self.didFail?("Не удалось обработать ответ сервера.")
                        
                    case .network:
                        self.didFail?("Проблема с сетью. Проверь интернет и попробуй снова.")
                    }
                }
            }
        }
    }

    func refresh() {
        guard !isLoading else { return }
        page = 1
        photos = []
        loadNextPage()
    }
}
