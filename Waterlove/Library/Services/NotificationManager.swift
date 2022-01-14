//
//  NotificationManager.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 11.01.2022.
//

import Foundation
import UserNotifications

protocol UNUserNotificationCenterProtocol: AnyObject {
  func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void)

  func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)

  func removeAllPendingNotificationRequests()
}

extension UNUserNotificationCenter: UNUserNotificationCenterProtocol {}

enum NotificationManagerConstants {
  static let isNotificationsEnabledKey = "isNotificationsEnabled"
  static let notificationScheduledHours = 9...23
}

protocol NotificationManagerProtocol {
  func requestAuthorization(completion: @escaping (Bool) -> Void)

  func scheduleNotifications()

  func removeScheduledNotifications()
}

class NotificationManager: NotificationManagerProtocol {
  let notificationCenter: UNUserNotificationCenterProtocol

  init(notificationCenter: UNUserNotificationCenterProtocol) {
    self.notificationCenter = notificationCenter
  }

  func requestAuthorization(completion: @escaping (Bool) -> Void) {
    notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
      completion(granted)
    }
  }

  func scheduleNotifications() {
    let content = UNMutableNotificationContent()
    content.title = "Waterlove"
    content.body = "Water helps you feel better!"
    content.sound = .default

    var dateComponents = DateComponents()
    dateComponents.calendar = Calendar.current

    for hour in NotificationManagerConstants.notificationScheduledHours {
      dateComponents.hour = hour

      let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
      let request = UNNotificationRequest(
        identifier: "hydration_reminder_at_\(hour)",
        content: content,
        trigger: trigger
      )

      notificationCenter.add(request) { error in
        if let error = error {
          print(error)
        }
      }
    }
  }

  func removeScheduledNotifications() {
    notificationCenter.removeAllPendingNotificationRequests()
  }
}
