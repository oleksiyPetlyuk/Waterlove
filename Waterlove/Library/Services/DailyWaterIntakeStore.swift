//
//  DailyWaterIntakeStore.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 22.12.2021.
//

import Foundation

protocol DailyWaterIntakeStoreProtocol {
  func storeDailyIntake(_ amount: Measurement<UnitVolume>)

  func getDailyIntake() -> Measurement<UnitVolume>?
}

class DailyWaterIntakeStore: DailyWaterIntakeStoreProtocol {
  private let defaults = UserDefaults.standard
  private let key = "dailyWaterIntake"

  func storeDailyIntake(_ amount: Measurement<UnitVolume>) {
    defaults.set(try? PropertyListEncoder().encode(amount), forKey: key)
  }

  func getDailyIntake() -> Measurement<UnitVolume>? {
    guard let data = defaults.value(forKey: key) as? Data else { return nil }

    return try? PropertyListDecoder().decode(Measurement<UnitVolume>.self, from: data)
  }
}
