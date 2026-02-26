//
//  ViewController.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 17.02.26.
//

import UIKit

final class GalleryViewController: UIViewController {

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GalleryCollectionViewCell.self,
                    forCellWithReuseIdentifier: GalleryCollectionViewCell.identifier)
        return collectionView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let errorView = ErrorView()
    private let viewModel = GalleryViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.loadNextPage()
    }
}

private extension GalleryViewController {
    
    func setupUI() {
        title = "Галерея"
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
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
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
        
        viewModel.didFail = { [weak self] error in
            guard let self else { return }
            
            self.loadingIndicator.stopAnimating()
            self.refreshControl.endRefreshing()
            
            self.errorView.setError(error)
            self.errorView.isHidden = self.viewModel.numberOfItems > 0
        }
    }
}

private extension GalleryViewController {
    
    @objc func refreshData() {
        viewModel.refresh()
    }
    
    @objc func openFavorites() {
        let favoritesVC = FavoritesViewController()
        favoritesVC.configure(with: viewModel.photos)
        navigationController?.pushViewController(favoritesVC, animated: true)
    }
}

extension GalleryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GalleryCollectionViewCell.identifier,
            for: indexPath
        ) as! GalleryCollectionViewCell

        if let photo = viewModel.photo(at: indexPath.item) {
            cell.configure(
                with: photo,
                isFavorite: viewModel.isFavorite(photoId: photo.id)
            )
        } else {
            cell.prepareForReuse()
        }

        return cell
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        let photos = (0..<viewModel.numberOfItems)
            .compactMap { viewModel.photo(at: $0) }
        
        let detailVM = PhotoDetailViewModel(
            photos: photos,
            initialIndex: indexPath.item
        )
        
        let detailVC = PhotoDetailViewController(viewModel: detailVM)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height * 1.5 {
            viewModel.loadNextPage()
        }
    }
}

extension GalleryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
}
