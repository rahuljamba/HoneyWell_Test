//
//  UserViewModel.swift
//  HoneyWell_Task
//
//  Created by Rahul Jamba on 20/02/26.
//


import Foundation
import Combine

@MainActor
@Observable
final class UserViewModel {
    
    var searchText: String = "" {
        didSet {
            searchSubject.send(searchText)
        }
    }
    
    // 🚨 API Results (Raw Data)
    var fetchedUsers: [User] = []
    
    // 🚨 Core Data Results (Saved Data for UI)
    var savedUsers: [UserEntity] = []
    
    var isLoading: Bool = false
    var errorMessage: String?
    
    // 🚨 @ObservationIgnored is MUST here for macros to compile properly
    private let dataManager: UserDataManager
    private let coreDataManager = CoreDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    private let searchSubject = PassthroughSubject<String, Never>()
    
    init(dataManager: UserDataManager) {
        self.dataManager = dataManager
        setupSearchPublisher()
        loadData()
    }
    
    func loadData() {
        loadSavedUsers()
        
        if savedUsers.isEmpty {
            Task {
                await performSearch(query: "")
            }
        }else {
            covertLocalModelIntoApiModel()
            
        }
    }
    
    private func setupSearchPublisher() {
        searchSubject
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                // Jab user search karega toh yeh trigger hoga
                Task { await self.performSearch(query: query) }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - API Handling
    private func performSearch(query: String) async {
        isLoading = true
        errorMessage = nil
        do {
            // FLOW STEP 2 (cont.): API se data fetch karo
            self.fetchedUsers = try await dataManager.searchUsers(query: query)
            
            // FLOW STEP 3: API ka data aate hi Local (Core Data) main save karwao
            for user in fetchedUsers {
                coreDataManager.saveUser(id: user.id, name: user.name, email: user.email, phone: user.phone)
            }
            
            // UI refresh karne ke liye database se fresh fetch karo
            loadSavedUsers()
            
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - Core Data CRUD Operations
    
    // READ
    func loadSavedUsers() {
        self.savedUsers = coreDataManager.fetchAllUsers()
    }
    
    func covertLocalModelIntoApiModel() {
        
        var localFecthusers = [User]()
        
        self.savedUsers.forEach { user in
            localFecthusers.append(User.init(id: Int(user.id), name: user.name ?? "NA", email: user.email ?? "NA", phone: user.phone ?? "NA"))
            
        }
        
        self.fetchedUsers = localFecthusers
    }
    
    // UPDATE
    func updateUserName(id: Int, newName: String) {
        coreDataManager.updateUser(id: id, newName: newName)
        loadSavedUsers() // Refresh list after update
        covertLocalModelIntoApiModel()
    }
    
    // DELETE
    func deleteUser(id: Int) {
        coreDataManager.deleteUser(id: id)
        loadSavedUsers() // Refresh list after delete
        covertLocalModelIntoApiModel()
    }
}
