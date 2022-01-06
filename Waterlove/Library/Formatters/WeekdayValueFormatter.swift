//
//  WeekdayValueFormatter.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 06.01.2022.
//

import Foundation
import Charts

class WeekdayValueFormatter: AxisValueFormatter {
  func stringForValue(_ value: Double, axis: AxisBase?) -> String {
    guard let weekday = Weekday(rawValue: Int(value)) else { return "" }

    return weekday.shortDescription
  }
}
