//
//  WaterloveWidget.swift
//  WaterloveWidget
//
//  Created by Oleksiy Petlyuk on 20.01.2022.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
  // swiftlint:disable:next line_length
  private let placeholderProgress = HydrationProgress(progress: 75, intookWaterAmount: .init(value: 1500, unit: .milliliters), date: .now)

  func placeholder(in context: Context) -> WaterloveWidgetContent {
    return WaterloveWidgetContent(date: .now, hydrationProgress: placeholderProgress)
  }

  func getSnapshot(in context: Context, completion: @escaping (WaterloveWidgetContent) -> Void) {
    if context.isPreview {
      let entry = WaterloveWidgetContent(date: .now, hydrationProgress: placeholderProgress)

      completion(entry)

      return
    }

    completion(readWidgetContent())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    let currentDate = Date()
    let endDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? .now
    let startOfNextDay = Calendar.current.startOfDay(for: endDate)

    let entry = readWidgetContent()

    let timeline = Timeline(entries: [entry], policy: .after(startOfNextDay))

    completion(timeline)
  }

  private func readWidgetContent() -> WaterloveWidgetContent {
    var contents: HydrationProgress?
    let archiveURL = FileManager.sharedContainerURL().appendingPathComponent("widget_contents.json")

    if let data = try? Data(contentsOf: archiveURL) {
      do {
        contents = try JSONDecoder().decode(HydrationProgress.self, from: data)
      } catch {
        print("Error: Can`t decode widget contents")
      }
    }

    let defaultContent = WaterloveWidgetContent(
      date: .now,
      hydrationProgress: .init(progress: 0, intookWaterAmount: .init(value: 0, unit: .milliliters), date: .now)
    )

    guard let contents = contents else { return defaultContent }

    guard Calendar.current.isDate(contents.date, inSameDayAs: .now) else { return defaultContent }

    return WaterloveWidgetContent(date: .now, hydrationProgress: contents)
  }
}

struct WaterloveWidgetContent: TimelineEntry {
  let date: Date
  let hydrationProgress: HydrationProgress
}

struct WaterloveWidgetEntryView: View {
  var entry: Provider.Entry

  var body: some View {
    ZStack {
      Color(UIColor.systemBackground)
        .edgesIgnoringSafeArea(.all)

      VStack {
        Spacer()

        HydrationProgressBar(hydrationProgress: entry.hydrationProgress)
          .frame(width: 120, height: 120)

        Spacer()
      }
    }
  }
}

struct WaterloveWidgetPlaceholderView: View {
  var entry: Provider.Entry

  var body: some View {
    WaterloveWidgetEntryView(entry: entry)
      .redacted(reason: .placeholder)
  }
}

@main
struct WaterloveWidget: Widget {
  let kind: String = "WaterloveWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      WaterloveWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Waterlove Widget")
    .description("It helps to track your hydration progress.")
    .supportedFamilies([.systemSmall])
  }
}

struct WaterloveWidget_Previews: PreviewProvider {
  static var previews: some View {
    let entry = WaterloveWidgetContent(
      date: Date(),
      hydrationProgress: .init(progress: 75, intookWaterAmount: .init(value: 1500, unit: .milliliters), date: .now)
    )

    WaterloveWidgetEntryView(entry: entry)
      .previewContext(WidgetPreviewContext(family: .systemSmall))

    WaterloveWidgetPlaceholderView(entry: entry)
      .previewContext(WidgetPreviewContext(family: .systemSmall))
  }
}
