//
//  CoreDataStack.swift
//  RestaurantsList
//
//  Created by Andriy Chuprina on 7/18/21.
//

import CoreData
import RxSwift

final class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    // MARK: Public properties
    var viewContext: NSManagedObjectContext { persistentContainer.viewContext }
    
    // MARK: - Core Data stack
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "RestaurantsList")
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }
        
        /// Used for testing, doesn't provide persistent store
        // description.url = URL(fileURLWithPath: "/dev/null")
        
        description.setOption(true as NSNumber,
                              forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        description.setOption(true as NSNumber,
                              forKey: NSPersistentHistoryTrackingKey)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.name = "viewContext"
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.shouldDeleteInaccessibleFaults = true
        return container
    }()
    
    // MARK: internal properties
    private let disposeBag = DisposeBag()
    
    private init() {
        _ = persistentContainer
        NotificationCenter.default.rx.notification(.NSPersistentStoreRemoteChange)
            .subscribe(onNext: { [weak self] notification in
                self?.fetchPersistentHistoryTransactionsAndChanges()
            }).disposed(by: disposeBag)
    }
    
    // MARK: Creates and configures a private queue context.
    private func newTaskContext(name: String? = nil, author: String? = nil) -> NSManagedObjectContext {
        let taskContext = persistentContainer.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        taskContext.name = name
        taskContext.transactionAuthor = author
        return taskContext
    }
    
    // MARK: Check if has changes
    private func fetchPersistentHistoryTransactionsAndChanges() {
        let taskContext = newTaskContext(name: "persistentHistoryContext")
        taskContext.perform {
            do {
                let token: NSPersistentHistoryToken? = nil
                let changeRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: token)
                let historyResult = try taskContext.execute(changeRequest) as? NSPersistentHistoryResult
                if let history = historyResult?.result as? [NSPersistentHistoryTransaction],
                   !history.isEmpty {
                    self.mergePersistentHistoryChanges(from: history)
                    return
                }
            } catch {
                debugPrint(error)
            }
        }
    }

    // MARK: Merge changes into view context
    private func mergePersistentHistoryChanges(from history: [NSPersistentHistoryTransaction]) {
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            for transaction in history {
                viewContext.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
            }
        }
    }
    
    //MARK: Insert array of objects into store
    func insert<T: EntityDTO>(_ objects: [T]) {
        let context = newTaskContext(name: "importContext", author: "importRestaurants")
        context.perform {
            do {
                let data = try JSONEncoder().encode(objects)
                let objects = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
                let insert = NSBatchInsertRequest(entityName: T.entitiName, objects: objects ?? [])
                try context.execute(insert)
            } catch {
                debugPrint(error)
            }
        }
    }
    
    //MARK: Insert singe object into store
    func insert<T: EntityDTO>(_ object: T) {
        insert([object])
    }
    
}
