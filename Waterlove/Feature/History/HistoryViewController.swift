//
//  HistoryViewController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 08.12.2021.
//

import UIKit
import Charts
import SnapKit

class HistoryViewController: UIViewController {
  private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Props.LoadedProps.Data.ID>

  // swiftlint:disable nesting
  enum Props {
    case loading
    case error(description: String)
    case loaded(LoadedProps)

    struct LoadedProps {
      let data: [Data]
      let searchInterval: SearchInterval
      let recommendedDailyAmount: Measurement<UnitVolume>?
      let didChangeSearchInterval: CommandWith<SearchInterval>

      struct Data: Identifiable {
        let id: UUID
        let drinkType: DrinkType
        let amount: Measurement<UnitVolume>
        let waterAmount: Measurement<UnitVolume>
        let createdAt: Date
        let canEdit: Bool
        let didDelete: Command
      }
    }

    static let initial = Props.loading
  }
  // swiftlint:enable nesting

  var props: Props = .initial {
    didSet {
      guard isViewLoaded else { return }

      view.setNeedsLayout()
    }
  }

  private enum Section {
    case main
  }

  private lazy var dataSource = makeDataSource()

  @IBOutlet private weak var scrollView: UIScrollView!
  @IBOutlet private weak var searchIntervalControl: UISegmentedControl!
  @IBOutlet private weak var chartViewContainer: UIView!
  @IBOutlet private weak var tableView: UITableView!

  private lazy var chartView: BarChartView = {
    let chartView = BarChartView()
    chartView.rightAxis.enabled = false
    chartView.leftAxis.axisMinimum = 0
    chartView.xAxis.labelPosition = .bottom
    chartView.xAxis.drawGridLinesEnabled = false
    chartView.scaleXEnabled = false
    chartView.scaleYEnabled = false
    chartView.legend.enabled = false
    chartView.animate(yAxisDuration: 2.5)

    return chartView
  }()

  private lazy var activityIndicator: UIActivityIndicatorView = {
    let activityIndicator = UIActivityIndicatorView(style: .large)
    activityIndicator.color = .gray
    activityIndicator.hidesWhenStopped = true
    view.addSubview(activityIndicator)
    activityIndicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }

    return activityIndicator
  }()

  private lazy var errorLabel: UILabel = {
    let label = UILabel()
    label.font = .preferredFont(forTextStyle: .title1)
    view.addSubview(label)
    label.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }

    return label
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.title = "History"
    navigationItem.rightBarButtonItem = editButtonItem

    chartViewContainer.addSubview(chartView)
    chartView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    switch props {
    case .loading:
      activityIndicator.startAnimating()
      scrollView.isHidden = true
      errorLabel.isHidden = true
    case .error(let description):
      activityIndicator.stopAnimating()
      scrollView.isHidden = true
      errorLabel.isHidden = false
      errorLabel.text = description
    case .loaded(let loadedProps):
      activityIndicator.stopAnimating()
      searchIntervalControl.selectedSegmentIndex = loadedProps.searchInterval.rawValue
      scrollView.isHidden = false
      errorLabel.isHidden = true
      dataSource.update()

      if let recommendedDailyAmount = loadedProps.recommendedDailyAmount {
        chartView.leftAxis.axisMaximum = recommendedDailyAmount.value + 500

        let limitLine = ChartLimitLine(limit: recommendedDailyAmount.value, label: "Recommended")
        chartView.leftAxis.addLimitLine(limitLine)
      }

      setChartData()

      if loadedProps.searchInterval == .week {
        chartView.xAxis.valueFormatter = WeekdayValueFormatter()
      } else {
        chartView.xAxis.valueFormatter = DefaultAxisValueFormatter()
      }
    }
  }

  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)

    tableView.setEditing(editing, animated: animated)
  }

  @IBAction func didChangeSearchInterval(_ sender: UISegmentedControl) {
    if case .loaded(let props) = props, let interval = SearchInterval(rawValue: sender.selectedSegmentIndex) {
      props.didChangeSearchInterval.perform(with: interval)
    }
  }
}

// MARK: - Data Source Setup
extension HistoryViewController {
  private class HistoryDataSource: UITableViewDiffableDataSource<Section, Props.LoadedProps.Data.ID> {
    weak var parent: HistoryViewController?

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      guard case .loaded(let props) = parent?.props else { return false }

      guard let id = itemIdentifier(for: indexPath), let entry = props.data.first(where: { $0.id == id }) else {
        return false
      }

      return entry.canEdit
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      guard case .loaded(let props) = parent?.props else { return }

      if editingStyle == .delete {
        guard let id = itemIdentifier(for: indexPath), let entry = props.data.first(where: { $0.id == id }) else { return }

        entry.didDelete.perform()
      }
    }

    func update(animatingDifferences: Bool = true) {
      guard case .loaded(let props) = parent?.props else { return }

      var snapshot = snapshot()

      if snapshot.indexOfSection(.main) == nil {
        snapshot.appendSections([.main])
      }

      let diff = props.data.map { $0.id }.difference(from: snapshot.itemIdentifiers)

      for change in diff {
        switch change {
        case let .remove(_, element, _):
          snapshot.deleteItems([element])
        case let .insert(_, element, _):
          if snapshot.indexOfItem(element) == nil {
            snapshot.appendItems([element], toSection: .main)
          }
        }
      }

      apply(snapshot, animatingDifferences: animatingDifferences)
    }
  }

  private func makeDataSource() -> HistoryDataSource {
    let dataSource = HistoryDataSource(
      tableView: tableView
    ) { [weak self] tableView, indexPath, id -> UITableViewCell? in
      let cell = tableView.dequeueReusableCell(
        withIdentifier: IntakeEntryTableViewCell.identifier,
        for: indexPath
      ) as? IntakeEntryTableViewCell

      if case .loaded(let props) = self?.props {
        cell?.intakeEntry = props.data.first { $0.id == id }
      }

      return cell
    }

    dataSource.parent = self

    return dataSource
  }
}

// MARK: - Chart Data Setup
private extension HistoryViewController {
  func setChartData() {
    let set1 = BarChartDataSet(entries: buildChartData())
    set1.setColor(.systemBlue)
    set1.drawValuesEnabled = false

    let data = BarChartData(dataSet: set1)

    chartView.data = data
  }

  func buildChartData() -> [BarChartDataEntry] {
    if case .loaded(let props) = props {
      switch props.searchInterval {
      case .week: return buildWeeklyChartData()
      case .month: return buildMonthlyChartData()
      }
    }

    return []
  }

  func buildWeeklyChartData() -> [BarChartDataEntry] {
    if case .loaded(let props) = props {
      var chartData: [BarChartDataEntry] = []
      let grouped = Dictionary(grouping: props.data) { Calendar.current.component(.weekday, from: $0.createdAt) }

      Weekday.allCases.forEach { weekday in
        var totalAmount: Measurement<UnitVolume> = .init(value: 0, unit: .milliliters)

        if let group = grouped.first(where: { $0.key == weekday.rawValue }) {
          group.value.forEach { entry in
            // swiftlint:disable:next shorthand_operator
            totalAmount = totalAmount + entry.waterAmount
          }
        }

        chartData.append(.init(x: Double(weekday.rawValue), y: totalAmount.value))
      }

      return chartData
    }

    return []
  }

  func buildMonthlyChartData() -> [BarChartDataEntry] {
    if case .loaded(let props) = props {
      var chartData: [BarChartDataEntry] = []

      guard let daysRange = Calendar.current.range(of: .day, in: .month, for: .now.startOfMonth()) else {
        return chartData
      }

      let grouped = Dictionary(grouping: props.data) { Calendar.current.component(.day, from: $0.createdAt) }

      daysRange.forEach { day in
        var totalAmount: Measurement<UnitVolume> = .init(value: 0, unit: .milliliters)

        if let group = grouped.first(where: { $0.key == day }) {
          group.value.forEach { entry in
            // swiftlint:disable:next shorthand_operator
            totalAmount = totalAmount + entry.waterAmount
          }
        }

        chartData.append(.init(x: Double(day), y: totalAmount.value))
      }

      return chartData
    }

    return []
  }
}

enum SearchInterval: Int {
  case week, month
}

enum Weekday: Int, CaseIterable {
  case sunday = 1
  case monday = 2
  case tuesday = 3
  case wednesday = 4
  case thursday = 5
  case friday = 6
  case saturday = 7

  var shortDescription: String {
    switch self {
    case .sunday: return "S"
    case .monday: return "M"
    case .tuesday: return "T"
    case .wednesday: return "W"
    case .thursday: return "T"
    case .friday: return "F"
    case .saturday: return "S"
    }
  }
}

class WeekdayValueFormatter: AxisValueFormatter {
  func stringForValue(_ value: Double, axis: AxisBase?) -> String {
    guard let weekday = Weekday(rawValue: Int(value)) else { return "" }

    return weekday.shortDescription
  }
}
