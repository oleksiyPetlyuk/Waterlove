//
//  WaterloveApp.swift
//  WaterloveWatch WatchKit Extension
//
//  Created by Oleksiy Petlyuk on 28.01.2022.
//

import SwiftUI

@main
struct WaterloveApp: App {
  let phoneConnectivityService = PhoneConnectivityService()

  private let formatter: MeasurementFormatter = {
    let formatter = MeasurementFormatter()
    formatter.unitOptions = .providedUnit

    return formatter
  }()

  @SceneBuilder var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
      }
      .environmentObject(phoneConnectivityService)
      .environmentObject(formatter)
    }

    WKNotificationScene(controller: NotificationController.self, category: "myCategory")
  }
}

extension MeasurementFormatter: ObservableObject {}
