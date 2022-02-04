//
//  PhoneConnectivityService.swift
//  WaterloveWatch WatchKit Extension
//
//  Created by Oleksiy Petlyuk on 01.02.2022.
//

import Foundation
import WatchConnectivity
import Combine
import ClockKit

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

  func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
    if let hydrationProgress = userInfo[WCSessionMessage.hydrationProgress.rawValue] as? Data {
      guard let url = FileManager.complicationDataURL() else { return }

      do {
        try hydrationProgress.write(to: url)
        updateComplications()
      } catch {
        print("Error: Cannot write complication contents")
      }
    }
  }
}

extension PhoneConnectivityService {
  private func updateComplications() {
    let complicationServer = CLKComplicationServer.sharedInstance()

    complicationServer.activeComplications?.forEach { complication in
      complicationServer.extendTimeline(for: complication)
    }
  }
}
