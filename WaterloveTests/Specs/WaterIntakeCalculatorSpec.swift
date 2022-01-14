//
//  WaterIntakeCalculatorSpec.swift
//  WaterloveTests
//
//  Created by Oleksiy Petlyuk on 13.01.2022.
//

import Foundation
import Quick
import Nimble
@testable import Waterlove

class WaterIntakeCalculatorSpec: QuickSpec {
  override func spec() {
    describe("calculator") {
      let sut = WaterIntakeCalculator()

      describe("it calculates water intake") {
        context("when a gender is male") {
          it("should return a valid water intake amount") {
            let amount = sut.calculate(gender: .male, weight: .init(value: 75, unit: .kilograms))
            let targetAmount: Measurement<UnitVolume> = .init(value: 2625, unit: .milliliters)

            expect(amount).to(equal(targetAmount))
          }
        }

        context("when a gender is female") {
          it("should return a valid water intake amount") {
            let amount = sut.calculate(gender: .female, weight: .init(value: 75, unit: .kilograms))
            let targetAmount: Measurement<UnitVolume> = .init(value: 2325, unit: .milliliters)

            expect(amount).to(equal(targetAmount))
          }
        }
      }
    }
  }
}
