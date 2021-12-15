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
    let totalWaterAmount: Float
    let gender: Field<WaterIntakeCalculator.Gender>
    let weight: Field<UInt8>
    let onSaveWaterIntakeResults: Command

    struct Field<T> {
      let value: T
      let onUpdate: CommandWith<T>
    }

    static let initial = Props(
      totalWaterAmount: 3.0,
      gender: .init(value: .male, onUpdate: .nop),
      weight: .init(value: 75, onUpdate: .nop),
      onSaveWaterIntakeResults: .nop
    )
  }
  // swiftlint:enable nesting

  private(set) var props: Props = .initial

  @IBOutlet private weak var totalWaterAmountLabel: UILabel!
  @IBOutlet private weak var genderControl: UISegmentedControl!
  @IBOutlet private weak var weightSlider: UISlider!

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

    render()
  }

  func render(_ props: Props) {
    self.props = props

    view.setNeedsLayout()
  }

  private func render() {
    guard isViewLoaded else { return }

    totalWaterAmountLabel.text = String(format: "%.2f L", props.totalWaterAmount)
    genderControl.selectedSegmentIndex = props.gender.value == .male ? 0 : 1
    weightSlider.value = Float(props.weight.value)
    renderWeightSliderLabel()
  }

  @IBAction private func didTapSaveWaterIntakeResults(_ sender: UIButton) {
    props.onSaveWaterIntakeResults.perform()
  }

  @IBAction private func genderValueChanged(_ sender: UISegmentedControl) {
    props.gender.onUpdate.perform(with: sender.selectedSegmentIndex == 0 ? .male : .female)
  }

  @IBAction private func weightValueChanged(_ sender: UISlider) {
    props.weight.onUpdate.perform(with: UInt8(sender.value))
  }

  private func renderWeightSliderLabel() {
    currentWeightLabel.text = "\(props.weight.value)"

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
