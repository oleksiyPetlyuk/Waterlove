//
//  PhoneConnectivityService.swift
//  WaterloveWatch WatchKit Extension
//
//  Created by Oleksiy Petlyuk on 01.02.2022.
//

import Foundation
import WatchConnectivity
import Combine

class PhoneConnectivityService: NSObject, ObservableObject {
  private var session: WCSession?

  @Published private(set) var hydrationProgress: HydrationProgress = {
    return HydrationProgress(progress: 0, intookWaterAmount: .init(value: 0, unit: .milliliters), date: .now)
  }()

  override init() {
    super.init()

    createWCSession()
  }

  private func createWCSession() {
    if WCSession.isSupported() {
      session = .default
      session?.delegate = self
      session?.activate()
    }
  }
}

extension PhoneConnectivityService: WCSessionDelegate {
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    guard activationState == .activated else { return }

    session.sendMessage([WCSessionMessage.contextUpdateRequired.rawValue: true], replyHandler: nil, errorHandler: nil)
  }

  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
    if let hydrationProgressData = applicationContext[WCSessionMessage.hydrationProgress.rawValue] as? Data {
      do {
        let hydrationProgress = try JSONDecoder().decode(HydrationProgress.self, from: hydrationProgressData)

        guard Calendar.current.isDate(hydrationProgress.date, inSameDayAs: .now) else { return }

        DispatchQueue.main.async {
          self.hydrationProgress = hydrationProgress
        }
      } catch {
        print("Error: Can`t decode hydration progress data")
      }
    }
  }
}
