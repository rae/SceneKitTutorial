//
//  RBLog.swift
//  (Simple-) Logging functionality
//
//  Created by Roger Boesch on 02/04/16.
//  Copyright © 2016 Roger Boesch All rights reserved.
//

import Foundation

enum RBLogSeverity : Int {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    case none = 4
}

class RBLog: NSObject {

    // MARK: - Properties
    static var severity = RBLogSeverity.debug

    // MARK: - Logging severity

    static func error(message: String) {
        if (RBLogSeverity.error.rawValue >= RBLog.severity.rawValue) {
            RBLog.log(message: message, severity: "⛔️")
        }
    }

    static func warning(message: String) {
        if (RBLogSeverity.warning.rawValue >= RBLog.severity.rawValue) {
            RBLog.log(message: message, severity: "⚠️")
        }
    }

    static func info(message: String) {
        if (RBLogSeverity.info.rawValue >= RBLog.severity.rawValue) {
            RBLog.log(message: message, severity: "▷")
        }
    }

    static func debug(message: String) {
        if (RBLogSeverity.debug.rawValue >= RBLog.severity.rawValue) {
            RBLog.log(message: message, severity: "→")
        }
    }

    // MARK: - Write logs

    private static func log(message: String, severity: String) {
        RBLog.write(message: "\(severity) \(message)")
    }

    static func write(message: String) {
        print(message)
    }

}

// MARK: - Short functions

public func rbError(_ message: String,  _ args: CVarArg...) {
    let str = String(format: message, arguments: args)
    RBLog.error(message: str)
}

public func rbWarning(_ message: String,  _ args: CVarArg...) {
    let str = String(format: message, arguments: args)
    RBLog.warning(message: str)
}

public func rbInfo(_ message: String,  _ args: CVarArg...) {
    let str = String(format: message, arguments: args)
    RBLog.info(message: str)
}

public func rbDebug(_ message: String,  _ args: CVarArg...) {
    let str = String(format: message, arguments: args)
    RBLog.debug(message: str)
}
