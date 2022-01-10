//
//  StorybookFlowController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 06.01.2022.
//

import UIKit

final class StorybookFlowController: UIViewController {
  private var embeddedNavigationController: UINavigationController?

  init() {
    super.init(nibName: nil, bundle: nil)

    let navigationController = UINavigationController()
    add(childController: navigationController)
    self.embeddedNavigationController = navigationController
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func start() {
    let controller = StorybookTableViewController(nibName: nil, bundle: nil)

    embeddedNavigationController?.viewControllers = [controller]
  }
}
