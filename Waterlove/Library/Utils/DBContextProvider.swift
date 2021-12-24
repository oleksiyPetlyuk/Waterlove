//
//  DBContextProvider.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 23.12.2021.
//

import Foundation
import CoreData

protocol DBContextProviderProtocol {
  func mainQueueContext() -> NSManagedObjectContext
  func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void)
}

final class DBContextProvider {
  private lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Waterlove")

    container.loadPersistentStores { _, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }

      container.viewContext.automaticallyMergesChangesFromParent = true
    }

    return container
  }()

  private lazy var mainContext = persistentContainer.viewContext
}

extension DBContextProvider: DBContextProviderProtocol {
  func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
    persistentContainer.performBackgroundTask(block)
  }

  func mainQueueContext() -> NSManagedObjectContext {
    self.mainContext
  }
}
