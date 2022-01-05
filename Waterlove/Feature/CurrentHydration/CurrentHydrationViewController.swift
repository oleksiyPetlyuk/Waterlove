//
//  CurrentHydrationViewController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 08.12.2021.
//

import UIKit

class CurrentHydrationViewController: UIViewController {
  struct Props {
    let hydrationProgressViewProps: HydrationProgressView.Props
    let didTapAddNewIntake: CommandWith<DrinkType>

    static let initial = Props(hydrationProgressViewProps: .initial, didTapAddNewIntake: .nop)
  }

  var props: Props = .initial {
    didSet {
      guard isViewLoaded else { return }

      view.setNeedsLayout()
    }
  }

  @IBOutlet private weak var hydrationProgressView: HydrationProgressView!

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.title = "Current Hydration"
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    hydrationProgressView.props = props.hydrationProgressViewProps
  }

  @IBAction private func didTapAddNewIntakeButton(_ sender: UIButton) {
    guard let drinkType = DrinkType(tag: sender.tag) else { return }

    props.didTapAddNewIntake.perform(with: drinkType)
  }
}
