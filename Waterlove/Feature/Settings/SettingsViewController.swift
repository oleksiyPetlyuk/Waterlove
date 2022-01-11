//
//  SettingsViewController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 11.01.2022.
//

import UIKit

class SettingsViewController: UITableViewController {
  // swiftlint:disable nesting
  struct Props {
    let isNotificationsEnabled: Field<Bool>

    struct Field<T> {
      let value: T
      let didUpdate: CommandWith<T>
    }

    static let initial = Props(isNotificationsEnabled: .init(value: false, didUpdate: .nop))
  }
  // swiftlint:enable nesting

  var props: Props = .initial {
    didSet {
      guard isViewLoaded else { return }

      view.setNeedsLayout()
    }
  }

  @IBOutlet private weak var isNotificationsEnabledSwitch: UISwitch!

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.title = "Settings"
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    isNotificationsEnabledSwitch.isOn = props.isNotificationsEnabled.value
  }

  @IBAction func didChangeAllowNotificationsValue(_ sender: UISwitch) {
    props.isNotificationsEnabled.didUpdate.perform(with: sender.isOn)
  }
}
