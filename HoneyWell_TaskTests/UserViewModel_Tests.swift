//
//  UserViewModel_Tests.swift
//  HoneyWell_Task
//
//  Created by Rahul Jamba on 20/02/26.
//


import XCTest
import Combine
@testable import HoneyWell_Task // Apne project ka sahi naam yahan likho

final class UserViewModelTests: XCTestCase {
    
    var viewModel: UserViewModel!
    var mockNetwork: MockNetworkManager!
    var dataManager: UserDataManager!
    var cancellables: Set<AnyCancellable>!

    @MainActor
    override func setUp() {
        super.setUp()
        // 1. Setup Mock and Managers
        mockNetwork = MockNetworkManager()
        dataManager = UserDataManager(networkManager: mockNetwork)
        viewModel = UserViewModel(dataManager: dataManager)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockNetwork = nil
        dataManager = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Test Cases
    
    @MainActor
    func testInitialLoad_WhenDatabaseEmpty_FetchesFromAPI() async {
        // Given: Empty database initially (Assume loadData triggers API if empty)
        
        // When: Initial load triggered
        viewModel.loadData()
        
        // Then: Wait a bit for async task
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        XCTAssertFalse(viewModel.fetchedUsers.isEmpty, "Users should be fetched from API when local is empty")
        XCTAssertEqual(viewModel.fetchedUsers.first?.name, "Leanne Graham")
    }

    @MainActor
    func testSearchDebounce_FiltersDataCorrectly() async {
        // Given
        let expectation = XCTestExpectation(description: "Search filters users after debounce")
        
        // Pre-load data
        viewModel.loadData()
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // When: User types in search bar
        viewModel.searchText = "Leanne"
        
        // Then: Wait for 500ms debounce + processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.viewModel.fetchedUsers.contains(where: { $0.name.contains("Leanne") }) {
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
    }

    @MainActor
    func testDeleteUser_UpdatesList() async {
        // Given: Data is present
        viewModel.loadData()
        try? await Task.sleep(nanoseconds: 500_000_000)
        let initialCount = viewModel.fetchedUsers.count
        let userToDelete = viewModel.fetchedUsers.first?.id ?? 1
        
        // When: Delete is called
        viewModel.deleteUser(id: userToDelete)
        
        // Then: Local count should decrease
        XCTAssertLessThan(viewModel.savedUsers.count, initialCount, "Saved users count should decrease after deletion")
    }
}

// MARK: - Mocks for Testing

final class MockNetworkManager: NetworkManaging {
    func fetchUsers() async throws -> [User] {
        return [
            User(id: 1, name: "Leanne Graham", email: "Sincere@april.biz", phone: "1-770-736-8031"),
            User(id: 2, name: "Ervin Howell", email: "Shanna@melissa.tv", phone: "010-692-6593")
        ]
    }
    
    // searchUsers support
    func searchUsers(query: String) async throws -> [User] {
        let all = try await fetchUsers()
        if query.isEmpty { return all }
        return all.filter { $0.name.contains(query) }
    }
}
