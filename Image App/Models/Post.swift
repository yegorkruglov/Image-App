//
//  Post.swift
//  Image App
//
//  Created by Egor Kruglov on 14.07.2023.
//

import Foundation

struct Post: Decodable {
    let id: String
    let width, height: Int
    let description: String?
    let urls: Urls
    let user: User
}

struct Urls: Codable {
    let raw, full, regular, small: String
}
struct User: Codable {
    let username: String
}
