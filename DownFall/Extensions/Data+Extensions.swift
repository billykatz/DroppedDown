//
//  JSONHelper.swift
//  DownFall
//
//  Created by William Katz on 6/9/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

extension Data {
    static func data(from fileName: String) throws -> Data? {
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                return try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            }
            catch let err {
                GameLogger.shared.fatalLog(prefix: "[Data Extension]", message: "Error loading json file. \(err)")
            }
        }
        return nil
    }
}
