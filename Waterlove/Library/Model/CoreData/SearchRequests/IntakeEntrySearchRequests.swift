//
//  IntakeEntrySearchRequests.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 28.12.2021.
//

import Foundation

class IntakeEntrySpecificDateSearchRequest: RepositorySearchRequest {
  /// Initialize a new search request with a specific date range predicate
  /// - Parameters:
  ///   - startDate: start date to search for
  ///   - endDate: end date to search for
  ///   - sortDescriptors: sort descriptors
  convenience init(startDate: Date, endDate: Date, sortDescriptors: [NSSortDescriptor] = []) {
    let predicate = NSPredicate(format: "createdAt >= %@ AND createdAt < %@", argumentArray: [startDate, endDate])

    self.init(predicate: predicate, sortDescriptors: sortDescriptors)
  }

  /// Initialize a new search request with a current day date range predicate.
  /// Sorted descending by date.
  convenience init() {
    var calendar = Calendar.current
    calendar.timeZone = NSTimeZone.local

    let startDate = calendar.startOfDay(for: Date())
    let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? .now

    let sort = NSSortDescriptor(key: "createdAt", ascending: false)

    self.init(startDate: startDate, endDate: endDate, sortDescriptors: [sort])
  }
}
