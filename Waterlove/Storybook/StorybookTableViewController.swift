//
//  StorybookTableViewController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 06.01.2022.
//

import UIKit

class StorybookTableViewController: UITableViewController {
  let stories: [(title: String, states: [String])] = [
    (title: "Tutorial", states: ["page-1", "page-2", "page-3"]),
    (title: "Water Intake Calculator", states: ["default"]),
    (title: "Current Hydration", states: ["empty", "50%", "100%"]),
    (title: "Add new intake", states: ["default", "tea-150"]),
    (title: "History", states: ["loading", "empty", "list", "error"])
  ]

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.title = "Storybook"

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "storybookCell")
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return stories.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return stories[section].states.count
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return stories[section].title
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "storybookCell", for: indexPath)
    cell.textLabel?.text = stories[indexPath.section].states[indexPath.row]

    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch stories[indexPath.section].title {
    case "Tutorial": tutorialState(for: indexPath)
    case "Water Intake Calculator": waterIntakeCalculatorState(for: indexPath)
    case "Current Hydration": currentHydrationState(for: indexPath)
    case "Add new intake": saveIntakeEntryState(for: indexPath)
    case "History": historyState(for: indexPath)
    default: break
    }
  }
}

// MARK: - Storybook States
private extension StorybookTableViewController {
  func tutorialState(for indexPath: IndexPath) {
    guard let controller = R.storyboard.main.tutorialViewController() else { return }

    switch stories[indexPath.section].states[indexPath.row] {
    case "page-1": controller.props = .page1
    case "page-2": controller.props = .page2
    case "page-3": controller.props = .page3
    default: break
    }

    navigationController?.pushViewController(controller, animated: true)
  }

  func waterIntakeCalculatorState(for indexPath: IndexPath) {
    guard let controller = R.storyboard.main.waterIntakeCalculatorViewController() else { return }

    switch stories[indexPath.section].states[indexPath.row] {
    case "default": controller.props = .initial
    default: break
    }

    navigationController?.pushViewController(controller, animated: true)
  }

  func currentHydrationState(for indexPath: IndexPath) {
    guard let controller = R.storyboard.main.currentHydrationViewController() else { return }

    switch stories[indexPath.section].states[indexPath.row] {
    case "empty": controller.props = .initial
    case "50%": controller.props = .halfProgress
    case "100%": controller.props = .fullProgress
    default: break
    }

    navigationController?.pushViewController(controller, animated: true)
  }

  func saveIntakeEntryState(for indexPath: IndexPath) {
    guard let controller = R.storyboard.main.saveIntakeEntryViewController() else { return }

    switch stories[indexPath.section].states[indexPath.row] {
    case "default": controller.props = .initial
    case "tea-150": controller.props = .tea
    default: break
    }

    navigationController?.pushViewController(controller, animated: true)
  }

  func historyState(for indexPath: IndexPath) {
    guard let controller = R.storyboard.main.historyViewController() else { return }

    let stateMachine = HistoryStateMachine()
    stateMachine.observer = controller

    switch stories[indexPath.section].states[indexPath.row] {
    case "loading": stateMachine.transition(with: .startLoading)
    case "empty":
      stateMachine.transition(with: .startLoading)
      stateMachine.transition(with: .loadingFinished(.init(
        entries: [],
        searchInterval: .week,
        recommendedDailyAmount: .init(value: 3000, unit: .milliliters),
        didChangeSearchInterval: .nop))
      )
    case "list":
      guard let path = Bundle.main.path(forResource: "example_entries", ofType: "json") else { return }

      do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let entries: [IntakeEntry] = try JSONDecoder().decode([IntakeEntry].self, from: data)

        stateMachine.transition(with: .startLoading)
        stateMachine.transition(with: .loadingFinished(.init(
          entries: entries.map { entry in
            return .init(
              id: entry.guid,
              drinkType: entry.drinkType,
              amount: entry.amount,
              waterAmount: entry.waterAmount,
              createdAt: entry.createdAt,
              canEdit: true,
              didDelete: .nop
            )
          },
          searchInterval: .week,
          recommendedDailyAmount: .init(value: 3000, unit: .milliliters),
          didChangeSearchInterval: .nop))
        )
      } catch {
        print("Error decoding entries: \(error)")
      }
    case "error":
      enum LoadingError: Error, LocalizedError {
        case test

        var errorDescription: String? {
          "Some error message"
        }
      }

      stateMachine.transition(with: .startLoading)
      stateMachine.transition(with: .loadingFailed(LoadingError.test))
    default: break
    }

    navigationController?.pushViewController(controller, animated: true)
  }
}

// MARK: - Tutorial View Controller Props
private extension TutorialViewController.Props {
  static let page1: Self = .init(
    pageViewControllerProps: .init(
      pages: [
        .init(
          id: 1,
          image: "bottle",
          heading: "Concentration Ability and Brain Activity",
          subheading: """
          A healthy habit to drink water during the day helps to maintain concentration and keep your brain active
          """
        )
      ],
      selectedPageIndex: 0,
      didUpdatePageIndex: .nop
    ),
    didTapNextButton: .nop,
    didChangePageControlValue: .nop,
    didFinishTutorial: .nop
  )

  static let page2: Self = .init(
    pageViewControllerProps: .init(
      pages: [
        .init(
          id: 2,
          image: "mirror",
          heading: "Beauty and Health",
          subheading: """
          Drinking enough water has a favourable effect on the body helping to retain beauty from inside
          """
        )
      ],
      selectedPageIndex: 0,
      didUpdatePageIndex: .nop
    ),
    didTapNextButton: .nop,
    didChangePageControlValue: .nop,
    didFinishTutorial: .nop
  )

  static let page3: Self = .init(
    pageViewControllerProps: .init(
      pages: [
        .init(
          id: 3,
          image: "cup",
          heading: "Being Fit",
          subheading: """
          A glass of water before a meal not only boosts your metabolism but also helps eating less
          """
        )
      ],
      selectedPageIndex: 0,
      didUpdatePageIndex: .nop
    ),
    didTapNextButton: .nop,
    didChangePageControlValue: .nop,
    didFinishTutorial: .nop
  )
}

// MARK: - Current Hydration View Controller Props
private extension CurrentHydrationViewController.Props {
  static let halfProgress: Self = .init(
    hydrationProgressViewProps: .init(
      progressBarProps: .init(progress: 50),
      intookWaterAmount: .init(value: 1500, unit: .milliliters)
    ),
    didTapAddNewIntake: .nop
  )

  static let fullProgress: Self = .init(
    hydrationProgressViewProps: .init(
      progressBarProps: .init(progress: 100),
      intookWaterAmount: .init(value: 3000, unit: .milliliters)
    ),
    didTapAddNewIntake: .nop
  )
}

// MARK: - Save Intake Entry View Controller Props
private extension SaveIntakeEntryViewController.Props {
  static let tea: Self = .init(
    amount: .init(value: 150, unit: .milliliters),
    drinkType: .tea,
    didSelectDrinkType: .nop,
    didTapNumpadButton: .nop,
    didTapSaveButton: .nop
  )
}
