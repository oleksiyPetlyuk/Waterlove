//
//  CurrentHydrationViewController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 08.12.2021.
//

import UIKit

class CurrentHydrationViewController: UIViewController {
  struct Props {
    let progress: (CGFloat, UInt)
    let didTapAddNewIntake: CommandWith<DrinkType>

    static let initial = Props(progress: (0, 0), didTapAddNewIntake: .nop)
  }

  var props: Props = .initial {
    didSet {
      guard isViewLoaded else { return }

      view.setNeedsLayout()
    }
  }

  @IBOutlet private weak var hydrationProgressView: HydrationProgressView!

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    hydrationProgressView.props = .init(
      progressBarProps: .init(progress: props.progress.0),
      progressValue: props.progress.0,
      intookWaterAmount: props.progress.1
    )
  }

  @IBAction private func didTapAddNewIntakeButton(_ sender: UIButton) {
    guard let drinkType = DrinkType(tag: sender.tag) else { return }

    props.didTapAddNewIntake.perform(with: drinkType)
  }
}
