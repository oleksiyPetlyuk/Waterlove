//
//  WatchConnectivityService.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 01.02.2022.
//

import Foundation
import WatchConnectivity

protocol WatchConnectivityServiceProtocol {
  var observer: WatchConnectivityServiceObserver? { get set }

  func createWCSession()

  func send(currentHydration: HydrationProgress)
}

protocol WatchConnectivityServiceObserver {
  func watchConnectivityServiceDidActivated(_ service: WatchConnectivityServiceProtocol)

  func watchConnectivityServiceDidReceivedContextUpdateRequest(_ service: WatchConnectivityServiceProtocol)
}

class WatchConnectivityService: NSObject, WatchConnectivityServiceProtocol {
  var observer: WatchConnectivityServiceObserver?

  private var session: WCSession?

  func createWCSession() {
    if WCSession.isSupported() {
      session = .default
      session?.delegate = self
      session?.activate()
    }
  }

  func send(currentHydration: HydrationProgress) {
    guard let session = session, session.activationState == .activated, session.isWatchAppInstalled else { return }

    guard let data = try? JSONEncoder().encode(currentHydration) else { return }

    do {
      try session.updateApplicationContext([WCSessionMessage.hydrationProgress.rawValue: data])
    } catch {
      print("Error sending application context to a watch: \(error.localizedDescription)")
    }
  }
}

extension WatchConnectivityService: WCSessionDelegate {
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    guard activationState == .activated else { return }

    observer?.watchConnectivityServiceDidActivated(self)
  }

  func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    if message[WCSessionMessage.contextUpdateRequired.rawValue] as? Bool != nil {
      observer?.watchConnectivityServiceDidReceivedContextUpdateRequest(self)
    }
  }

  func sessionDidBecomeInactive(_ session: WCSession) {
    //
  }

  func sessionDidDeactivate(_ session: WCSession) {
    //
  }
}
