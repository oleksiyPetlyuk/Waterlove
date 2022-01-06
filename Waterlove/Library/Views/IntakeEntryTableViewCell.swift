//
//  IntakeEntryTableViewCell.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 29.12.2021.
//

import UIKit

class IntakeEntryTableViewCell: UITableViewCell {
  static let identifier = "IntakeEntryTableViewCell"

  @IBOutlet private weak var drinkTypeLabel: UILabel!
  @IBOutlet private weak var dateLabel: UILabel!
  @IBOutlet private weak var amountLabel: UILabel!

  private let formatter: MeasurementFormatter = {
    let formatter = MeasurementFormatter()
    formatter.unitOptions = .providedUnit

    return formatter
  }()

  var intakeEntry: HistoryViewController.Props.Entry? {
    didSet {
      guard let entry = intakeEntry else { return }

      drinkTypeLabel.text = entry.drinkType.rawValue.capitalizingFirstLetter()
      dateLabel.text = entry.createdAt.formatted()
      amountLabel.text = formatter.string(from: entry.amount)
    }
  }
}
