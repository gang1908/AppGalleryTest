//
//  PhotoError.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 2.03.26.
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

extension PhotoError {
    var message: String {
        switch self {
        case .missingAccessKey:
            return
                "Не найден UNSPLASH_ACCESS_KEY. Добавь ключ в Info.plist (см. README)."
        case .unauthorized:
            return
                "Ключ Unsplash неверный или нет доступа (401/403). Проверь UNSPLASH_ACCESS_KEY."
        case .rateLimited:
            return "Слишком много запросов (429). Попробуй чуть позже."
        case .invalidURL:
            return "Ошибка формирования запроса."
        case .network:
            return "Проблема с сетью. Проверь интернет и попробуй снова."
        case .decoding:
            return "Не удалось обработать ответ сервера."
        }
    }
}
