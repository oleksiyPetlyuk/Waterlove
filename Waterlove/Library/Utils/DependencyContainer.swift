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

protocol HasSettingsService {
  var settingsService: SettingsServiceProtocol { get }
}

protocol HasWatchConnectivityService {
  var watchConnectivityService: WatchConnectivityServiceProtocol { get }
}

struct DependencyContainer: HasWaterIntakeService,
                            HasNotificationManager, // swiftlint:disable:this indentation_width
                            HasSettingsService,
                            HasWatchConnectivityService {
  var waterIntakeService: WaterIntakeServiceProtocol
  var notificationManager: NotificationManagerProtocol
  var settingsService: SettingsServiceProtocol
  var watchConnectivityService: WatchConnectivityServiceProtocol

  static func make() -> DependencyContainer {
    let notificationManager = NotificationManager(notificationCenter: UNUserNotificationCenter.current())
    let watchConnectivityService = WatchConnectivityService()

    return .init(
      waterIntakeService: WaterIntakeService(watchConnectivityService: watchConnectivityService),
      notificationManager: notificationManager,
      settingsService: SettingsService.shared,
      watchConnectivityService: watchConnectivityService
    )
  }
}
