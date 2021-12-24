//
//  DBEntityMapper.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 23.12.2021.
//

import Foundation

class DBEntityMapper<DomainModel, Entity> {
  func convert(_ entity: Entity) -> DomainModel? {
    fatalError("convert(_ entity: Entity: must be overridden")
  }

  func update(_ entity: Entity, by model: DomainModel) {
    fatalError("update(_ entity: Entity: must be overridden")
  }

  func entityAccessorKey(_ entity: Entity) -> UUID {
    fatalError("entityAccessorKey must be overridden")
  }

  func entityAccessorKey(_ object: DomainModel) -> UUID {
    fatalError("entityAccessorKey must be overridden")
  }
}
