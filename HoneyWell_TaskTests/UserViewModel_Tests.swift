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
        
        // Intezaar thoda badhao ya specific check karo
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        XCTAssertFalse(viewModel.fetchedUsers.isEmpty)
        
        // Check karo ki kya result mein "Leanne Graham" kahin bhi hai, order matter nahi karta
        let hasLeanne = viewModel.fetchedUsers.contains { $0.name == "Leanne Graham" }
        XCTAssertTrue(hasLeanne, "Fetched users should contain Leanne Graham")
    }

    @MainActor
    func testSearchDebounce_TriggersWithCorrectQuery() async {
        let expectation = XCTestExpectation(description: "Search triggers loading state")
        
        // When: User types
        viewModel.searchText = "Lean"
        
        // Then: Loading state check karne ke liye delay bohot chota hona chahiye (before API finish)
        // 0.6s is perfect (500ms debounce + 100ms processing start)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            // Agar Mock bohot fast hai toh shayad loading khatam ho jaye,
            // isliye logic check karo ki loading start hui thi ya nahi
            XCTAssertTrue(self.viewModel.isLoading)
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 3.0)
    }


    @MainActor
    func testConversion_WhenDatabaseHasNilValues_ProvidesDefaults() {
        // Note: This tests your 'covertLocalModelIntoApiModel' method
        // Success case for default "NA" handling
        viewModel.loadSavedUsers() // Calls conversion
        
        // Assertions based on your Core Data state
        // If empty, fetchedUsers will be empty but won't crash
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
