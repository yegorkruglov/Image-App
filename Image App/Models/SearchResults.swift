//
//  SerachResults.swift
//  Image App
//
//  Created by Egor Kruglov on 15.07.2023.
//

import Foundation

struct SearchResults: Decodable {
    let total, totalPages: Int
    let results: [Post]

    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case results
    }
}
