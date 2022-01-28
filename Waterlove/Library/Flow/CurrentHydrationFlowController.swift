//
//  CurrentHydrationFlowController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 27.12.2021.
//

import UIKit

final class CurrentHydrationFlowController: UIViewController {
  typealias Dependencies = HasWaterIntakeService

  private let waterIntakeService: WaterIntakeServiceProtocol

  private var embeddedNavigationController: UINavigationController?

  private lazy var currentHydrationVC: CurrentHydrationViewController? = {
    return R.storyboard.main.currentHydrationViewController()
  }()

  private lazy var saveIntakeEntryVC: SaveIntakeEntryViewController? = {
    return R.storyboard.main.saveIntakeEntryViewController()
  }()

  private var intakeEntryAmount: Measurement<UnitVolume> = .init(value: 0, unit: .milliliters) {
    didSet {
      if let controller = saveIntakeEntryVC {
        controller.props = makeSaveIntakeEntryProps()
      }
    }
  }

  private var drinkType = DrinkType.water {
    didSet {
      if let controller = saveIntakeEntryVC {
        controller.props = makeSaveIntakeEntryProps()
      }
    }
  }

  private var hydrationProgress = HydrationProgress(
    progress: 0,
    intookWaterAmount: .init(value: 0, unit: .milliliters),
    date: .now
  ) {
    didSet {
      if let controller = currentHydrationVC {
        controller.props = makeCurrentHydrationProps()
      }
    }
  }

  init(dependencies: Dependencies) {
    self.waterIntakeService = dependencies.waterIntakeService

    super.init(nibName: nil, bundle: nil)

    let navigationController = UINavigationController()
    add(childController: navigationController)
    self.embeddedNavigationController = navigationController
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    Task { await loadCurrentHydration() }
  }

  func start() {
    startCurrentHydration()
  }

  private func startCurrentHydration() {
    if let controller = currentHydrationVC {
      controller.props = makeCurrentHydrationProps()

      embeddedNavigationController?.viewControllers = [controller]
    }
  }

  private func loadCurrentHydration() async {
    let hydrationProgress = await waterIntakeService.getHydrationProgress()

    guard let hydrationProgress = hydrationProgress else { return }

    DispatchQueue.main.async { self.hydrationProgress = hydrationProgress }
  }

  private func startSaveIntakeEntry() {
    if let controller = saveIntakeEntryVC {
      controller.props = makeSaveIntakeEntryProps()

      embeddedNavigationController?.present(controller, animated: true, completion: nil)
    }
  }
}

// MARK: - Current Hydration Presenter
extension CurrentHydrationFlowController {
  private func makeCurrentHydrationProps() -> CurrentHydrationViewController.Props {
    return .init(
      hydrationProgressViewProps: .init(
        progressBarProps: .init(progress: hydrationProgress.progress),
        intookWaterAmount: hydrationProgress.intookWaterAmount
      ),
      didTapAddNewIntake: .init { [weak self] drinkType in
        self?.drinkType = drinkType
        self?.startSaveIntakeEntry()
      }
    )
  }
}

// MARK: - Save intake entry presenter
extension CurrentHydrationFlowController {
  private func makeSaveIntakeEntryProps() -> SaveIntakeEntryViewController.Props {
    return .init(
      amount: intakeEntryAmount,
      drinkType: drinkType,
      didSelectDrinkType: .init { [weak self] drinkType in
        self?.drinkType = drinkType
      },
      didTapNumpadButton: .init { [weak self] numpadButton in
        guard let self = self else { return }

        var stringValue = String(Int(self.intakeEntryAmount.value))

        switch numpadButton {
        case .delete:
          stringValue = stringValue.count == 1 ? "0" : String(stringValue.dropLast())
        default:
          stringValue = stringValue.appending(numpadButton.rawValue)
        }

        guard stringValue.count < 5 else { return }

        if let newValue = Double(stringValue) {
          self.intakeEntryAmount = .init(value: newValue, unit: .milliliters)
        }
      },
      didTapSaveButton: .init { [weak self] in
        guard let self = self else { return }

        guard self.intakeEntryAmount > .init(value: 0, unit: .milliliters) else {
          self.embeddedNavigationController?.dismiss(animated: true, completion: nil)

          return
        }

        Task {
          let newIntake = IntakeEntry(
            guid: UUID(),
            drinkType: self.drinkType,
            amount: self.intakeEntryAmount,
            createdAt: .now
          )

          let result = await self.waterIntakeService.saveIntakeEntry(newIntake)

          switch result {
          case .success:
            await self.loadCurrentHydration()

            DispatchQueue.main.async {
              self.intakeEntryAmount = .init(value: 0, unit: .milliliters)
              self.embeddedNavigationController?.dismiss(animated: true, completion: nil)
            }
          case .failure:
            print("Error saving new entry")
          }
        }
      }
    )
  }
}
