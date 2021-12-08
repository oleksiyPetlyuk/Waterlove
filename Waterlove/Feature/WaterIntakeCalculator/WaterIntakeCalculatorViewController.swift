//
//  WaterIntakeCalculatorViewController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 07.12.2021.
//

import UIKit

class WaterIntakeCalculatorViewController: UIViewController {
  var saveWaterIntakeResultsHandler: (() -> Void)?

  @IBAction func didTapSaveWaterIntakeResults(_ sender: UIButton) {
    if let saveWaterIntakeResultsHandler = saveWaterIntakeResultsHandler {
      saveWaterIntakeResultsHandler()
    }
  }
}
