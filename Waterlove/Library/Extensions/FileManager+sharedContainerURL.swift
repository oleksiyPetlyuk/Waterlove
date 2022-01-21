//
//  FileManager+sharedContainerURL.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 21.01.2022.
//

import Foundation

extension FileManager {
  static func sharedContainerURL() -> URL {
    // swiftlint:disable:next force_unwrapping line_length
    return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.oleksiy.petlyuk.Waterlove")!
  }
}
