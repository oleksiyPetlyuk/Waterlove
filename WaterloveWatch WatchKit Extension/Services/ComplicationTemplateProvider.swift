//
//  ComplicationTemplateProvider.swift
//  WaterloveWatch WatchKit Extension
//
//  Created by Oleksiy Petlyuk on 04.02.2022.
//

import Foundation
import ClockKit
import SwiftUI

class ComplicationTemplateProvider {
  private let formatter: MeasurementFormatter = {
    let formatter = MeasurementFormatter()
    formatter.unitOptions = .providedUnit

    return formatter
  }()

  func make(for hydrationProgress: HydrationProgress, complicationFamily: CLKComplicationFamily) -> CLKComplicationTemplate? {
    switch complicationFamily {
    case .circularSmall:
      return makeCircularSmall(for: hydrationProgress)
    case .graphicCircular:
      return makeGraphicCircular(for: hydrationProgress)
    case .graphicCorner:
      return makeGraphicCornerCircular(for: hydrationProgress)
    case .modularSmall:
      return makeModularSmall(for: hydrationProgress)
    case .utilitarianSmall:
      return makeUtilitarianSmall(for: hydrationProgress)
    case .utilitarianLarge:
      return makeUtilitarianLarge(for: hydrationProgress)
    default:
      return nil
    }
  }
}

private extension ComplicationTemplateProvider {
  func getDefaultText(_ hydrationProgress: HydrationProgress) -> CLKTextProvider {
    return CLKTextProvider(format: "%d", hydrationProgress.progress)
  }

  func getExtendedText(_ hydrationProgress: HydrationProgress) -> CLKTextProvider {
    return CLKTextProvider(
      format: "%d%% / %@",
      hydrationProgress.progress,
      formatter.string(from: hydrationProgress.intookWaterAmount.converted(to: .liters))
    )
  }

  func convertToFraction(_ value: UInt8) -> Float {
    return Float(value) / 100
  }

  func makeCircularSmall(for hydrationProgress: HydrationProgress) -> CLKComplicationTemplate {
    return CLKComplicationTemplateCircularSmallRingText(
      textProvider: getDefaultText(hydrationProgress),
      fillFraction: convertToFraction(hydrationProgress.progress),
      ringStyle: .closed
    )
  }

  func makeGraphicCircular(for hydrationProgress: HydrationProgress) -> CLKComplicationTemplate {
    return  CLKComplicationTemplateGraphicCircularView(
      ComplicationViewCircular(hydrationProgress: hydrationProgress)
    )
  }

  func makeGraphicCornerCircular(for hydrationProgress: HydrationProgress) -> CLKComplicationTemplate {
    return CLKComplicationTemplateGraphicCornerCircularView(
      ComplicationViewCornerCircular(hydrationProgress: hydrationProgress)
    )
  }

  func makeModularSmall(for hydrationProgress: HydrationProgress) -> CLKComplicationTemplate {
    return CLKComplicationTemplateModularSmallRingText(
      textProvider: getDefaultText(hydrationProgress),
      fillFraction: convertToFraction(hydrationProgress.progress),
      ringStyle: .closed
    )
  }

  func makeUtilitarianSmall(for hydrationProgress: HydrationProgress) -> CLKComplicationTemplate {
    return CLKComplicationTemplateUtilitarianSmallRingText(
      textProvider: getDefaultText(hydrationProgress),
      fillFraction: convertToFraction(hydrationProgress.progress),
      ringStyle: .closed
    )
  }

  func makeUtilitarianLarge(for hydrationProgress: HydrationProgress) -> CLKComplicationTemplate {
    return CLKComplicationTemplateUtilitarianLargeFlat(textProvider: getExtendedText(hydrationProgress))
  }
}
