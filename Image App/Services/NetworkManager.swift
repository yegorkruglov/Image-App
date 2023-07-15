//
//  NetworkManager.swift
//  Image App
//
//  Created by Egor Kruglov on 14.07.2023.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
}

final class NetworkManager {
    static let shared = NetworkManager()
    
    private let apiKey = "NX34jEa70uwhD_hTvldS06VrNVL_w_v8wJL86a2fk_Q"
    
    func fetchRandomPosts(numberOfPosts count: Int) async throws -> [Post] {
        guard let url = URL(string: "https://api.unsplash.com/photos/random?client_id=\(apiKey)&count=\(count)") else {
            throw NetworkError.invalidURL
         }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        
        do {
            return try decoder.decode([Post].self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func searchPhotosFor(query: String) async throws -> SearchResults {
        guard let url = URL(string: "https://api.unsplash.com/search/photos?client_id=\(apiKey)&page=1&per_page=20&query=\(query)") else {
            throw NetworkError.invalidURL
         }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        
        do {
            return try decoder.decode(SearchResults.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    private init() {}
}
