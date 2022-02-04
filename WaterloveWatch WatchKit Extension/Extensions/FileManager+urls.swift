//
//  FileManager+urls.swift
//  WaterloveWatch WatchKit Extension
//
//  Created by Oleksiy Petlyuk on 04.02.2022.
//

import Foundation

extension FileManager {
  static func complicationDataURL() -> URL? {
    guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }

    return url.appendingPathComponent("complication_data.json")
  }
}
