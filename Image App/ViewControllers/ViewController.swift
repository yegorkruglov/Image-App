//
//  ViewController.swift
//  Image App
//
//  Created by Egor Kruglov on 14.07.2023.
//

import UIKit

final class ViewController: UIViewController {
    
    // MARK: - Public Properties
    var post: Post!
    var imageView = UIImageView()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Image by \(post.user.username)"
        
        configureImageView()
        configureNavBar()
    }
    
    // MARK: - Private Methods
    private func configureImageView() {
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        
        let margins = view.layoutMarginsGuide
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        let imageURL = URL(string: post.urls.regular)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: imageURL)
    }
    
    private func configureNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "info.circle"),
            style: .done,
            target: self,
            action: #selector(showDetails)
        )
    }
    
    @objc private func showDetails() {
        let alert = UIAlertController()
        alert.message = """
                        Width: \(post.width) Height: \(post.height)
                        Description: \(post.description ?? "no description")
                        """
        let closeAction = UIAlertAction(title: "Close", style: .cancel)
        alert.addAction(closeAction)
        
        present(alert, animated: true)
    }
    
}
