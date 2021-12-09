//
//  WaterIntakeCalculatorViewController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 07.12.2021.
//

import UIKit
import SnapKit

class WaterIntakeCalculatorViewController: UIViewController {
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

  private let waterIntakeCalculator = WaterIntakeCalculator()

  var saveWaterIntakeResultsHandler: (() -> Void)?

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(currentWeightLabel)
    updateTotalWaterAmountLabel()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    updateCurrentWeightLabel()
  }

  @IBAction func didTapSaveWaterIntakeResults(_ sender: UIButton) {
    if let saveWaterIntakeResultsHandler = saveWaterIntakeResultsHandler {
      saveWaterIntakeResultsHandler()
    }
  }

  @IBAction func genderValueChanged(_ sender: UISegmentedControl) {
    updateTotalWaterAmountLabel()
  }

  @IBAction func weightValueChanged(_ sender: UISlider) {
    updateCurrentWeightLabel()
    updateTotalWaterAmountLabel()
  }

  private func updateCurrentWeightLabel() {
    let currentValue = Int(round(weightSlider.value))
    currentWeightLabel.text = "\(currentValue)"

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

  private func updateTotalWaterAmountLabel() {
    let weight = Int(round(weightSlider.value))
    let gender: WaterIntakeCalculator.Gender = genderControl.selectedSegmentIndex == 0 ? .male : .female
    let waterAmount = waterIntakeCalculator.calculate(gender: gender, weight: weight)

    totalWaterAmountLabel.text = String(format: "%.2f L", waterAmount)
  }
}
