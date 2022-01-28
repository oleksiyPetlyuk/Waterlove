//
//  AppFlowController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 07.12.2021.
//

import UIKit

final class AppFlowController: UIViewController {
  private let dependencyContainer: DependencyContainer

  private var settingsService: SettingsServiceProtocol

  init(dependencyContainer: DependencyContainer) {
    self.dependencyContainer = dependencyContainer
    self.settingsService = dependencyContainer.settingsService

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Start the flow
  func start() {
    settingsService.isUserDidFinishTutorial ? startMain() : startTutorial()
  }

  private func startTutorial() {
    let onboardingFlow = OnboardingFlowController(dependencies: dependencyContainer)

    onboardingFlow.didFinishOnboarding = { [weak self] in
      guard let self = self else { return }

      self.settingsService.isUserDidFinishTutorial = true
      self.remove(childController: onboardingFlow)
      self.startMain()
    }

    add(childController: onboardingFlow)
    onboardingFlow.start()
  }

  private func startMain() {
    let mainFlow = MainFlowController(dependencies: dependencyContainer)

    add(childController: mainFlow)
    mainFlow.start()
  }
}
