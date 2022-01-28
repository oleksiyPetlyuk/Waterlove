//
//  SceneDelegate.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 03.12.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  let appFlowController = AppFlowController(dependencyContainer: DependencyContainer.make())

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }

    window = UIWindow(windowScene: windowScene)
    window?.makeKeyAndVisible()
    window?.rootViewController = appFlowController

    appFlowController.start()
  }
}
