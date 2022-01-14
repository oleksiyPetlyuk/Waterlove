//
//  SettingsFlowController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 11.01.2022.
//

import UIKit

final class SettingsFlowController: UIViewController {
  typealias Dependencies = HasNotificationManager

  let dependencies: Dependencies

  private var embeddedNavigationController: UINavigationController?

  private lazy var settingsVC: SettingsViewController? = {
    return R.storyboard.main.settingsViewController()
  }()

  // swiftlint:disable:next line_length
  private var isNotificationsEnabled: Bool = UserDefaults.standard.bool(forKey: NotificationManagerConstants.isNotificationsEnabledKey) {
    didSet {
      if let controller = settingsVC {
        controller.props = makeProps()
      }
    }
  }

  init(dependencies: Dependencies) {
    self.dependencies = dependencies

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

        UserDefaults.standard.set(isEnabled, forKey: NotificationManagerConstants.isNotificationsEnabledKey)

        if isEnabled {
          self.dependencies.notificationManager.scheduleNotifications()
        } else {
          self.dependencies.notificationManager.removeScheduledNotifications()
        }

        self.isNotificationsEnabled = isEnabled
      })
    )
  }
}
