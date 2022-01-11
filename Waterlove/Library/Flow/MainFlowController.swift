//
//  MainFlowController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 08.12.2021.
//

import UIKit

final class MainFlowController: UIViewController {
  typealias Dependencies = HasDailyWaterIntakeStore

  let dependencies: Dependencies

  private var embeddedTabBarController: UITabBarController?

  init(dependencies: Dependencies) {
    self.dependencies = dependencies

    super.init(nibName: nil, bundle: nil)

    let tabBarController = UITabBarController()
    add(childController: tabBarController)
    self.embeddedTabBarController = tabBarController
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func start() {
    let currentHydrationController = CurrentHydrationFlowController(dependencies: dependencies)
    let historyController = HistoryFlowController(dependencies: dependencies)
    let settingsController = SettingsFlowController()

    historyController.tabBarItem = UITabBarItem(
      title: "History",
      image: UIImage(systemName: "clock"),
      selectedImage: nil
    )
    currentHydrationController.tabBarItem = UITabBarItem(
      title: "Current Hydration",
      image: UIImage(systemName: "heart.fill"),
      selectedImage: nil
    )
    settingsController.tabBarItem = UITabBarItem(
      title: "Settings",
      image: UIImage(systemName: "gear"),
      selectedImage: nil
    )

    embeddedTabBarController?.viewControllers = [historyController, currentHydrationController, settingsController]
    embeddedTabBarController?.selectedViewController = currentHydrationController

    historyController.start()
    currentHydrationController.start()
    settingsController.start()

    configureUserNotifications()
  }

  private func configureUserNotifications() {
    NotificationManager.shared.requestAuthorization { granted in
      if granted {
        let isNotificationsEnabled = UserDefaults
          .standard
          .bool(forKey: NotificationManagerConstants.isNotificationsEnabledKey)

        if isNotificationsEnabled {
          NotificationManager.shared.scheduleNotifications()

          return
        }
      }

      NotificationManager.shared.removeScheduledNotifications()
    }
  }
}
