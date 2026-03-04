//
//  CoreDataFavorites.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 2.03.26.
//

import CoreData

final class CoreDataFavoritesStore: FavoritesProtocol {

    private let context: NSManagedObjectContext
    private let save: () -> Void

    init(context: NSManagedObjectContext, save: @escaping () -> Void) {
        self.context = context
        self.save = save
    }

    func isFavorite(_ id: String) -> Bool {
        let request: NSFetchRequest<FavoritePhoto> = FavoritePhoto.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", id)

        let count = (try? context.count(for: request)) ?? 0
        return count > 0
    }

    func toggle(photo: Photo) {
        if isFavorite(photo.id) {
            remove(photo.id)
            return
        }

        let obj = FavoritePhoto(context: context)
        obj.id = photo.id
        obj.thumbURL = photo.urls.thumb
        obj.regularURL = photo.urls.regular
        obj.authorName = photo.user.name
        obj.createdAt = photo.createdAt
        obj.photoDescription = photo.description
        obj.altDescription = photo.altDescription

        save()
    }

    func remove(_ id: String) {
        let request: NSFetchRequest<FavoritePhoto> = FavoritePhoto.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", id)

        if let existing = try? context.fetch(request).first {
            context.delete(existing)
            save()
        }
    }

    func fetchAll() -> [FavoritePhotoItem] {
        let request: NSFetchRequest<FavoritePhoto> = FavoritePhoto.fetchRequest()
        let items = (try? context.fetch(request)) ?? []

        return items.map { obj in
            FavoritePhotoItem(
                id: obj.id ?? "",
                thumbURL: obj.thumbURL,
                regularURL: obj.regularURL,
                authorName: obj.authorName,
                createdAt: obj.createdAt,
                photoDescription: obj.photoDescription,
                altDescription: obj.altDescription
            )
        }
    }
}
