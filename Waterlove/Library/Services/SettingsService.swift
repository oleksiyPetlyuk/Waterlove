//
//  SettingsService.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 28.01.2022.
//

import Foundation

protocol SettingsServiceProtocol {
  var isUserDidFinishTutorial: Bool { get set }

  var isNotificationsEnabled: Bool { get set }
}

class SettingsService: SettingsServiceProtocol {
  static let shared = SettingsService()

  private let defaults = UserDefaults.standard

  private init() {
    defaults.register(defaults: [Constants.isNotificationsEnabledKey: true])
  }
}

extension SettingsService {
  private enum Constants {
    static let userDidFinishTutorialKey = "userDidFinishTutorial"
    static let isNotificationsEnabledKey = "isNotificationsEnabled"
  }

  var isUserDidFinishTutorial: Bool {
    get {
      defaults.bool(forKey: Constants.userDidFinishTutorialKey)
    }

    set {
      defaults.set(newValue, forKey: Constants.userDidFinishTutorialKey)
    }
  }

  var isNotificationsEnabled: Bool {
    get {
      defaults.bool(forKey: Constants.isNotificationsEnabledKey)
    }

    set {
      defaults.set(newValue, forKey: Constants.isNotificationsEnabledKey)
    }
  }
}
