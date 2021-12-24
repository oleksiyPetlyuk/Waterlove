//
//  IntakeEntryEntityMapper.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 23.12.2021.
//

import Foundation

class IntakeEntryEntityMapper: DBEntityMapper<IntakeEntry, IntakeEntryEntity> {
  override func convert(_ entity: IntakeEntryEntity) -> IntakeEntry? {
    return IntakeEntry(
      guid: entity.guid,
      drinkType: entity.drinkType,
      amount: entity.amount,
      createdAt: entity.createdAt
    )
  }

  override func update(_ entity: IntakeEntryEntity, by model: IntakeEntry) {
    entity.guid = model.guid
    entity.drinkType = model.drinkType
    entity.amount = model.amount.converted(to: .milliliters)
    entity.createdAt = model.createdAt
  }

  override func entityAccessorKey(_ object: IntakeEntry) -> UUID {
    return object.guid
  }

  override func entityAccessorKey(_ entity: IntakeEntryEntity) -> UUID {
    return entity.guid
  }
}
