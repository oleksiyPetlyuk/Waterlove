//
//  Command.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 13.12.2021.
//

typealias Command = CommandWith<Void>

struct CommandWith<T> {
  private var action: (T) -> Void

  static var nop: CommandWith { return CommandWith { _ in } }

  init(action: @escaping (T) -> Void) {
    self.action = action
  }

  func perform(with value: T) {
    self.action(value)
  }
}

extension CommandWith where T == Void {
  func perform() {
    self.perform(with: ())
  }
}
