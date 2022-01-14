//
//  NotificationManagerSpec.swift
//  WaterloveTests
//
//  Created by Oleksiy Petlyuk on 13.01.2022.
//

import Foundation
import Quick
import Nimble
@testable import Waterlove

class NotificationManagerSpec: QuickSpec {
  override func spec() {
    describe("notification manager") {
      // swiftlint:disable implicitly_unwrapped_optional
      var notificationCenter: MockNotificationCenter!
      var sut: NotificationManagerProtocol!

      beforeEach {
        notificationCenter = MockNotificationCenter()
        sut = NotificationManager(notificationCenter: notificationCenter)
      }

      context("when requested for authorization") {
        it("should grant access") {
          var requestGranted = false

          sut.requestAuthorization { requestGranted = $0 }

          expect(requestGranted).toEventually(beTruthy())
        }
      }

      context("when schedules notifications") {
        it("should contain valid notification requests") {
          sut.scheduleNotifications()

          let scheduledNotifications = notificationCenter.notificationRequests.map { $0.content }

          let scheduledDates = notificationCenter.notificationRequests.compactMap { request in
            (request.trigger as? UNCalendarNotificationTrigger)?.dateComponents
          }

          var targetDates: [DateComponents] = []

          for hour in NotificationManagerConstants.notificationScheduledHours {
            var dateComponents = DateComponents()
            dateComponents.hour = hour

            targetDates.append(dateComponents)
          }

          let diff = targetDates.difference(from: scheduledDates) { $0.hour == $1.hour }

          expect(diff.count).to(equal(0))

          scheduledNotifications.forEach { notification in
            expect(notification.title).to(equal("Waterlove"))
            expect(notification.body).to(equal("Water helps you feel better!"))
            expect(notification.sound).to(equal(.default))
          }
        }
      }

      context("when removes scheduled notifications") {
        it("should remove all pending notification requests") {
          sut.scheduleNotifications()

          expect(notificationCenter.notificationRequests).toNot(beEmpty())

          sut.removeScheduledNotifications()

          expect(notificationCenter.notificationRequests).to(beEmpty())
        }
      }
    }
  }
}
