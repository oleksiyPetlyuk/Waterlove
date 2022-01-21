//
//  MainFlowController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 08.12.2021.
//

import UIKit

final class MainFlowController: UIViewController {
  typealias Dependencies = HasWaterIntakeService & HasNotificationManager

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
    let settingsController = SettingsFlowController(dependencies: dependencies)

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
    dependencies.notificationManager.requestAuthorization { [weak self] granted in
      guard let self = self else { return }

      if granted {
        let isNotificationsEnabled = UserDefaults
          .standard
          .bool(forKey: NotificationManagerConstants.isNotificationsEnabledKey)

        if isNotificationsEnabled {
          self.dependencies.notificationManager.scheduleNotifications()

          return
        }
      }

      self.dependencies.notificationManager.removeScheduledNotifications()
    }
  }
}
