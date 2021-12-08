//
//  OnboardingFlowController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 07.12.2021.
//

import UIKit

final class OnboardingFlowController: UIViewController {
  private var embeddedNavigationController: UINavigationController?

  var onBoardingDidFinish: (() -> Void)?

  init() {
    super.init(nibName: nil, bundle: nil)

    let navigationController = UINavigationController()
    add(childController: navigationController)
    self.embeddedNavigationController = navigationController
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  func start() {
    startTutorial()
  }

  private func startTutorial() {
    if let controller = R.storyboard.main.tutorialViewController() {
      controller.didFinishTutorial = { [weak self] in
        self?.startWaterIntakeCalculator()
      }

      embeddedNavigationController?.viewControllers = [controller]
    }
  }

  private func startWaterIntakeCalculator() {
    if let controller = R.storyboard.main.waterIntakeCalculatorViewController() {
      controller.saveWaterIntakeResultsHandler = { [weak self] in
        self?.remove(childController: controller)

        if let onBoardingDidFinish = self?.onBoardingDidFinish {
          onBoardingDidFinish()
        }
      }

      embeddedNavigationController?.pushViewController(controller, animated: true)
    }
  }
}
