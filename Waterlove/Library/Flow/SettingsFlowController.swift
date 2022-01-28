//
//  SettingsFlowController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 11.01.2022.
//

import UIKit

final class SettingsFlowController: UIViewController {
  typealias Dependencies = HasNotificationManager & HasSettingsService

  private let notificationManager: NotificationManagerProtocol

  private var settingsService: SettingsServiceProtocol

  private var embeddedNavigationController: UINavigationController?

  private lazy var settingsVC: SettingsViewController? = {
    return R.storyboard.main.settingsViewController()
  }()

  private lazy var isNotificationsEnabled = settingsService.isNotificationsEnabled {
    didSet {
      if let controller = settingsVC {
        controller.props = makeProps()
      }
    }
  }

  init(dependencies: Dependencies) {
    self.notificationManager = dependencies.notificationManager
    self.settingsService = dependencies.settingsService

    super.init(nibName: nil, bundle: nil)

    let navigationController = UINavigationController()
    navigationController.navigationBar.prefersLargeTitles = true
    add(childController: navigationController)
    self.embeddedNavigationController = navigationController
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func start() {
    if let controller = settingsVC {
      controller.props = makeProps()

      embeddedNavigationController?.viewControllers = [controller]
    }
  }

  private func makeProps() -> SettingsViewController.Props {
    return .init(isNotificationsEnabled: .init(
      value: isNotificationsEnabled,
      didUpdate: .init { [weak self] isEnabled in
        guard let self = self else { return }

        self.settingsService.isNotificationsEnabled = isEnabled

        if isEnabled {
          self.notificationManager.scheduleNotifications()
        } else {
          self.notificationManager.removeScheduledNotifications()
        }

        self.isNotificationsEnabled = isEnabled
      })
    )
  }
}
