//
//  ViewController.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 17.02.26.
//

import UIKit

final class GalleryViewController: UIViewController {

    private let viewModel: GalleryViewModel
    private let favoritesStore: FavoritesProtocol
    private let imageLoader: ImageLoaderProtocol

    private enum Constants {
        static let spacing: CGFloat = 1
        static let columns: CGFloat = 3
        static let paginationTriggerMultiplier: CGFloat = 1.5
        static let errorViewSideInset: CGFloat = 20
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
        collectionView.prefetchDataSource = self
        collectionView.register(
            GalleryCollectionViewCell.self,
            forCellWithReuseIdentifier: GalleryCollectionViewCell.identifier
        )
        return collectionView
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()

    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let errorView = ErrorView()

    init(viewModel: GalleryViewModel, favoritesStore: FavoritesProtocol, imageLoader: ImageLoaderProtocol) {
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
        setupUI()
        setupBindings()
        viewModel.loadNextPage()
    }
}

private extension GalleryViewController {

    func setupUI() {
        title = L10n.galleryTitle
        view.backgroundColor = .systemBackground

        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorView)

        collectionView.refreshControl = refreshControl

        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true

        errorView.isHidden = true
        errorView.retryAction = { [weak self] in
            self?.refreshData()
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "heart.fill"),
            style: .plain,
            target: self,
            action: #selector(openFavorites)
        )

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.errorViewSideInset),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.errorViewSideInset)
        ])
    }
}

private extension GalleryViewController {

    func setupBindings() {
        viewModel.didStartLoading = { [weak self] in
            guard let self else { return }
            if self.viewModel.numberOfItems == 0 {
                self.loadingIndicator.startAnimating()
            }
        }

        viewModel.didUpdate = { [weak self] in
            guard let self else { return }

            self.collectionView.reloadData()
            self.loadingIndicator.stopAnimating()
            self.refreshControl.endRefreshing()
            self.errorView.isHidden = true
        }

        viewModel.didFail = { [weak self] message in
            guard let self else { return }

            self.loadingIndicator.stopAnimating()
            self.refreshControl.endRefreshing()

            self.errorView.setError(message)
            self.errorView.isHidden = self.viewModel.numberOfItems > 0
        }
    }
}

private extension GalleryViewController {

    @objc func refreshData() {
        viewModel.refresh()
    }

    @objc func openFavorites() {
        let favoritesVM = FavoritesViewModel(favoritesStore: favoritesStore)
        let favoritesVC = FavoritesViewController(
            viewModel: favoritesVM,
            favoritesStore: favoritesStore,
            imageLoader: imageLoader
        )
        navigationController?.pushViewController(favoritesVC, animated: true)
    }
}

extension GalleryViewController: UICollectionViewDataSource {

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
            let photo = viewModel.photo(at: indexPath.item)
        else {
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: GalleryCollectionViewCell.identifier,
                for: indexPath
            )
        }

        cell.configure(
            with: photo,
            isFavorite: viewModel.isFavorite(photoId: photo.id),
            imageLoader: imageLoader
        )

        return cell
    }
}

extension GalleryViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photos = (0..<viewModel.numberOfItems).compactMap { viewModel.photo(at: $0) }

        let detailVM = PhotoDetailViewModel(
            photos: photos,
            initialIndex: indexPath.item,
            favoritesStore: favoritesStore
        )

        let detailVC = PhotoDetailViewController(viewModel: detailVM, imageLoader: imageLoader)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height * Constants.paginationTriggerMultiplier {
            viewModel.loadNextPage()
        }
    }
}

extension GalleryViewController: UICollectionViewDelegateFlowLayout {

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

extension GalleryViewController: UICollectionViewDataSourcePrefetching {

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths
            .compactMap { viewModel.photo(at: $0.item)?.urls.thumb }
            .compactMap(URL.init(string:))

        imageLoader.prefetch(urls: urls)
    }
}
