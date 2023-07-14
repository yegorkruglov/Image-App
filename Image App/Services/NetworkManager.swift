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
    
    private let accessKey = "NX34jEa70uwhD_hTvldS06VrNVL_w_v8wJL86a2fk_Q"
    
    func fetchPosts() async throws -> [Post] {
        guard let url = URL(string: "https://api.unsplash.com/photos/?client_id=\(accessKey)") else {
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
    
    private init() {}
}
