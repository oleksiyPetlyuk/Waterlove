//
//  ComplicationViews.swift
//  WaterloveWatch WatchKit Extension
//
//  Created by Oleksiy Petlyuk on 02.02.2022.
//

import SwiftUI
import ClockKit

struct ComplicationViewCircular: View {
  let hydrationProgress: HydrationProgress

  var body: some View {
    ZStack {
      ProgressView(
        "\(hydrationProgress.progress)",
        value: Double(hydrationProgress.progress) / 100,
        total: 1.0
      )
        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
    }
  }
}

struct ComplicationViewCornerCircular: View {
  let hydrationProgress: HydrationProgress

  var body: some View {
    ZStack {
      Text("\(hydrationProgress.progress)").foregroundColor(.white)
      Circle()
        .trim(from: 0.0, to: min(CGFloat(hydrationProgress.progress) / 100, 1))
        .stroke(.blue, lineWidth: 5)
        .rotationEffect(Angle(degrees: 270))
    }
  }
}

struct ComplicationViews_Previews: PreviewProvider {
  static let templateProvider = ComplicationTemplateProvider()

  static let progress = HydrationProgress(
    progress: 75,
    intookWaterAmount: .init(value: 1500, unit: .milliliters),
    date: .now
  )

  static var previews: some View {
    Group {
      templateProvider.make(for: progress, complicationFamily: .circularSmall)?.previewContext()

      templateProvider.make(for: progress, complicationFamily: .graphicCircular)?.previewContext()

      templateProvider.make(for: progress, complicationFamily: .graphicCorner)?.previewContext()

      templateProvider.make(for: progress, complicationFamily: .modularSmall)?.previewContext()

      templateProvider.make(for: progress, complicationFamily: .utilitarianSmall)?.previewContext()

      templateProvider.make(for: progress, complicationFamily: .utilitarianLarge)?.previewContext()
    }
  }
}
