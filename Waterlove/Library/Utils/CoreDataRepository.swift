//
//  CoreDataRepository.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 23.12.2021.
//

import Foundation
import CoreData

enum DBRepositoryErrors: Error {
  case entityTypeError
  case noChangesInRepository
}

final class DBRepository<DomainModel, DBEntity>: Repository<DomainModel>, NSFetchedResultsControllerDelegate {
  private let associatedEntityName: String
  private let contextSource: DBContextProviderProtocol
  private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
  private let entityMapper: DBEntityMapper<DomainModel, DBEntity>

  init(contextSource: DBContextProviderProtocol, entityMapper: DBEntityMapper<DomainModel, DBEntity>, autoUpdateSearchRequest: RepositorySearchRequestProtocol? = nil) {
    self.contextSource = contextSource
    self.associatedEntityName = String(describing: DBEntity.self)
    self.entityMapper = entityMapper

    super.init()

    guard let request = autoUpdateSearchRequest else { return }

    self.fetchedResultsController = configureSearchedDataUpdating(request)
  }

  override func save(_ objects: [DomainModel], completion: @escaping ((Result<Void, Error>) -> Void)) {
    saveIn(data: objects, completion: completion)
  }

  override func present(by request: RepositorySearchRequestProtocol, completion: @escaping ((Result<[DomainModel], Error>) -> Void)) {
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: associatedEntityName)
    fetchRequest.predicate = request.predicate
    fetchRequest.sortDescriptors = request.sortDescriptors

    contextSource.performBackgroundTask { context in
      do {
        let rawData = try context.fetch(fetchRequest)

        guard !rawData.isEmpty else { return completion(.success([])) }

        guard let results = rawData as? [DBEntity] else {
          completion(.success([]))

          return
        }

        let converted = results.compactMap { return self.entityMapper.convert($0) }

        completion(.success(converted))
      } catch {
        completion(.failure(error))
      }
    }
  }

  override func delete(by request: RepositorySearchRequestProtocol, completion: @escaping ((Result<Void, Error>) -> Void)) {
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: associatedEntityName)
    fetchRequest.predicate = request.predicate
    fetchRequest.includesPropertyValues = false

    contextSource.performBackgroundTask { context in
      let results = try? context.fetch(fetchRequest)

      results?.forEach { context.delete($0) }

      self.applyChanges(context: context, completion: completion)
    }
  }

  // MARK: - Fetched Results Controller Delegate
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    guard let fetchedObjects = controller.fetchedObjects as? [DBEntity] else { return }

    updateObservableContent(fetchedObjects)
  }
}

private extension DBRepository {
  func saveIn(data: [DomainModel], completion: @escaping ((Result<Void, Error>) -> Void)) {
    contextSource.performBackgroundTask { context in
      var existingObjects: [UUID: DBEntity] = [:]
      let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: self.associatedEntityName)

      (try? context.fetch(fetchRequest) as? [DBEntity])?.forEach {
        let accessor = self.entityMapper.entityAccessorKey($0)
        existingObjects[accessor] = $0
      }

      data.forEach {
        let accessor = self.entityMapper.entityAccessorKey($0)
        let entityForUpdate: DBEntity? = existingObjects[accessor] ?? NSEntityDescription.insertNewObject(
          forEntityName: self.associatedEntityName,
          into: context
        ) as? DBEntity

        guard let entity = entityForUpdate else { return }

        self.entityMapper.update(entity, by: $0)
      }

      self.applyChanges(context: context, completion: completion)
    }
  }

  func applyChanges(context: NSManagedObjectContext, mergePolicy: Any = NSMergeByPropertyObjectTrumpMergePolicy, completion: ((Result<Void, Error>) -> Void)? = nil) {
    context.mergePolicy = mergePolicy

    switch context.hasChanges {
    case true:
      do {
        try context.save()
      } catch {
        print("Failed to save a context: \(error)")

        completion?(.failure(error))
      }

      completion?(.success(()))
    case false:
      completion?(.failure(DBRepositoryErrors.noChangesInRepository))
    }
  }

  func configureSearchedDataUpdating(_ request: RepositorySearchRequestProtocol) -> NSFetchedResultsController<NSFetchRequestResult> {
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: associatedEntityName)

    fetchRequest.predicate = request.predicate
    fetchRequest.sortDescriptors = request.sortDescriptors

    let fetchedResultsController = NSFetchedResultsController(
      fetchRequest: fetchRequest,
      managedObjectContext: contextSource.mainQueueContext(),
      sectionNameKeyPath: nil,
      cacheName: nil
    )

    fetchedResultsController.delegate = self

    try? fetchedResultsController.performFetch()

    if let content = fetchedResultsController.fetchedObjects as? [DBEntity] {
      updateObservableContent(content)
    }

    return fetchedResultsController
  }

  func updateObservableContent(_ content: [DBEntity]) {
    let converted = content.compactMap { return self.entityMapper.convert($0) }

    searchedData = converted
  }
}
