//
//  HistoryFlowController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 04.01.2022.
//

import UIKit

final class HistoryFlowController: UIViewController {
  typealias Dependencies = HasWaterIntakeService

  let dependencies: Dependencies

  private var embeddedNavigationController: UINavigationController?

  private var historyStateMachine = HistoryStateMachine()

  private lazy var historyVC: HistoryViewController? = {
    guard let controller = R.storyboard.main.historyViewController() else { return nil }

    historyStateMachine.observer = controller

    return controller
  }()

  private var searchInterval = SearchInterval.week {
    didSet {
      Task { await loadHistory() }
    }
  }

  private var entries: [IntakeEntry] = [] {
    didSet {
      historyStateMachine.transition(with: .loadingFinished(makeHistoryLoadedProps()))
    }
  }

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

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    Task { await loadHistory() }
  }

  func start() {
    startHistory()
  }

  private func startHistory() {
    if let controller = historyVC {
      Task { await loadHistory() }

      embeddedNavigationController?.viewControllers = [controller]
    }
  }
}

private extension HistoryFlowController {
  func makeHistoryLoadedProps() -> HistoryViewController.Props {
    let entries: [HistoryViewController.Props.Entry] = entries.map { entry in
      return .init(
        id: entry.guid,
        drinkType: entry.drinkType,
        amount: entry.amount,
        waterAmount: entry.waterAmount,
        createdAt: entry.createdAt,
        canEdit: true,
        didDelete: .init { [weak self] in
          guard let self = self else { return }

          Task {
            let result = await self.dependencies.waterIntakeService.deleteIntakeEntry(by: entry.guid)

            switch result {
            case .failure(let error):
              self.historyStateMachine.transition(with: .loadingFailed(error))
            case .success:
              await self.loadHistory()
            }
          }
        }
      )
    }

    return .init(
      entries: entries,
      searchInterval: searchInterval,
      recommendedDailyAmount: dependencies.waterIntakeService.getDailyIntake(),
      didChangeSearchInterval: .init { [weak self] newInterval in
        self?.searchInterval = newInterval
      }
    )
  }

  func loadHistory() async {
    DispatchQueue.main.async { self.historyStateMachine.transition(with: .startLoading) }

    let startDate: Date
    let endDate: Date

    switch searchInterval {
    case .week:
      startDate = .now.startOfWeek()
      endDate = .now.endOfWeek()
    case .month:
      startDate = .now.startOfMonth()
      endDate = .now.endOfMonth()
    }

    let result = await dependencies.waterIntakeService.getIntakeEntries(startingFrom: startDate, endDate: endDate)

    switch result {
    case .failure(let error):
      DispatchQueue.main.async { self.historyStateMachine.transition(with: .loadingFailed(error)) }
    case .success(let entries):
      DispatchQueue.main.async { self.entries = entries }
    }
  }
}
