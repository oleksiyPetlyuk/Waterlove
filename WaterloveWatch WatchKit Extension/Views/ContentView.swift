//
//  ContentView.swift
//  WaterloveWatch WatchKit Extension
//
//  Created by Oleksiy Petlyuk on 28.01.2022.
//

import SwiftUI
import Foundation

struct ContentView: View {
  @EnvironmentObject var phoneConnectivityService: PhoneConnectivityService

  var body: some View {
    TabView {
      CurrentHydrationView(hydrationProgress: phoneConnectivityService.hydrationProgress)

      HistoryView(entries: phoneConnectivityService.hydrationProgress.history) { entry in
        phoneConnectivityService.deleteIntakeEntry(entry.guid)
      }
    }
  }
}

struct CurrentHydrationView: View {
  let hydrationProgress: HydrationProgress

  var body: some View {
    ZStack {
      VStack {
        Spacer()

        HydrationProgressBar(hydrationProgress: hydrationProgress)
          .padding()

        Spacer()
      }
    }
  }
}

struct HistoryView: View {
  let entries: [IntakeEntry]?
  var onDelete: ((IntakeEntry) -> Void)?

  var body: some View {
    if let entries = entries, !entries.isEmpty {
      List {
        ForEach(entries) { entry in
          HistoryRow(entry: entry)
            .swipeActions {
              Button(role: .destructive, action: {
                onDelete?(entry)
              }, label: {
                Label("Delete", systemImage: "trash.fill")
              })
            }
        }
      }
    } else {
      Text("There is no data yet 😔").padding()
    }
  }
}

struct HistoryRow: View {
  let entry: IntakeEntry

  @EnvironmentObject var formatter: MeasurementFormatter

  var body: some View {
    HStack {
      Text(entry.drinkType.rawValue.capitalizingFirstLetter())

      Spacer()

      Text(formatter.string(from: entry.amount))
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static let progress = HydrationProgress(
    progress: 75,
    intookWaterAmount: .init(value: 1500, unit: .milliliters),
    date: .now,
    history: [
      IntakeEntry(guid: UUID(), drinkType: .water, amount: .init(value: 100, unit: .milliliters), createdAt: .now),
      IntakeEntry(guid: UUID(), drinkType: .coffee, amount: .init(value: 250, unit: .milliliters), createdAt: .now),
      IntakeEntry(guid: UUID(), drinkType: .water, amount: .init(value: 350, unit: .milliliters), createdAt: .now),
      IntakeEntry(guid: UUID(), drinkType: .juice, amount: .init(value: 400, unit: .milliliters), createdAt: .now),
      IntakeEntry(guid: UUID(), drinkType: .tea, amount: .init(value: 150, unit: .milliliters), createdAt: .now),
      IntakeEntry(guid: UUID(), drinkType: .water, amount: .init(value: 250, unit: .milliliters), createdAt: .now)
    ]
  )

  static let formatter: MeasurementFormatter = {
    let formatter = MeasurementFormatter()
    formatter.unitOptions = .providedUnit

    return formatter
  }()

  static var previews: some View {
    Group {
      ContentView()
        .environmentObject(PhoneConnectivityService())

      HistoryView(entries: progress.history)

      HistoryView(entries: nil)

      CurrentHydrationView(hydrationProgress: progress)
    }
    .environmentObject(formatter)
  }
}
