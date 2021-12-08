//
//  AppFlowController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 07.12.2021.
//

import UIKit

final class AppFlowController: UIViewController {
  /// Start the flow
  func start() {
    startTutorial()
  }

  private func startTutorial() {
    let onboardingFlow = OnboardingFlowController()

    onboardingFlow.onBoardingDidFinish = { [weak self] in
      self?.remove(childController: onboardingFlow)
      self?.startMain()
    }

    add(childController: onboardingFlow)
    onboardingFlow.start()
  }

  private func startMain() {
    let mainFlow = MainFlowController()

    add(childController: mainFlow)
    mainFlow.start()
  }
}
