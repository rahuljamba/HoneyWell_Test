//
//  CoreDataManager.swift
//  HoneyWell_Task
//
//  Created by Rahul Jamba on 20/02/26.
//
import Foundation
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "HoneyWell_Task")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error { print("CoreData failed: \(error)") }
        }
    }
    
    var context: NSManagedObjectContext { persistentContainer.viewContext }
    func saveContext() { try? context.save() }
    
    // 1. CREATE / STORE
    func saveUser(id: Int, name: String, email: String, phone: String) {
        // Avoid duplicates
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        if let _ = try? context.fetch(request).first { return }
        
        let newUser = UserEntity(context: context)
        newUser.id = Int64(id)
        newUser.name = name
        newUser.email = email
        newUser.phone = phone
        saveContext()
    }
    
    func fetchAllUsers() -> [UserEntity] {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        return (try? context.fetch(request)) ?? []
    }
    
    func updateUser(id: Int, newName: String) {
            let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", id)
            
            if let userToUpdate = try? context.fetch(request).first {
                userToUpdate.name = newName
                saveContext()
            }
        }
        
        func deleteUser(id: Int) {
            let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", id)
            
            if let userToDelete = try? context.fetch(request).first {
                context.delete(userToDelete)
                saveContext()
            }
        }
}
