//
//  MockNetworkManager.swift
//  HoneyWell_Task
//
//  Created by Rahul Jamba on 20/02/26.
//
@testable import HoneyWell_Task

final class MockRealAPIManager: NetworkManaging {
    func fetchUsers() async throws -> [User] {
        return [
            User(id: 1, name: "Leanne Graham", email: "Sincere@april.biz", phone: "1-770-736-8031 x56442"),
            User(id: 2, name: "Ervin Howell", email: "Shanna@melissa.tv", phone: "010-692-6593 x09125"),
            User(id: 3, name: "Rahul Sharma", email: "rahul@test.com", phone: "1234567890")
        ]
    }
}
