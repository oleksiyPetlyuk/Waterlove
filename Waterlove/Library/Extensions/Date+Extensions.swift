//
//  Date+Extensions.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 04.01.2022.
//

import Foundation

extension Date {
  func startOfWeek(using calendar: Calendar = .current) -> Date {
    guard let interval = calendar.dateInterval(of: .weekOfYear, for: self) else { return self }

    return interval.start
  }

  func endOfWeek(using calendar: Calendar = .current) -> Date {
    guard let interval = calendar.dateInterval(of: .weekOfYear, for: self) else { return self }

    return interval.end
  }

  func startOfMonth(using calendar: Calendar = .current) -> Date {
    guard let interval = calendar.dateInterval(of: .month, for: self) else { return self }

    return interval.start
  }

  func endOfMonth(using calendar: Calendar = .current) -> Date {
    guard let interval = calendar.dateInterval(of: .month, for: self) else { return self }

    return interval.end
  }
}
