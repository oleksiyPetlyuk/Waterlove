//
//  CurrentHydrationViewController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 08.12.2021.
//

import UIKit

class CurrentHydrationViewController: UIViewController {
  struct Props {
    let progress: [(CGFloat, UInt)]

    static let initial = Props(progress: [
      (0, 0), (0.1, 250), (0.5, 1050), (0.7, 1400), (0.3, 350), (0.95, 1870), (1, 2000)
    ])
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

    props.progress.enumerated().forEach { offset, progress in
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(offset)) { [weak self] in
        self?.hydrationProgressView.props = .init(
          progressBarProps: .init(progress: progress.0),
          progressValue: progress.0,
          intookWaterAmount: progress.1
        )
      }
    }
  }
}
