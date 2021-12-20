//
//  TutorialStepViewController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 17.12.2021.
//

import UIKit

class TutorialStepViewController: UIViewController {
  struct Props {
    // used to identify steps
    let id: UInt
    let image: String
    let heading: String
    let subheading: String

    static let initial = Props(
      id: .init(),
      image: "bottle",
      heading: "Concentration Ability and Brain Activity",
      subheading: """
      A healthy habit to drink water during the day helps to maintain concentration and keep your brain active
      """
    )
  }

  var props: Props = .initial {
    didSet {
      guard isViewLoaded else { return }

      view.setNeedsLayout()
    }
  }

  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var headingLabel: UILabel!
  @IBOutlet private weak var subheadingLabel: UILabel!

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    imageView.image = .init(named: props.image)
    headingLabel.text = props.heading
    subheadingLabel.text = props.subheading
  }
}
