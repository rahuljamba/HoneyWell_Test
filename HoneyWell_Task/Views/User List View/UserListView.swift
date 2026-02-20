//
//  UserView.swift
//  HoneyWell_Task
//
//  Created by Rahul Jamba on 20/02/26.
//

import SwiftUI

import SwiftUI

struct UserListView: View {
    
    @State private var viewModel = UserViewModel(dataManager: UserDataManager(networkManager: NetworkManager()))
    
    // 🚨 Alert State Variables
    @State private var showingUpdateAlert = false
    @State private var userToUpdate: User? // Change to UserEntity if using the CoreData approach
    @State private var newName: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading && $viewModel.fetchedUsers.isEmpty {
                    ProgressView("Fetching Users...")
                } else if let error = viewModel.errorMessage {
                    Text("Error: \(error)").foregroundColor(.red)
                } else {
                    List(viewModel.fetchedUsers) { user in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(user.name)
                                .font(.headline)
                            
                            HStack {
                                Image(systemName: "envelope.fill")
                                Text(user.email)
                            }
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            
                            HStack {
                                Image(systemName: "phone.fill")
                                Text(user.phone)
                            }
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                        
                        // 🚨 NEW: Swipe Actions (Left Swipe)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            
                            // 1. Delete Action (Red background automatically via .destructive role)
                            Button(role: .destructive) {
                                deleteAction(for: user)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            // 2. Update Action (Custom Blue Tint)
                            Button {
                                userToUpdate = user
                                newName = user.name // Pre-fill current name
                                showingUpdateAlert = true
                            } label: {
                                Label("Update", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Contacts")
            .searchable(text: $viewModel.searchText, prompt: "Search by name...")
            // 🚨 NEW: Alert with TextField
            .alert("Update Name", isPresented: $showingUpdateAlert, presenting: userToUpdate) { user in
                TextField("Enter new name", text: $newName)
                
                Button("Save") {
                    updateAction(for: user, with: newName)
                }
                
                Button("Cancel", role: .cancel) {
                    newName = ""
                }
            } message: { user in
                Text("Update details for \(user.name)")
            }
        }
    }
    
    // MARK: - Action Handlers
    
    private func deleteAction(for user: User) {
        print("Delete triggered for: \(user.name)")
        viewModel.deleteUser(id: user.id)
    }
    
    private func updateAction(for user: User, with newName: String) {
        // ViewModel mein update function call karna
        guard !newName.isEmpty else { return }
        viewModel.updateUserName(id: user.id, newName: newName)
    }
}
