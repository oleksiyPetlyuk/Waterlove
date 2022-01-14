//
//  DependencyContainer.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 22.12.2021.
//

import Foundation
import UserNotifications

protocol HasDailyWaterIntakeStore {
  var dailyWaterIntakeStore: DailyWaterIntakeStoreProtocol { get }
}

protocol HasNotificationManager {
  var notificationManager: NotificationManagerProtocol { get }
}

struct DependencyContainer: HasDailyWaterIntakeStore, HasNotificationManager {
  var dailyWaterIntakeStore: DailyWaterIntakeStoreProtocol
  var notificationManager: NotificationManagerProtocol

  static func make() -> DependencyContainer {
    let notificationManager = NotificationManager(notificationCenter: UNUserNotificationCenter.current())

    return .init(dailyWaterIntakeStore: DailyWaterIntakeStore(), notificationManager: notificationManager)
  }
}
