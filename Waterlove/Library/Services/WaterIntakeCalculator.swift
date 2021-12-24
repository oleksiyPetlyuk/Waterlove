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
  ///   - weight: Represents a weight
  /// - Returns: Daily water intake
  func calculate(gender: Gender, weight: Measurement<UnitMass>) -> Measurement<UnitVolume> {
    if gender == .male {
      return .init(value: (weight.converted(to: .kilograms) * 35).value, unit: .milliliters)
    }

    return .init(value: (weight.converted(to: .kilograms) * 31).value, unit: .milliliters)
  }
}
