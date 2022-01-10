//
//  IntakeEntry.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 23.12.2021.
//

import Foundation

final class IntakeEntry {
  var guid: UUID
  var drinkType: DrinkType
  var amount: Measurement<UnitVolume>
  var waterAmount: Measurement<UnitVolume> {
    let value = round(amount.converted(to: .milliliters).value * drinkType.waterAmountMultiplier)

    return .init(value: value, unit: .milliliters)
  }
  var createdAt: Date

  init(guid: UUID, drinkType: DrinkType, amount: Measurement<UnitVolume>, createdAt: Date) {
    self.guid = guid
    self.drinkType = drinkType
    self.amount = amount
    self.createdAt = createdAt
  }
}

extension IntakeEntry: Identifiable {}

extension IntakeEntry: Codable {
  enum CodingKeys: CodingKey {
    case guid, drinkType, amount, createdAt
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(guid, forKey: .guid)
    try container.encode(drinkType.rawValue, forKey: .drinkType)
    try container.encode(amount.value, forKey: .amount)
    try container.encode(createdAt, forKey: .createdAt)
  }

  convenience init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let guid = try container.decode(UUID.self, forKey: .guid)
    let drinkType = DrinkType(rawValue: try container.decode(String.self, forKey: .drinkType))
    let amount: Measurement<UnitVolume> = .init(
      value: try container.decode(Double.self, forKey: .amount),
      unit: .milliliters
    )
    let createdAt = try container.decode(Date.self, forKey: .createdAt)

    self.init(guid: guid, drinkType: drinkType ?? .water, amount: amount, createdAt: createdAt)
  }
}
