//
//  HydrationProgress.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 28.01.2022.
//

import Foundation

struct HydrationProgress: Codable {
  let progress: UInt8
  let intookWaterAmount: Measurement<UnitVolume>
  let date: Date
}
