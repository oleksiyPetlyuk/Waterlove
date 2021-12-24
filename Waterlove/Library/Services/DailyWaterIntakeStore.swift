//
//  DailyWaterIntakeStore.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 22.12.2021.
//

import Foundation

protocol DailyWaterIntakeStoreProtocol {
  func storeDailyIntake(_ amount: UInt)

  func getDailyIntake() -> UInt?
}

class DailyWaterIntakeStore: DailyWaterIntakeStoreProtocol {
  private let defaults = UserDefaults.standard
  private let key = "dailyWaterIntake"

  func storeDailyIntake(_ amount: UInt) {
    defaults.set(amount, forKey: key)
  }

  func getDailyIntake() -> UInt? {
    let amount = defaults.integer(forKey: key)

    return amount == 0 ? nil : UInt(amount)
  }
}
