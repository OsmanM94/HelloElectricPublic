//
//  Logger.swift
//  Clin
//
//  Created by asia on 05/09/2024.
//

import Foundation
import os

struct Logger {
    private static let logger = os.Logger(subsystem: Bundle.main.bundleIdentifier!, category: "HelloElectric")
    
    static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let filename = (file as NSString).lastPathComponent
        logger.debug("DEBUG: [\(filename):\(line)] \(function) - \(message)")
    }
    
    static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let filename = (file as NSString).lastPathComponent
        logger.info("INFO: [\(filename):\(line)] \(function) - \(message)")
    }
    
    static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let filename = (file as NSString).lastPathComponent
        logger.error("ERROR: [\(filename):\(line)] \(function) - \(message)")
    }
}
