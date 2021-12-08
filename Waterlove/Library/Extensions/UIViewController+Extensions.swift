//
//  UIViewController+Extensions.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 07.12.2021.
//

import UIKit

extension UIViewController {
  /// Add child view controller and its view
  func add(childController: UIViewController) {
    addChild(childController)
    view.addSubview(childController.view)
    childController.didMove(toParent: self)
  }

  /// Remove child view controller and its view
  func remove(childController: UIViewController) {
    childController.willMove(toParent: nil)
    childController.view.removeFromSuperview()
    childController.removeFromParent()
  }
}
