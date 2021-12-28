//
//  DrinkType.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 22.12.2021.
//

import Foundation

enum DrinkType: String {
  case water
  case coffee
  case tea
  case juice

  /// Indicates the amount of water in different drink types (e.g. 100 ml of coffee contains 30 ml of water)
  var waterAmountMultiplier: Double {
    switch self {
    case .water: return 1
    case .coffee: return 0.3
    case .tea: return 0.8
    case .juice: return 0.2
    }
  }

  init?(tag: Int) {
    switch tag {
    case 0: self = .water
    case 1: self = .coffee
    case 2: self = .tea
    case 3: self = .juice
    default: return nil
    }
  }
}
