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

  @SceneBuilder var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
      }
      .environmentObject(phoneConnectivityService)
    }

    WKNotificationScene(controller: NotificationController.self, category: "myCategory")
  }
}
