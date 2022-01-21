//
//  DependencyContainer.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 22.12.2021.
//

import Foundation
import UserNotifications

protocol HasWaterIntakeService {
  var waterIntakeService: WaterIntakeServiceProtocol { get }
}

protocol HasNotificationManager {
  var notificationManager: NotificationManagerProtocol { get }
}

struct DependencyContainer: HasWaterIntakeService, HasNotificationManager {
  var waterIntakeService: WaterIntakeServiceProtocol
  var notificationManager: NotificationManagerProtocol

  static func make() -> DependencyContainer {
    let notificationManager = NotificationManager(notificationCenter: UNUserNotificationCenter.current())

    return .init(waterIntakeService: WaterIntakeService(), notificationManager: notificationManager)
  }
}
