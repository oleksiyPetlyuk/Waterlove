//
//  WaterIntakeService.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 22.12.2021.
//

import Foundation
import WidgetKit

protocol WaterIntakeServiceProtocol {
  func storeDailyIntake(_ amount: Measurement<UnitVolume>)

  func getDailyIntake() -> Measurement<UnitVolume>?

  func getHydrationProgress() async -> HydrationProgress?

  func saveIntakeEntry(_ entry: IntakeEntry) async -> Result<Void, Error>

  func deleteIntakeEntry(by id: UUID) async -> Result<Void, Error>

  func getIntakeEntries(startingFrom: Date, endDate: Date) async -> Result<[IntakeEntry], Error>
}

class WaterIntakeService: WaterIntakeServiceProtocol {
  private let defaults = UserDefaults.standard

  private let dailyWaterIntakeKey = "dailyWaterIntake"

  private var repository: Repository<IntakeEntry>

  private var watchConnectivityService: WatchConnectivityServiceProtocol

  init(watchConnectivityService: WatchConnectivityServiceProtocol) {
    self.repository = DBRepository(
      contextSource: DBContextProvider(),
      entityMapper: IntakeEntryEntityMapper(),
      autoUpdateSearchRequest: nil
    )

    self.watchConnectivityService = watchConnectivityService
    self.watchConnectivityService.observer = self
    self.watchConnectivityService.createWCSession()
  }

  func storeDailyIntake(_ amount: Measurement<UnitVolume>) {
    defaults.set(try? PropertyListEncoder().encode(amount), forKey: dailyWaterIntakeKey)
  }

  func getDailyIntake() -> Measurement<UnitVolume>? {
    guard let data = defaults.value(forKey: dailyWaterIntakeKey) as? Data else { return nil }

    return try? PropertyListDecoder().decode(Measurement<UnitVolume>.self, from: data)
  }

  @discardableResult
  func getHydrationProgress() async -> HydrationProgress? {
    guard let dailyIntake = self.getDailyIntake() else { return nil }

    return await withCheckedContinuation { continuation in
      let searchRequest = IntakeEntrySpecificDateSearchRequest()

      repository.present(by: searchRequest) { result in
        switch result {
        case .failure(let error):
          print("Error: \(error.localizedDescription)")

          continuation.resume(returning: nil)
        case .success(let entries):
          var totalAmount: Measurement<UnitVolume> = .init(value: 0, unit: .milliliters)
          var progress: UInt8

          entries.forEach { entry in
            // swiftlint:disable:next shorthand_operator
            totalAmount = totalAmount + entry.waterAmount
          }

          if totalAmount >= dailyIntake {
            progress = 100
          } else {
            progress = UInt8(totalAmount.value / dailyIntake.value * 100)
          }

          let hydrationProgress = HydrationProgress(progress: progress, intookWaterAmount: totalAmount, date: .now)

          continuation.resume(returning: hydrationProgress)

          self.saveWidgetContents(contents: hydrationProgress)
        }
      }
    }
  }

  func saveIntakeEntry(_ entry: IntakeEntry) async -> Result<Void, Error> {
    let result: Result<Void, Error> = await withCheckedContinuation { continuation in
      repository.save([entry]) { result in
        continuation.resume(returning: result)
      }
    }

    switch result {
    case .failure(let error):
      print("Error: \(error.localizedDescription)")
    case .success:
      DispatchQueue.global().async {
        Task {
          guard let progress = await self.getHydrationProgress() else { return }

          WidgetCenter.shared.reloadTimelines(ofKind: "WaterloveWidget")

          self.watchConnectivityService.send(currentHydration: progress)
        }
      }
    }

    return result
  }

  func deleteIntakeEntry(by id: UUID) async -> Result<Void, Error> {
    let result: Result<Void, Error> = await withCheckedContinuation { continuation in
      let searchRequest = IntakeEntryGetByGuidSearchRequest(guids: [id])

      repository.delete(by: searchRequest) { result in
        continuation.resume(returning: result)
      }
    }

    switch result {
    case .failure:
      print("Error: Can`t delete intake entry")
    case .success:
      DispatchQueue.global().async {
        Task {
          guard let progress = await self.getHydrationProgress() else { return }

          WidgetCenter.shared.reloadTimelines(ofKind: "WaterloveWidget")

          self.watchConnectivityService.send(currentHydration: progress)
        }
      }
    }

    return result
  }

  func getIntakeEntries(startingFrom: Date, endDate: Date) async -> Result<[IntakeEntry], Error> {
    return await withCheckedContinuation { continuation in
      let sort = NSSortDescriptor(key: "createdAt", ascending: true)
      let searchRequest = IntakeEntrySpecificDateSearchRequest(
        startDate: startingFrom,
        endDate: endDate,
        sortDescriptors: [sort]
      )

      repository.present(by: searchRequest) { result in
        continuation.resume(returning: result)
      }
    }
  }

  private func saveWidgetContents(contents: HydrationProgress) {
    let archiveURL = FileManager.sharedContainerURL().appendingPathComponent("widget_contents.json")

    if let dataToSave = try? JSONEncoder().encode(contents) {
      do {
        try dataToSave.write(to: archiveURL)
      } catch {
        print("Error: Cannot write widget contents")
      }
    }
  }
}

extension WaterIntakeService: WatchConnectivityServiceObserver {
  private func sendDataToWatch() async {
    guard let currentHydration = await getHydrationProgress() else { return }

    watchConnectivityService.send(currentHydration: currentHydration)
  }

  func watchConnectivityServiceDidActivated(_ service: WatchConnectivityServiceProtocol) {
    Task {
      await sendDataToWatch()
    }
  }

  func watchConnectivityServiceDidReceivedContextUpdateRequest(_ service: WatchConnectivityServiceProtocol) {
    Task {
      await sendDataToWatch()
    }
  }
}
