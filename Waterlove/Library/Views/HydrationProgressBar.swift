//
//  HydrationProgressBar.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 28.01.2022.
//

import SwiftUI

struct HydrationProgressBar: View {
  var hydrationProgress: HydrationProgress

  private let formatter: MeasurementFormatter = {
    let formatter = MeasurementFormatter()
    formatter.unitOptions = .providedUnit

    return formatter
  }()

  var body: some View {
    ZStack {
      SwiftUIViews.CircularProgressBar(progress: hydrationProgress.progress)

      VStack {
        Text("\(min(hydrationProgress.progress, 100)) %")
          .font(.title2)
          .bold()

        Text(formatter.string(from: hydrationProgress.intookWaterAmount.converted(to: .liters)))
          .font(.body)
          .bold()
      }
    }
  }
}

struct HydrationProgressBar_Previews: PreviewProvider {
  static var previews: some View {
    let hydrationProgress = HydrationProgress(
      progress: 75,
      intookWaterAmount: Measurement<UnitVolume>(value: 1500, unit: .milliliters),
      date: .now
    )

    HydrationProgressBar(hydrationProgress: hydrationProgress)
  }
}
