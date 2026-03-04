//
//  FavoritesViewController.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 17.02.26.
//

import UIKit

final class FavoritesViewController: UIViewController {

    private let viewModel: FavoritesViewModel
    private let favoritesStore: FavoritesProtocol
    private let imageLoader: ImageLoaderProtocol

    private enum Constants {
        static let spacing: CGFloat = 1
        static let columns: CGFloat = 3
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Constants.spacing
        layout.minimumLineSpacing = Constants.spacing

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            GalleryCollectionViewCell.self,
            forCellWithReuseIdentifier: GalleryCollectionViewCell.identifier
        )
        return collectionView
    }()

    init(viewModel: FavoritesViewModel, favoritesStore: FavoritesProtocol, imageLoader: ImageLoaderProtocol) {
        self.viewModel = viewModel
        self.favoritesStore = favoritesStore
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.favoritesTitle
        view.backgroundColor = .systemBackground
        setupUI()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reload()
    }

    private func setupUI() {
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupBindings() {
        viewModel.didUpdate = { [weak self] in
            self?.collectionView.reloadData()
        }
    }
}

extension FavoritesViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: GalleryCollectionViewCell.identifier,
                for: indexPath
            ) as? GalleryCollectionViewCell,
            let item = viewModel.item(at: indexPath.item)
        else {
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: GalleryCollectionViewCell.identifier,
                for: indexPath
            )
        }

        cell.configure(with: item, imageLoader: imageLoader)
        return cell
    }
}

extension FavoritesViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let photos: [Photo] = (0..<viewModel.numberOfItems).compactMap { index in
            guard let item = viewModel.item(at: index) else { return nil }

            return Photo(
                id: item.id,
                urls: PhotoURLs(
                    raw: "",
                    full: "",
                    regular: item.regularURL ?? "",
                    small: "",
                    thumb: item.thumbURL ?? ""
                ),
                user: PhotoUser(
                    name: item.authorName ?? L10n.unknownAuthor,
                    username: ""
                ),
                description: item.photoDescription,
                altDescription: item.altDescription,
                createdAt: item.createdAt
            )
        }

        let detailVM = PhotoDetailViewModel(
            photos: photos,
            initialIndex: indexPath.item,
            favoritesStore: favoritesStore
        )

        let detailVC = PhotoDetailViewController(viewModel: detailVM, imageLoader: imageLoader)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let totalSpacing = (Constants.columns - 1) * Constants.spacing
        let width = (collectionView.frame.width - totalSpacing) / Constants.columns
        return CGSize(width: width, height: width)
    }
}
