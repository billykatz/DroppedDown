//
//  Logger.swift
//  DownFall
//
//  Created by Katz, Billy on 2/8/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation
import os

class UITestRunningChecker {
    static let shared = UITestRunningChecker()
    
    var testsAreRunning : Bool {
        var uiTestAreRunning = false
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-isUITest") {
            uiTestAreRunning = true
        }
        #endif
        return uiTestAreRunning
    }
}

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    /// Logs everything in shift shaft.
    static let shiftShaft = OSLog(subsystem: subsystem, category: "ShiftShaft")
}

class GameLogger: TextOutputStream {
    
    func write(_ string: String) {
        os_log("%s", log: OSLog.shiftShaft, string)
    }
    
    
    static let shared = GameLogger()

    func log(prefix: String, message: String) {
        os_log("%s: %s", log: OSLog.shiftShaft, prefix, message)
    }

    func fatalLog(prefix: String, message: String) {
        log(prefix: prefix, message: message)
        if !UITestRunningChecker.shared.testsAreRunning {
            fatalError()
        }
    }
}
