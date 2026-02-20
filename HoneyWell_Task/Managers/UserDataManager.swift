//
//  UserDataManager.swift
//  HoneyWell_Task
//
//  Created by Rahul Jamba on 20/02/26.
//


import Foundation

actor UserDataManager {
    private var cachedUsers: [User] = []
    private let networkManager: NetworkManaging
    
    init(networkManager: NetworkManaging) {
        self.networkManager = networkManager
    }
    
    func getUsers() async throws -> [User] {
        if cachedUsers.isEmpty {
            cachedUsers = try await networkManager.fetchUsers()
        }
        return cachedUsers
    }
    
    func searchUsers(query: String) async throws -> [User] {
        let allUsers = try await getUsers()
        
        guard !query.isEmpty else { return allUsers }
        
        return allUsers.filter { user in
            user.name.localizedCaseInsensitiveContains(query)
        }
    }
}

