//
//  DependencyContainer.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 22.12.2021.
//

import Foundation

protocol HasDailyWaterIntakeStore {
  var dailyWaterIntakeStore: DailyWaterIntakeStoreProtocol { get }
}

struct DependencyContainer: HasDailyWaterIntakeStore {
  var dailyWaterIntakeStore: DailyWaterIntakeStoreProtocol

  static func make() -> DependencyContainer {
    return .init(dailyWaterIntakeStore: DailyWaterIntakeStore())
  }
}
