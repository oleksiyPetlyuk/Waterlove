//
//  MockNotificationCenter.swift
//  WaterloveTests
//
//  Created by Oleksiy Petlyuk on 13.01.2022.
//

import Foundation
import UserNotifications
import XCTest
@testable import Waterlove

class MockNotificationCenter: UNUserNotificationCenterProtocol {
  var notificationRequests: [UNNotificationRequest] = []

  func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
    completionHandler(true, nil)
  }

  func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
    notificationRequests.append(request)

    completionHandler?(nil)
  }

  func removeAllPendingNotificationRequests() {
    notificationRequests.removeAll()
  }
}
