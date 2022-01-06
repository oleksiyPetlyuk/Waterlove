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
  private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Props.Entry.ID>

  // swiftlint:disable nesting
  struct Props: Equatable {
    let entries: [Entry]
    let searchInterval: SearchInterval
    let recommendedDailyAmount: Measurement<UnitVolume>?
    let didChangeSearchInterval: CommandWith<SearchInterval>

    struct Entry: Identifiable, Equatable {
      static func == (lhs: HistoryViewController.Props.Entry, rhs: HistoryViewController.Props.Entry) -> Bool {
        return lhs.id == rhs.id
      }

      let id: UUID
      let drinkType: DrinkType
      let amount: Measurement<UnitVolume>
      let waterAmount: Measurement<UnitVolume>
      let createdAt: Date
      let canEdit: Bool
      let didDelete: Command
    }

    static let initial = Props(
      entries: [],
      searchInterval: .week,
      recommendedDailyAmount: nil,
      didChangeSearchInterval: .nop
    )

    static func == (lhs: HistoryViewController.Props, rhs: HistoryViewController.Props) -> Bool {
      return lhs.entries == rhs.entries &&
      lhs.searchInterval == rhs.searchInterval &&
      lhs.recommendedDailyAmount == rhs.recommendedDailyAmount
    }
  }
  // swiftlint:enable nesting

  private enum Section {
    case main
  }

  private var props: Props = .initial

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

  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)

    tableView.setEditing(editing, animated: animated)
  }

  @IBAction func didChangeSearchInterval(_ sender: UISegmentedControl) {
    if let interval = SearchInterval(rawValue: sender.selectedSegmentIndex) {
      props.didChangeSearchInterval.perform(with: interval)
    }
  }
}

// MARK: - Data Source Setup
extension HistoryViewController {
  private class HistoryDataSource: UITableViewDiffableDataSource<Section, Props.Entry.ID> {
    weak var parent: HistoryViewController?

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      guard let props = parent?.props else { return false }

      guard let id = itemIdentifier(for: indexPath), let entry = props.entries.first(where: { $0.id == id }) else {
        return false
      }

      return entry.canEdit
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      guard let props = parent?.props else { return }

      if editingStyle == .delete {
        guard let id = itemIdentifier(for: indexPath), let entry = props.entries.first(where: { $0.id == id }) else {
          return
        }

        entry.didDelete.perform()
      }
    }

    func update(animatingDifferences: Bool = true) {
      guard let props = parent?.props else { return }

      var snapshot = snapshot()

      if snapshot.indexOfSection(.main) == nil {
        snapshot.appendSections([.main])
      }

      let diff = props.entries.map { $0.id }.difference(from: snapshot.itemIdentifiers)

      for change in diff {
        switch change {
        case let .remove(_, element, _):
          snapshot.deleteItems([element])
        case let .insert(_, element, _):
          if snapshot.indexOfItem(element) == nil {
            if let first = snapshot.itemIdentifiers.first {
              snapshot.insertItems([element], beforeItem: first)
            } else {
              snapshot.appendItems([element], toSection: .main)
            }
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

      if let props = self?.props {
        cell?.intakeEntry = props.entries.first { $0.id == id }
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
    switch props.searchInterval {
    case .week: return buildWeeklyChartData()
    case .month: return buildMonthlyChartData()
    }
  }

  func buildWeeklyChartData() -> [BarChartDataEntry] {
    var chartData: [BarChartDataEntry] = []
    let grouped = Dictionary(grouping: props.entries) { Calendar.current.component(.weekday, from: $0.createdAt) }

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

  func buildMonthlyChartData() -> [BarChartDataEntry] {
    var chartData: [BarChartDataEntry] = []

    guard let daysRange = Calendar.current.range(of: .day, in: .month, for: .now.startOfMonth()) else {
      return chartData
    }

    let grouped = Dictionary(grouping: props.entries) { Calendar.current.component(.day, from: $0.createdAt) }

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
}

extension HistoryViewController: HistoryStateMachineObserver {
  func historyStateMachine(_ stateMachine: HistoryStateMachine, didEnter state: HistoryStateMachine.State) {
    switch state {
    case .idle:
      break
    case .loading:
      activityIndicator.startAnimating()
      scrollView.isHidden = true
      errorLabel.isHidden = true
    case .empty:
      activityIndicator.stopAnimating()
      scrollView.isHidden = true
      errorLabel.isHidden = false
      errorLabel.text = "No entries found"
    case .list(let props):
      self.props = props
      activityIndicator.stopAnimating()
      searchIntervalControl.selectedSegmentIndex = props.searchInterval.rawValue
      scrollView.isHidden = false
      errorLabel.isHidden = true
      dataSource.update()

      if let recommendedDailyAmount = props.recommendedDailyAmount {
        chartView.leftAxis.axisMaximum = recommendedDailyAmount.value + 1000

        let limitLine = ChartLimitLine(limit: recommendedDailyAmount.value, label: "Recommended")
        chartView.leftAxis.addLimitLine(limitLine)
      }

      setChartData()

      if props.searchInterval == .week {
        chartView.xAxis.valueFormatter = WeekdayValueFormatter()
      } else {
        chartView.xAxis.valueFormatter = DefaultAxisValueFormatter()
      }
    case .error(let error):
      activityIndicator.stopAnimating()
      scrollView.isHidden = true
      errorLabel.isHidden = false
      errorLabel.text = error.localizedDescription
    }
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
