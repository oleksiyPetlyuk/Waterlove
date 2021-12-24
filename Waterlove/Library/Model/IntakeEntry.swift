//
//  IntakeEntry.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 23.12.2021.
//

import Foundation

class IntakeEntry {
  var guid: UUID
  var drinkType: DrinkType
  var amount: Measurement<UnitVolume>
  var createdAt: Date

  init(guid: UUID, drinkType: DrinkType, amount: Measurement<UnitVolume>, createdAt: Date) {
    self.guid = guid
    self.drinkType = drinkType
    self.amount = amount
    self.createdAt = createdAt
  }
}

extension IntakeEntry: Identifiable {}
