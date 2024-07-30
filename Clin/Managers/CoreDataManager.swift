//
//  CoreDataManager.swift
//  Clin
//
//  Created by asia on 30/07/2024.
//

import Foundation
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "ListingContainer")
    }
    
    func loadCoreData(completion: @escaping (Bool) -> Void) {
        container.loadPersistentStores { description, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Unable to load persistent stores: \(error)")
                    completion(false)
                } else {
                    completion(true)
                } 
            }
        }
    }
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func delete(_ object: NSManagedObject) {
        context.delete(object)
        saveContext()
    }
    
    func fetch<T: NSManagedObject>(_ objectType: T.Type, predicate: NSPredicate? = nil) -> [T] {
        let request = T.fetchRequest()
        if let predicate = predicate {
            request.predicate = predicate
        }
        do {
            return try context.fetch(request) as! [T]
        } catch {
            print("Failed to fetch \(T.self): \(error)")
            return []
        }
    }
}
