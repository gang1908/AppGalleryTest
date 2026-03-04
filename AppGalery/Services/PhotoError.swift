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

extension PhotoError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingAccessKey:
            return NSLocalizedString("error.missingKey", comment: "")
        case .unauthorized:
            return NSLocalizedString("error.unauthorized", comment: "")
        case .rateLimited:
            return NSLocalizedString("error.rateLimited", comment: "")
        case .invalidURL:
            return NSLocalizedString("error.invalidURL", comment: "")
        case .network:
            return NSLocalizedString("error.network", comment: "")
        case .decoding:
            return NSLocalizedString("error.decoding", comment: "")
        }
    }
}
