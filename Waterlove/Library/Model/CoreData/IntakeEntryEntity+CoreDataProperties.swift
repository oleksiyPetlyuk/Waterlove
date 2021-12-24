//
//  IntakeEntry+CoreDataProperties.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 22.12.2021.
//
//

import Foundation
import CoreData

extension IntakeEntryEntity {
  @NSManaged var guid: UUID
  @NSManaged private var drinkTypeValue: String
  @NSManaged private var amountValue: Double
  @NSManaged var createdAt: Date

  var drinkType: DrinkType {
    get {
      return DrinkType(rawValue: drinkTypeValue) ?? .water
    }

    set {
      drinkTypeValue = newValue.rawValue
    }
  }

  var amount: Measurement<UnitVolume> {
    get {
      return .init(value: amountValue, unit: .milliliters)
    }

    set {
      amountValue = newValue.value
    }
  }
}

extension IntakeEntryEntity: Identifiable {}
