//
//  OnboardingFlowController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 07.12.2021.
//

import UIKit

final class OnboardingFlowController: UIViewController {
  typealias Dependencies = HasDailyWaterIntakeStore

  let dependencies: Dependencies

  private var embeddedNavigationController: UINavigationController?

  private lazy var waterIntakeCalculatorVC: WaterIntakeCalculatorViewController? = {
    return R.storyboard.main.waterIntakeCalculatorViewController()
  }()

  private lazy var tutorialVC: TutorialViewController? = {
    return R.storyboard.main.tutorialViewController()
  }()

  private var selectedTutorialPageIndex = 0 {
    didSet {
      if let controller = tutorialVC {
        controller.props = makeTutorialProps()
      }
    }
  }

  private var gender = WaterIntakeCalculator.Gender.male {
    didSet {
      if let controller = waterIntakeCalculatorVC {
        controller.props = makeWaterIntakeCalculatorProps()
      }
    }
  }

  private var weight: Measurement<UnitMass> = .init(value: 75, unit: .kilograms) {
    didSet {
      if let controller = waterIntakeCalculatorVC {
        controller.props = makeWaterIntakeCalculatorProps()
      }
    }
  }

  var didFinishOnboarding: (() -> Void)?

  init(dependencies: Dependencies) {
    self.dependencies = dependencies

    super.init(nibName: nil, bundle: nil)

    let navigationController = UINavigationController()
    add(childController: navigationController)
    self.embeddedNavigationController = navigationController
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func start() {
    startTutorial()
  }

  private func startTutorial() {
    if let controller = tutorialVC {
      controller.props = makeTutorialProps()

      embeddedNavigationController?.viewControllers = [controller]
    }
  }

  private func startWaterIntakeCalculator() {
    if let controller = waterIntakeCalculatorVC {
      controller.props = makeWaterIntakeCalculatorProps()

      embeddedNavigationController?.pushViewController(controller, animated: true)
    }
  }
}

// MARK: - Tutorial Presenter
extension OnboardingFlowController {
  private func makeTutorialProps() -> TutorialViewController.Props {
    return .init(
      pageViewControllerProps: .init(
        pages: [
          .init(
            id: 1,
            image: "bottle",
            heading: "Concentration Ability and Brain Activity",
            subheading: """
            A healthy habit to drink water during the day helps to maintain concentration and keep your brain active
            """
          ),
          .init(
            id: 2,
            image: "mirror",
            heading: "Beauty and Health",
            subheading: """
            Drinking enough water has a favourable effect on the body helping to retain beauty from inside
            """
          ),
          .init(
            id: 3,
            image: "cup",
            heading: "Being Fit",
            subheading: """
            A glass of water before a meal not only boosts your metabolism but also helps eating less
            """
          )
        ],
        selectedPageIndex: selectedTutorialPageIndex,
        didUpdatePageIndex: .init { [weak self] index in
          self?.selectedTutorialPageIndex = index
        }
      ),
      didTapNextButton: .init { [weak self] in
        self?.selectedTutorialPageIndex += 1
      },
      didChangePageControlValue: .init { [weak self] page in
        self?.selectedTutorialPageIndex = page
      },
      didFinishTutorial: .init { [weak self] in
        self?.startWaterIntakeCalculator()
      }
    )
  }
}

// MARK: - Water Intake Calculator Presenter
extension OnboardingFlowController {
  private func makeWaterIntakeCalculatorProps() -> WaterIntakeCalculatorViewController.Props {
    let waterIntakeCalc = WaterIntakeCalculator()
    let waterAmount = waterIntakeCalc.calculate(gender: gender, weight: weight)

    return .init(
      totalWaterAmount: waterAmount,
      gender: .init(value: gender, didUpdate: .init { [weak self] newValue in
        self?.gender = newValue
      }),
      weight: .init(value: weight, didUpdate: .init { [weak self] newValue in
        self?.weight = newValue
      }),
      didSaveWaterIntakeResults: .init { [weak self] in
        guard let self = self else { return }

        self.dependencies.dailyWaterIntakeStore.storeDailyIntake(waterAmount)

        if let controller = self.waterIntakeCalculatorVC {
          self.remove(childController: controller)

          self.didFinishOnboarding?()
        }
      }
    )
  }
}
