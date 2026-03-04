//
//  CoreDataStack.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 2.03.26.
//

import CoreData

final class CoreDataStack {

    let container: NSPersistentContainer

    init(modelName: String = "AppGaleryModel") {
        container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("CoreData failed to load: \(error)")
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    var context: NSManagedObjectContext { container.viewContext }

    func saveIfNeeded() {
        let context = container.viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("CoreData save error:", error)
        }
    }
}
