//
//  NetworkManager.swift
//  HoneyWell_Task
//
//  Created by Rahul Jamba on 20/02/26.
//

import Foundation

protocol NetworkManaging {
    func fetchUsers() async throws -> [User]
}

actor NetworkManager: NetworkManaging {
    func fetchUsers() async throws -> [User] {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode([User].self, from: data)
    }
}
