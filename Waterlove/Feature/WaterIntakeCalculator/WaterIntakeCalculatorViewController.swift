//
//  WaterIntakeCalculatorViewController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 07.12.2021.
//

import UIKit

class WaterIntakeCalculatorViewController: UIViewController {
  // swiftlint:disable nesting
  struct Props {
    let totalWaterAmount: Measurement<UnitVolume>
    let gender: Field<WaterIntakeCalculator.Gender>
    let weight: Field<Measurement<UnitMass>>
    let didSaveWaterIntakeResults: Command

    struct Field<T> {
      let value: T
      let didUpdate: CommandWith<T>
    }

    static let initial = Props(
      totalWaterAmount: .init(value: 3000, unit: .milliliters),
      gender: .init(value: .male, didUpdate: .nop),
      weight: .init(value: .init(value: 75, unit: .kilograms), didUpdate: .nop),
      didSaveWaterIntakeResults: .nop
    )
  }
  // swiftlint:enable nesting

  var props: Props = .initial {
    didSet {
      guard isViewLoaded else { return }

      view.setNeedsLayout()
    }
  }

  @IBOutlet private weak var totalWaterAmountLabel: UILabel!
  @IBOutlet private weak var genderControl: UISegmentedControl!
  @IBOutlet private weak var weightSlider: UISlider!

  private let formatter = MeasurementFormatter()

  private var currentWeightLabel: UILabel = {
    let label = UILabel(frame: .init(x: 0, y: 0, width: 50, height: 25))
    label.textColor = .link
    label.font = .preferredFont(forTextStyle: .subheadline)
    label.numberOfLines = 0
    label.textAlignment = .center

    return label
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(currentWeightLabel)
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    totalWaterAmountLabel.text = formatter.string(from: props.totalWaterAmount)
    genderControl.selectedSegmentIndex = props.gender.value == .male ? 0 : 1
    weightSlider.value = Float(props.weight.value.value)
    renderWeightSliderLabel()
  }

  @IBAction private func didTapSaveWaterIntakeResults(_ sender: UIButton) {
    props.didSaveWaterIntakeResults.perform()
  }

  @IBAction func didChangeGender(_ sender: UISegmentedControl) {
    props.gender.didUpdate.perform(with: sender.selectedSegmentIndex == 0 ? .male : .female)
  }

  @IBAction func didChangeWeight(_ sender: UISlider) {
    props.weight.didUpdate.perform(with: .init(value: Double(sender.value), unit: .kilograms))
  }

  private func renderWeightSliderLabel() {
    let weight: Measurement<UnitMass> = .init(value: Double(Int(props.weight.value.value)), unit: .kilograms)
    currentWeightLabel.text = formatter.string(from: weight)

    let trackRect = weightSlider.trackRect(forBounds: weightSlider.bounds)
    let thumbRect = weightSlider.thumbRect(
      forBounds: weightSlider.bounds,
      trackRect: trackRect,
      value: weightSlider.value
    )

    let x = thumbRect.origin.x + weightSlider.frame.origin.x + 15.5
    let y = weightSlider.frame.origin.y - 16

    currentWeightLabel.center = CGPoint(x: x, y: y)
  }
}
