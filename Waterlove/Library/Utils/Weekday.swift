//
//  Weekday.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 06.01.2022.
//

import Foundation

enum Weekday: Int, CaseIterable {
  case sunday = 1
  case monday = 2
  case tuesday = 3
  case wednesday = 4
  case thursday = 5
  case friday = 6
  case saturday = 7

  var shortDescription: String {
    switch self {
    case .sunday: return "S"
    case .monday: return "M"
    case .tuesday: return "T"
    case .wednesday: return "W"
    case .thursday: return "T"
    case .friday: return "F"
    case .saturday: return "S"
    }
  }
}
