//
//  WaterIntakeCalculator.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 09.12.2021.
//

import Foundation

class WaterIntakeCalculator {
  enum Gender {
    case male, female
  }

  func calculate(gender: Gender, weight: UInt8) -> Float {
    if gender == .male {
      return Float(weight) * 0.035
    }

    return Float(weight) * 0.031
  }
}
