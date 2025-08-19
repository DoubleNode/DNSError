//
//  DNSLogger.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSError
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import Foundation
import SwiftyBeaver

// Global logger instance - marked as MainActor for thread safety
@MainActor
public let dnsLog = DNSLogger.shared.dnsLog

// DNSLogger needs to be Sendable and thread-safe for Swift 6
@MainActor
public final class DNSLogger: Sendable {
    public static let shared = DNSLogger()

    public let dnsLog = SwiftyBeaver.self

    private var consoleDestinationRef: ConsoleDestination?

    private init() {
        self.addConsoleDestination()
    }

    @discardableResult
    public func addConsoleDestination() -> Bool {
        let console = ConsoleDestination()  // log to Xcode Console
        console.format = "$DHH:mm:ss.SSS$d $N.$F:$l [$T] $L $M"
        console.asynchronously = false
        console.levelString.verbose = "💙"
        console.levelString.debug = "💚"
        console.levelString.info = "🧡🧡"
        console.levelString.warning = "💛💛"
        console.levelString.error = "❤️❤️❤️❤️"
        console.minLevel = .verbose

        // Store reference to avoid accessing SwiftyBeaver.destinations later
        self.consoleDestinationRef = console
        return dnsLog.addDestination(console)
    }

    public func consoleDestination() -> ConsoleDestination? {
        return consoleDestinationRef
    }
}
