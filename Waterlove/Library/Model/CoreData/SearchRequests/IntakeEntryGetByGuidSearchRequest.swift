//
//  IntakeEntryGetByGuidSearchRequest.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 05.01.2022.
//

import Foundation

class IntakeEntryGetByGuidSearchRequest: RepositorySearchRequest {
  /// Initialize a new search request with a search by guid predicate
  /// - Parameter guids: Array of guid to search for
  convenience init(guids: [UUID]) {
    let predicate = NSPredicate(format: "guid IN %@", guids)

    self.init(predicate: predicate, sortDescriptors: [])
  }
}
