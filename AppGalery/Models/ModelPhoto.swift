//
//  ModelPhoto.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 17.02.26.
//

import Foundation

struct UnsplashPhotoDTO: Decodable {
    let id: String
    let createdAt: String?
    let description: String?
    let altDescription: String?
    let urls: UnsplashPhotoURLsDTO
    let user: UnsplashPhotoUserDTO

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case description
        case altDescription = "alt_description"
        case urls
        case user
    }
}

struct UnsplashPhotoURLsDTO: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct UnsplashPhotoUserDTO: Decodable {
    let name: String
    let username: String?
}

struct Photo {
    let id: String
    let urls: PhotoURLs
    let user: PhotoUser
    let description: String?
    let altDescription: String?
    let createdAt: String?
}

struct PhotoURLs {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct PhotoUser {
    let name: String
    let username: String
}

struct PhotoDetail {
    let title: String
    let description: String
    let author: String
    let createdAt: String
}
