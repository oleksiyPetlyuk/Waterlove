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
  convenience init(startDate: Date, endDate: Date) {
    let predicate = NSPredicate(format: "createdAt >= %@ AND createdAt < %@", argumentArray: [startDate, endDate])

    self.init(predicate: predicate, sortDescriptors: [])
  }

  /// Initialize a new search request with a current day date range predicate
  convenience init() {
    var calendar = Calendar.current
    calendar.timeZone = NSTimeZone.local

    let startDate = calendar.startOfDay(for: Date())
    let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? .now

    self.init(startDate: startDate, endDate: endDate)
  }
}
