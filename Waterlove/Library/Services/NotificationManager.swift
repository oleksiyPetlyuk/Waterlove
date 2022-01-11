//
//  NotificationManager.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 11.01.2022.
//

import Foundation
import UserNotifications

enum NotificationManagerConstants {
  static let isNotificationsEnabledKey = "isNotificationsEnabled"
}

class NotificationManager {
  static let shared = NotificationManager()

  func requestAuthorization(completion: @escaping (Bool) -> Void) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
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

    for hour in 9...23 {
      dateComponents.hour = hour
      content.subtitle = "Should be received at \(hour):00"

      let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
      let request = UNNotificationRequest(
        identifier: "hydration_reminder_at_\(hour)",
        content: content,
        trigger: trigger
      )

      UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
          print(error)
        }
      }
    }
  }

  func removeScheduledNotifications() {
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
  }
}
