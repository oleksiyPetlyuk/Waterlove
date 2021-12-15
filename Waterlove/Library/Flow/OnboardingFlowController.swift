//
//  OnboardingFlowController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 07.12.2021.
//

import UIKit

final class OnboardingFlowController: UIViewController {
  private var embeddedNavigationController: UINavigationController?

  private lazy var waterIntakeCalculatorVC: WaterIntakeCalculatorViewController? = {
    return R.storyboard.main.waterIntakeCalculatorViewController()
  }()

  private lazy var tutorialVC: TutorialViewController? = {
    return R.storyboard.main.tutorialViewController()
  }()

  var onboardingDidFinish: (() -> Void)?

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
    if let controller = tutorialVC {
      controller.render(makeTutorialProps())

      embeddedNavigationController?.viewControllers = [controller]
    }
  }

  private func startWaterIntakeCalculator() {
    if let controller = waterIntakeCalculatorVC {
      let props = makeProps(gender: controller.props.gender.value, weight: controller.props.weight.value)

      controller.render(props)

      embeddedNavigationController?.pushViewController(controller, animated: true)
    }
  }
}

// MARK: - Tutorial Presenter
extension OnboardingFlowController {
  private func makeTutorialProps() -> TutorialViewController.Props {
    return .init(onDidFinishTutorial: .init(action: startWaterIntakeCalculator))
  }
}

// MARK: - Water Intake Calculator Presenter
extension OnboardingFlowController {
  private func makeProps(gender: WaterIntakeCalculator.Gender, weight: UInt8) -> WaterIntakeCalculatorViewController.Props {
    let waterIntakeCalc = WaterIntakeCalculator()
    let waterAmount = waterIntakeCalc.calculate(gender: gender, weight: weight)

    return .init(
      totalWaterAmount: waterAmount,
      gender: .init(value: gender, onUpdate: .init(action: onGenderValueChanged(_:))),
      weight: .init(value: weight, onUpdate: .init(action: onWeightValueChanged(_:))),
      onSaveWaterIntakeResults: .init(action: onSaveWaterIntakeResults)
    )
  }

  func onGenderValueChanged(_ newValue: WaterIntakeCalculator.Gender) {
    guard let controller = waterIntakeCalculatorVC else { return }

    let props = makeProps(gender: newValue, weight: controller.props.weight.value)

    controller.render(props)
  }

  func onWeightValueChanged(_ newValue: UInt8) {
    guard let controller = waterIntakeCalculatorVC else { return }

    let props = makeProps(gender: controller.props.gender.value, weight: newValue)

    controller.render(props)
  }

  func onSaveWaterIntakeResults() {
    guard let controller = waterIntakeCalculatorVC else { return }

    remove(childController: controller)

    onboardingDidFinish?()
  }
}
