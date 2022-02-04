//
//  ContentView.swift
//  WaterloveWatch WatchKit Extension
//
//  Created by Oleksiy Petlyuk on 28.01.2022.
//

import SwiftUI
import Foundation

struct ContentView: View {
  @State private var pageIndex = 1

  @EnvironmentObject var phoneConnectivityService: PhoneConnectivityService

  var body: some View {
    TabView(selection: $pageIndex) {
      HistoryView().tag(0)
      CurrentHydrationView(hydrationProgress: phoneConnectivityService.hydrationProgress).tag(1)
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

struct Hero: Identifiable {
  let id = UUID()
  let name: String
}

struct HistoryView: View {
  let heroes = [
    Hero(name: "One"),
    Hero(name: "Two"),
    Hero(name: "Three"),
    Hero(name: "Four"),
    Hero(name: "Five"),
    Hero(name: "Six")
  ]

  var body: some View {
    List {
      ForEach(heroes) { hero in
        Text(hero.name)
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .environmentObject(PhoneConnectivityService())

    HistoryView()

    CurrentHydrationView(hydrationProgress: HydrationProgress(
      progress: 75,
      intookWaterAmount: .init(value: 1500, unit: .milliliters),
      date: .now
    ))
  }
}
