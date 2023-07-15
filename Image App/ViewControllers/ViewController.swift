//
//  ViewController.swift
//  Image App
//
//  Created by Egor Kruglov on 14.07.2023.
//

import UIKit

final class ViewController: UIViewController {

    var post: Post!
    var imageView = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        configureImageView()
    }
    

    private func configureImageView() {
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        let imageURL = URL(string: post.urls.regular)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: imageURL)
    }
}
