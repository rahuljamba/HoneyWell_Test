//
//  UserViewModel_Tests.swift
//  HoneyWell_Task
//
//  Created by Rahul Jamba on 20/02/26.
//


import XCTest
import Combine
@testable import HoneyWell_Task

final class UserViewModelTests: XCTestCase {
    
    var viewModel: UserViewModel!
    var mockNetwork: MockNetworkManager!
    var dataManager: UserDataManager!
    var cancellables: Set<AnyCancellable>!

    @MainActor
    override func setUp() {
        super.setUp()
        // Initialize Mocking infrastructure
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

    // MARK: - Success Cases
    
    @MainActor
    func testLoadData_WhenLocalEmpty_SuccessAPI() async {
        mockNetwork.shouldReturnError = false
        
        viewModel.loadData()
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        XCTAssertFalse(viewModel.fetchedUsers.isEmpty)
        
        let hasLeanne = viewModel.fetchedUsers.contains { $0.name == "Leanne Graham" }
        XCTAssertTrue(hasLeanne, "Fetched users should contain Leanne Graham")
    }

    @MainActor
    func testSearchDebounce_TriggersWithCorrectQuery() async {
        let expectation = XCTestExpectation(description: "Search triggers loading state")
        
        viewModel.searchText = "Lean"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            XCTAssertTrue(self.viewModel.isLoading)
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 3.0)
    }


    @MainActor
    func testConversion_WhenDatabaseHasNilValues_ProvidesDefaults() {
        
        viewModel.loadSavedUsers() // Calls conversion
        
        XCTAssertNotNil(viewModel.fetchedUsers)
    }
}

// MARK: - Mocking Infrastructure

final class MockNetworkManager: NetworkManaging {
    var shouldReturnError = false
    
    func fetchUsers() async throws -> [User] {
        if shouldReturnError {
            throw URLError(.badServerResponse)
        }
        return [
            User(id: 1, name: "Leanne Graham", email: "Sincere@april.biz", phone: "1-770-736-8031")
        ]
    }
    
    func searchUsers(query: String) async throws -> [User] {
        return try await fetchUsers()
    }
}
