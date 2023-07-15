//
//  CollectionViewController.swift
//  Image App
//
//  Created by Egor Kruglov on 14.07.2023.
//

import UIKit
import Kingfisher

final class CollectionViewController: UICollectionViewController {
    
    // MARK: - Private Properties
    private var posts: [Post] = []
    private let networkManager = NetworkManager.shared
    private let sectionInsets = UIEdgeInsets(top: 20, left: 20.0, bottom: 20, right: 20.0)
    private let itemsPerRow: CGFloat = 2
    private var searchBar: UISearchController = {
        let searchBar = UISearchController()
        searchBar.searchBar.placeholder = "Search images"
        searchBar.searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        
        configureNavBar()
        fetchRandomPosts()
    }
    
    // MARK: - Private Methods
    private func fetchRandomPosts() {
        Task {
            do {
                posts = try await networkManager.fetchRandomPosts(numberOfPosts: 10)
                collectionView.reloadData()
            } catch  {
                print(error)
            }
        }
    }
    
    private func configureNavBar() {
        title = "Image App"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchBar
        navigationItem.hidesSearchBarWhenScrolling = false
        searchBar.searchResultsUpdater = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(reloadHomePage)
        )
    }
    
    @objc private func reloadHomePage() {
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
        
        fetchRandomPosts()
    }
    
}

// MARK: - UICollectionViewDataSource
extension CollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell else { return UICollectionViewCell() }
        let post = posts[indexPath.item]
        cell.configure(with: post)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fullImageVC = ViewController()
        fullImageVC.post = posts[indexPath.item]
        navigationController?.pushViewController(fullImageVC, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        sectionInsets.left
    }
}

// MARK: - UISearchResultsUpdating
extension CollectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }
    }
    
    
}
