//
//  String+capitalizeFirstLetter.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 27.12.2021.
//

import Foundation

extension String {
  func capitalizingFirstLetter() -> String {
    return prefix(1).capitalized + dropFirst()
  }

  mutating func capitalizeFirstLetter() {
    self = self.capitalizingFirstLetter()
  }
}
