//
//  SceneDelegate.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 17.02.26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let coreDataStack = CoreDataStack()
        let favoritesStore = CoreDataFavoritesStore(
            context: coreDataStack.context,
            save: { coreDataStack.saveIfNeeded() }
        )

        let imageLoader = ImageLoader()
        let apiService = APIService()

        let galleryVM = GalleryViewModel(service: apiService, favoritesStore: favoritesStore)
        let galleryVC = GalleryViewController(
            viewModel: galleryVM,
            favoritesStore: favoritesStore,
            imageLoader: imageLoader
        )

        let navigationController = UINavigationController(rootViewController: galleryVC)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.prefersLargeTitles = true

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }
}
