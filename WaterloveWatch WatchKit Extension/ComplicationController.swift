//
//  ComplicationController.swift
//  WaterloveWatch WatchKit Extension
//
//  Created by Oleksiy Petlyuk on 28.01.2022.
//

import ClockKit
import SwiftUI

class ComplicationController: NSObject, CLKComplicationDataSource {
  let templateProvider = ComplicationTemplateProvider()

  // MARK: - Complication Configuration
  func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
    let descriptors = [
      CLKComplicationDescriptor(identifier: "complication", displayName: "Waterlove", supportedFamilies: [
        .graphicCorner,
        .graphicCircular,
        .circularSmall,
        .modularSmall,
        .utilitarianSmall,
        .utilitarianLarge
      ])
    ]

    handler(descriptors)
  }

  func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
    // Do any necessary work to support these newly shared complication descriptors
  }

  // MARK: - Timeline Configuration
  func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
    // Call the handler with the last entry date you can currently provide or nil if you can't support future timelines
    handler(nil)
  }

  func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
    // Call the handler with your desired behavior when the device is locked
    handler(.showOnLockScreen)
  }

  // MARK: - Timeline Population
  func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
    guard
      let data = readComplicationData(),
      let template = templateProvider.make(for: data, complicationFamily: complication.family)
    else {
      handler(nil)

      return
    }

    let entry = CLKComplicationTimelineEntry(date: .now, complicationTemplate: template)
    handler(entry)
  }

  func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
    // Call the handler with the timeline entries after the given date
    guard
      let data = readComplicationData(),
      let template = templateProvider.make(for: data, complicationFamily: complication.family)
    else {
      handler(nil)

      return
    }

    let entry = CLKComplicationTimelineEntry(date: .now, complicationTemplate: template)
    handler([entry])
  }

  // MARK: - Sample Templates
  func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
    // This method will be called once per supported complication, and the results will be cached
    let progress = HydrationProgress(
      progress: 75,
      intookWaterAmount: .init(value: 1500, unit: .milliliters),
      date: .now
    )
    let template = templateProvider.make(for: progress, complicationFamily: complication.family)
    handler(template)
  }
}

private extension ComplicationController {
  func readComplicationData() -> HydrationProgress? {
    guard let url = FileManager.complicationDataURL(), let data = try? Data(contentsOf: url) else { return nil }

    do {
      let progress = try JSONDecoder().decode(HydrationProgress.self, from: data)

      if Calendar.current.isDate(progress.date, inSameDayAs: .now) {
        return progress
      }
    } catch {
      print("Error: Can`t decode complication data")
    }

    return nil
  }
}
