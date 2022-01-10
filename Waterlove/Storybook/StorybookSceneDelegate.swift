//
//  StorybookSceneDelegate.swift
//  Waterlove Storybook
//
//  Created by Oleksiy Petlyuk on 06.01.2022.
//

import UIKit

class StorybookSceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  let storybookFlowController = StorybookFlowController()

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }

    window = UIWindow(windowScene: windowScene)
    window?.makeKeyAndVisible()
    window?.rootViewController = storybookFlowController

    storybookFlowController.start()
  }
}
