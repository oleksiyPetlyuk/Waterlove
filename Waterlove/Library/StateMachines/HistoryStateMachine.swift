//
//  HistoryStateMachine.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 06.01.2022.
//

import Foundation

protocol HistoryStateMachineObserver: AnyObject {
  func historyStateMachine(_ stateMachine: HistoryStateMachine, didEnter state: HistoryStateMachine.State)
}

class HistoryStateMachine {
  enum State {
    case idle
    case loading
    case error(Error)
    case empty
    case list(HistoryViewController.Props)
  }

  enum Event {
    case startLoading
    case loadingFailed(Error)
    case loadingFinished(HistoryViewController.Props)
  }

  var observer: HistoryStateMachineObserver?

  private(set) var state: State = .idle {
    didSet {
      guard oldValue != state else { return }

      observer?.historyStateMachine(self, didEnter: state)
    }
  }

  init(with state: State = .idle) {
    self.state = state
  }

  // swiftlint:disable:next cyclomatic_complexity
  func transition(with event: Event) {
    switch (state, event) {
    case (.idle, .startLoading):
      state = .loading
    case (.idle, _):
      break
    case let (.loading, .loadingFailed(error)):
      state = .error(error)
    case let (.loading, .loadingFinished(props)) where props.entries.isEmpty:
      state = .empty
    case let (.loading, .loadingFinished(props)):
      state = .list(props)
    case (.loading, _):
      break
    case (.error, .startLoading):
      state = .loading
    case (.error, _):
      break
    case (.empty, .startLoading):
      state = .loading
    case (.empty, _):
      break
    case (.list, .startLoading):
      state = .loading
    case (.list, _):
      break
    }
  }
}

extension HistoryStateMachine.State: Equatable {
  static func == (lhs: HistoryStateMachine.State, rhs: HistoryStateMachine.State) -> Bool {
    switch (lhs, rhs) {
    case let(.error(error1), .error(error2)):
      return error1.localizedDescription == error2.localizedDescription
    case let (.list(props1), .list(props2)):
      return props1 == props2
    case (.idle, .idle):
      return true
    case (.loading, .loading):
      return true
    case (.empty, .empty):
      return true
    default:
      return false
    }
  }
}
