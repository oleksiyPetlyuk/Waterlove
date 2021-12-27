//
//  SaveIntakeEntryViewController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 27.12.2021.
//

import UIKit

class SaveIntakeEntryViewController: UIViewController {
  struct Props {
    let amount: Measurement<UnitVolume>
    let drinkType: DrinkType
    let didSelectDrinkType: CommandWith<DrinkType>
    let didTapNumpadButton: CommandWith<NumpadButton>
    let didTapSaveButton: Command

    static let initial = Props(
      amount: .init(value: 0, unit: .milliliters),
      drinkType: .water,
      didSelectDrinkType: .nop,
      didTapNumpadButton: .nop,
      didTapSaveButton: .nop
    )
  }

  var props: Props = .initial {
    didSet {
      guard isViewLoaded else { return }

      view.setNeedsLayout()
    }
  }

  private let formatter: MeasurementFormatter = {
    let formatter = MeasurementFormatter()
    formatter.unitOptions = .providedUnit

    return formatter
  }()

  @IBOutlet private weak var amountLabel: UILabel!
  @IBOutlet private weak var drinkTypeLabel: UILabel!

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    amountLabel.text = formatter.string(from: props.amount)
    drinkTypeLabel.text = props.drinkType.rawValue.capitalizingFirstLetter()
  }

  @IBAction private func didTapDrinkTypeButton(_ sender: UIButton) {
    guard let drinkType = DrinkType(tag: sender.tag) else { return }

    props.didSelectDrinkType.perform(with: drinkType)
  }

  @IBAction private func didTapNumberButton(_ sender: UIButton) {
    guard let numpadButton = NumpadButton(tag: sender.tag) else { return }

    props.didTapNumpadButton.perform(with: numpadButton)
  }

  @IBAction private func didTapSaveButton(_ sender: UIButton) {
    props.didTapSaveButton.perform()
  }
}

enum NumpadButton: String {
  case zero = "0"
  case doubleZero = "00"
  case one = "1"
  case two = "2"
  case three = "3"
  case four = "4"
  case five = "5"
  case six = "6"
  case seven = "7"
  case eight = "8"
  case nine = "9"
  case delete

  init?(tag: Int) {
    if tag == -1 {
      self = .delete
    } else if tag == 100 {
      self = .doubleZero
    } else {
      self.init(rawValue: String(tag))
    }
  }
}
