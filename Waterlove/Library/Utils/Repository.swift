//
//  Repository.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 23.12.2021.
//

import Foundation

// MARK: - Repository protocol
protocol RepositoryProtocol {
  associatedtype DomainModel

  var searchedData: [DomainModel] { get }

  func save(_ objects: [DomainModel], completion: @escaping ((Result<Void, Error>) -> Void))

  func present(by request: RepositorySearchRequestProtocol, completion: @escaping ((Result<[DomainModel], Error>) -> Void))

  func delete(by request: RepositorySearchRequestProtocol, completion: @escaping ((Result<Void, Error>) -> Void))
}

protocol RepositorySearchRequestProtocol {
  var predicate: NSPredicate? { get }
  var sortDescriptors: [NSSortDescriptor] { get }
}

class RepositorySearchRequest: RepositorySearchRequestProtocol {
  var predicate: NSPredicate?
  var sortDescriptors: [NSSortDescriptor]

  init(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor] = []) {
    self.predicate = predicate
    self.sortDescriptors = sortDescriptors
  }
}

// MARK: - Default Repository implementation
class Repository<DomainModel>: NSObject, RepositoryProtocol {
  typealias DomainModel = DomainModel

  @Published var searchedData: [DomainModel] = []

  func save(_ objects: [DomainModel], completion: @escaping ((Result<Void, Error>) -> Void)) {
    fatalError("save(_ objects: must be overridden")
  }

  func present(by request: RepositorySearchRequestProtocol, completion: @escaping ((Result<[DomainModel], Error>) -> Void)) {
    fatalError("present(by request: must be overridden")
  }

  func delete(by request: RepositorySearchRequestProtocol, completion: @escaping ((Result<Void, Error>) -> Void)) {
    fatalError("delete(by request: must be overridden")
  }
}
