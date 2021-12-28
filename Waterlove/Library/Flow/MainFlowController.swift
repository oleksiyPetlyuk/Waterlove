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
    let historyController = R.storyboard.main.historyViewController()
    let settingsController = R.storyboard.main.settingsViewController()

    if
      let historyController = historyController,
      let settingsController = settingsController {
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
      currentHydrationController.start()
    }
  }
}
