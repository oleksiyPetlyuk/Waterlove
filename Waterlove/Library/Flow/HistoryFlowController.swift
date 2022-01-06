//
//  HistoryFlowController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 04.01.2022.
//

import UIKit

final class HistoryFlowController: UIViewController {
  typealias Dependencies = HasDailyWaterIntakeStore

  let dependencies: Dependencies

  private var embeddedNavigationController: UINavigationController?

  private lazy var historyVC: HistoryViewController? = {
    return R.storyboard.main.historyViewController()
  }()

  private var repository: Repository<IntakeEntry>

  private var searchInterval = SearchInterval.week {
    didSet {
      loadHistory(showLoading: false)
    }
  }

  private var entries: [IntakeEntry] = [] {
    didSet {
      if let controller = historyVC {
        controller.props = .loaded(makeHistoryLoadedProps())
      }
    }
  }

  init(dependencies: Dependencies) {
    self.dependencies = dependencies

    self.repository = DBRepository(
      contextSource: DBContextProvider(),
      entityMapper: IntakeEntryEntityMapper(),
      autoUpdateSearchRequest: nil
    )

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

    loadHistory(showLoading: false)
  }

  func start() {
    startHistory()
  }

  private func startHistory() {
    if let controller = historyVC {
      loadHistory()

      embeddedNavigationController?.viewControllers = [controller]
    }
  }
}

private extension HistoryFlowController {
  func makeHistoryLoadedProps() -> HistoryViewController.Props.LoadedProps {
    let entries: [HistoryViewController.Props.LoadedProps.Data] = entries.map { entry in
      return .init(
        id: entry.guid,
        drinkType: entry.drinkType,
        amount: entry.amount,
        waterAmount: entry.waterAmount,
        createdAt: entry.createdAt,
        canEdit: true,
        didDelete: .init { [weak self] in
          guard let self = self else { return }

          self.repository.delete(by: IntakeEntryGetByGuidSearchRequest(guids: [entry.guid])) { result in
            switch result {
            case .failure(let error):
              if let controller = self.historyVC {
                DispatchQueue.main.async {
                  controller.props = .error(description: error.localizedDescription)
                }
              }
            case .success:
              DispatchQueue.main.async {
                self.loadHistory(showLoading: false)
              }
            }
          }
        }
      )
    }

    return .init(
      data: entries,
      searchInterval: searchInterval,
      recommendedDailyAmount: dependencies.dailyWaterIntakeStore.getDailyIntake(),
      didChangeSearchInterval: .init { [weak self] newInterval in
        self?.searchInterval = newInterval
      }
    )
  }

  func loadHistory(showLoading: Bool = true) {
    if let controller = historyVC {
      if showLoading {
        controller.props = .loading
      }

      fetchEntries { [weak self] result in
        switch result {
        case .failure(let error):
          controller.props = .error(description: error.localizedDescription)
        case .success(let entries):
          self?.entries = entries
        }
      }
    }
  }

  func fetchEntries(completion: @escaping ((Result<[IntakeEntry], Error>) -> Void)) {
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

    let sort = NSSortDescriptor(key: "createdAt", ascending: true)

    let request = IntakeEntrySpecificDateSearchRequest(startDate: startDate, endDate: endDate, sortDescriptors: [sort])

    repository.present(by: request) { result in
      DispatchQueue.main.async {
        completion(result)
      }
    }
  }
}
