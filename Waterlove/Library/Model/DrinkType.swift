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
