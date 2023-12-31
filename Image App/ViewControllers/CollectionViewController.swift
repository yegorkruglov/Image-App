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
    private let networkManager = NetworkManager.shared
    
    private let sectionInsets = UIEdgeInsets(top: 20, left: 20.0, bottom: 20, right: 20.0)
    private let itemsPerRow: CGFloat = 2
    private var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = "Search images"
        searchController.searchBar.searchBarStyle = .default
        return searchController
    }()

    private var searchQuery: String!
    private var searchResults: SearchResults!
    private var numberOfPagesDownloaded: Int!
    private var posts: [Post] = []
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        
        configureNavBar()
        fetchRandomPosts()
    }
    
    // MARK: - Private Methods
    private func fetchRandomPosts() {
        Task {
            do {
                posts = try await networkManager.fetchRandomPosts(numberOfPosts: 20)
                collectionView.reloadData()
            } catch  {
                print(error)
            }
        }
    }
    
    private func configureNavBar() {
        title = "Featured images"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(reloadHomePage)
        )
    }
    
    private func clearCache() {
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
        searchQuery = nil
    }
    
    @objc private func reloadHomePage() {
        clearCache()
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
        
        searchController.searchBar.resignFirstResponder()
        navigationController?.pushViewController(fullImageVC, animated: true)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let visibleHeight = scrollView.bounds.height
        var isLoadingData = false

        if offsetY > contentHeight - visibleHeight {
            guard
                searchController.isActive,
                searchResults != nil,
                searchResults.totalPages > 1,
                numberOfPagesDownloaded < searchResults.totalPages,
                !isLoadingData else { return }
            
            isLoadingData.toggle()
            let nextPageNumber = numberOfPagesDownloaded + 1
            Task {
                do {
                    searchResults = try await networkManager.searchPhotosFor(query: searchQuery, page: nextPageNumber)
                    let postsToAdd = searchResults.results
                    posts.append(contentsOf: postsToAdd)
                    numberOfPagesDownloaded = nextPageNumber
                    collectionView.reloadData()
                    isLoadingData.toggle()
                } catch  {
                    print(error)
                }
            }
        }
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

// MARK: - UISearchControllerDelegate
extension CollectionViewController: UISearchControllerDelegate {
    func willDismissSearchController(_ searchController: UISearchController) {
        clearCache()
        fetchRandomPosts()
        if !posts.isEmpty {
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }
}

// MARK: - UISearchResultsUpdating
extension CollectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard
            let query = searchController.searchBar.text,
            !query.isEmpty else { return }
        searchQuery = query
        Task {
            do {
                searchResults = try await networkManager.searchPhotosFor(query: query, page: 1)
                posts = searchResults.results
                guard searchResults.totalPages != 0 else {
                    posts = []
                    collectionView.reloadData()
                    print("No results")
                    return
                }
                numberOfPagesDownloaded = 1
                collectionView.reloadData()
            } catch  {
                print(error)
            }
        }
    }
}
