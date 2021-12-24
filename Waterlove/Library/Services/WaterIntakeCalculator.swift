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

  /// Calculates daily water intake based on gender and weight
  /// - Parameters:
  ///   - gender: Represents a gender (male or female)
  ///   - weight: Represents a weight in kilograms
  /// - Returns: Daily water intake in millilitres
  func calculate(gender: Gender, weight: UInt8) -> UInt {
    if gender == .male {
      return UInt(Double(weight) * 0.035 * 1000)
    }

    return UInt(Double(weight) * 0.031 * 1000)
  }
}
