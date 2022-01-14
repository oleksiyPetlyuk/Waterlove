//
//  HistoryStateMachineTests.swift
//  WaterloveTests
//
//  Created by Oleksiy Petlyuk on 13.01.2022.
//

import XCTest
@testable import Waterlove

class HistoryStateMachineTests: XCTestCase {
  func test_Transitions() {
    enum TestCaseError: Error {
      case error
    }

    struct TestCase {
      var stateFrom: HistoryStateMachine.State
      var event: HistoryStateMachine.Event
      var stateTo: HistoryStateMachine.State
      var file: StaticString
      var line: UInt

      init(
        stateFrom: HistoryStateMachine.State,
        event: HistoryStateMachine.Event,
        stateTo: HistoryStateMachine.State,
        file: StaticString = #file,
        line: UInt = #line
      ) {
        self.stateFrom = stateFrom
        self.event = event
        self.stateTo = stateTo
        self.file = file
        self.line = line
      }
    }

    let error = TestCaseError.error
    let emptyProps = HistoryViewController.Props.initial
    let propsWithData = HistoryViewController.Props(
      entries: [
        .init(
          id: UUID(),
          drinkType: .water,
          amount: .init(value: 100, unit: .milliliters),
          waterAmount: .init(value: 100, unit: .milliliters),
          createdAt: .now,
          canEdit: true,
          didDelete: .nop
        )
      ],
      searchInterval: .week,
      recommendedDailyAmount: nil,
      didChangeSearchInterval: .nop
    )

    let testCases: [TestCase] = [
      .init(stateFrom: .idle, event: .startLoading, stateTo: .loading),
      .init(stateFrom: .idle, event: .loadingFailed(error), stateTo: .idle),
      .init(stateFrom: .idle, event: .loadingFinished(emptyProps), stateTo: .idle),

      .init(stateFrom: .loading, event: .loadingFailed(error), stateTo: .error(error)),
      .init(stateFrom: .loading, event: .loadingFinished(emptyProps), stateTo: .empty),
      .init(stateFrom: .loading, event: .loadingFinished(propsWithData), stateTo: .list(propsWithData)),
      .init(stateFrom: .loading, event: .startLoading, stateTo: .loading),

      .init(stateFrom: .error(error), event: .startLoading, stateTo: .loading),
      .init(stateFrom: .error(error), event: .loadingFinished(propsWithData), stateTo: .error(error)),
      .init(stateFrom: .error(error), event: .loadingFailed(error), stateTo: .error(error)),

      .init(stateFrom: .empty, event: .startLoading, stateTo: .loading),
      .init(stateFrom: .empty, event: .loadingFailed(error), stateTo: .empty),
      .init(stateFrom: .empty, event: .loadingFinished(propsWithData), stateTo: .empty),

      .init(stateFrom: .list(propsWithData), event: .startLoading, stateTo: .loading),
      .init(stateFrom: .list(propsWithData), event: .loadingFinished(propsWithData), stateTo: .list(propsWithData)),
      .init(stateFrom: .list(propsWithData), event: .loadingFailed(error), stateTo: .list(propsWithData))
    ]

    for testCase in testCases {
      let sut = HistoryStateMachine(with: testCase.stateFrom)
      sut.transition(with: testCase.event)
      XCTAssertEqual(sut.state, testCase.stateTo, file: testCase.file, line: testCase.line)
    }
  }
}
