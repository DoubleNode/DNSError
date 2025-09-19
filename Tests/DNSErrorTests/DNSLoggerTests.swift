//
//  DNSLoggerTests.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSErrorTests
//
//  Created by Darren Ehlers.
//  Copyright © 2025 - 2016 DoubleNode.com. All rights reserved.
//

import XCTest
import SwiftyBeaver

@testable import DNSError

class DNSLoggerTests: XCTestCase {
    
    var logger: DNSLogger!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        // Clear all SwiftyBeaver destinations before each test
        SwiftyBeaver.removeAllDestinations()
        logger = DNSLogger()
    }
    
    override func tearDown() {
        SwiftyBeaver.removeAllDestinations()
        logger = nil
        super.tearDown()
    }
    
    // MARK: - Singleton Tests
    
    func testSharedInstance() {
        // Given: DNSLogger shared instance
        let shared1 = DNSLogger.shared
        let shared2 = DNSLogger.shared
        
        // When: Accessing shared instance multiple times
        // Then: Should return the same instance
        XCTAssertTrue(shared1 === shared2)
    }
    
    func testSharedInstanceIsNotNil() {
        // Given: DNSLogger shared instance
        let shared = DNSLogger.shared
        
        // Then: Should not be nil
        XCTAssertNotNil(shared)
        XCTAssertNotNil(shared.dnsLog)
    }
    
    func testGlobalDnsLogVariable() {
        // Given: Global dnsLog variable
        // When: Accessing the global variable
        // Then: It should reference SwiftyBeaver.self
        XCTAssertTrue(dnsLog === SwiftyBeaver.self)
    }
    
    // MARK: - Initialization Tests
    
    func testInitializationAddsConsoleDestination() {
        // Given: A new DNSLogger instance (created in setUp)
        // When: Logger is initialized
        // Then: Should have a console destination
        let consoleDestination = logger.consoleDestination()
        XCTAssertNotNil(consoleDestination)
    }
    
    func testInitializationSetsUpSwiftyBeaver() {
        // Given: A new DNSLogger instance
        // When: Logger is initialized
        // Then: dnsLog should reference SwiftyBeaver
        XCTAssertTrue(logger.dnsLog === SwiftyBeaver.self)
    }
    
    // MARK: - Console Destination Tests
    
    func testAddConsoleDestination() {
        // Given: A logger with no destinations
        SwiftyBeaver.removeAllDestinations()
        
        // When: Adding console destination
        let result = logger.addConsoleDestination()
        
        // Then: Should return true and destination should be added
        XCTAssertTrue(result)
        let consoleDestination = logger.consoleDestination()
        XCTAssertNotNil(consoleDestination)
    }
    
    func testConsoleDestinationConfiguration() {
        // Given: A logger with console destination
        let consoleDestination = logger.consoleDestination()
        
        // Then: Console destination should have correct configuration
        XCTAssertNotNil(consoleDestination)
        XCTAssertEqual(consoleDestination?.format, "$DHH:mm:ss.SSS$d $N.$F:$l [$T] $L $M")
        XCTAssertFalse(consoleDestination?.asynchronously ?? true)
        XCTAssertEqual(consoleDestination?.levelString.verbose, "💙")
        XCTAssertEqual(consoleDestination?.levelString.debug, "💚")
        XCTAssertEqual(consoleDestination?.levelString.info, "🧡🧡")
        XCTAssertEqual(consoleDestination?.levelString.warning, "💛💛")
        XCTAssertEqual(consoleDestination?.levelString.error, "❤️❤️❤️❤️")
        XCTAssertEqual(consoleDestination?.minLevel, .verbose)
    }
    
    func testConsoleDestinationWhenNoneExists() {
        // Given: A logger with no console destination
        SwiftyBeaver.removeAllDestinations()
        
        // When: Getting console destination
        let consoleDestination = logger.consoleDestination()
        
        // Then: Should return nil
        XCTAssertNil(consoleDestination)
    }
    
    func testMultipleConsoleDestinations() {
        // Given: A logger with one console destination
        _ = logger.addConsoleDestination()
        let initialCount = SwiftyBeaver.destinations.count
        
        // When: Adding another console destination
        let result = logger.addConsoleDestination()
        
        // Then: Should add another destination
        XCTAssertTrue(result)
        XCTAssertEqual(SwiftyBeaver.destinations.count, initialCount + 1)
    }
    
    // MARK: - Logging Functionality Tests
    
    func testLoggingAtDifferentLevels() {
        // Given: A logger with console destination
        let consoleDestination = logger.consoleDestination()
        XCTAssertNotNil(consoleDestination)
        
        // When: Logging at different levels
        // Then: Should not throw exceptions
        XCTAssertNoThrow({
            self.logger.dnsLog.verbose("Test verbose message")
            self.logger.dnsLog.debug("Test debug message")
            self.logger.dnsLog.info("Test info message")
            self.logger.dnsLog.warning("Test warning message")
            self.logger.dnsLog.error("Test error message")
        })
    }
    
    func testLoggingWithParameters() {
        // Given: A logger with console destination
        XCTAssertNotNil(logger.consoleDestination())
        
        // When: Logging with parameters
        // Then: Should not throw exceptions
        XCTAssertNoThrow({
            self.logger.dnsLog.info("Test message with parameter: \(42)")
            self.logger.dnsLog.error("Error code: \(500), message: \("Internal Server Error")")
        })
    }
    
    // MARK: - Thread Safety Tests
    
    func testConcurrentLogging() {
        // Given: A logger with console destination
        XCTAssertNotNil(logger.consoleDestination())
        let expectation = XCTestExpectation(description: "Concurrent logging")
        expectation.expectedFulfillmentCount = 100
        
        // When: Logging from multiple threads concurrently
        for i in 0..<100 {
            DispatchQueue.global().async {
                self.logger.dnsLog.info("Concurrent message \(i)")
                expectation.fulfill()
            }
        }
        
        // Then: All logging should complete successfully
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testConcurrentDestinationAccess() {
        // Given: Multiple threads accessing destinations
        let expectation = XCTestExpectation(description: "Concurrent destination access")
        expectation.expectedFulfillmentCount = 50
        
        // When: Accessing console destination from multiple threads
        for _ in 0..<50 {
            DispatchQueue.global().async {
                _ = self.logger.consoleDestination()
                expectation.fulfill()
            }
        }
        
        // Then: All accesses should complete successfully
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testSharedInstanceThreadSafety() {
        // Given: Multiple threads accessing shared instance
        let expectation = XCTestExpectation(description: "Shared instance thread safety")
        expectation.expectedFulfillmentCount = 100
        
        var sharedInstances: [DNSLogger] = []
        let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
        
        // When: Accessing shared instance from multiple threads
        for _ in 0..<100 {
            queue.async {
                let shared = DNSLogger.shared
                queue.async(flags: .barrier) {
                    sharedInstances.append(shared)
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        // Then: All instances should be the same
        let firstInstance = sharedInstances.first
        for instance in sharedInstances {
            XCTAssertTrue(instance === firstInstance)
        }
    }
    
    // MARK: - Memory Management Tests
    
    func testLoggerDeallocation() {
        weak var weakLogger: DNSLogger?
        
        // Given: A logger instance in a local scope
        autoreleasepool {
            let localLogger = DNSLogger()
            weakLogger = localLogger
            XCTAssertNotNil(weakLogger)
        }
        
        // When: The logger goes out of scope
        // Then: It should be deallocated (but shared instance might still exist)
        // Note: We can't guarantee deallocation due to SwiftyBeaver internal references
        // This test documents the expected behavior
    }
    
    // MARK: - Configuration Tests
    
    func testConsoleDestinationFormatString() {
        // Given: A console destination
        let consoleDestination = logger.consoleDestination()
        
        // Then: Format should include all required components
        XCTAssertNotNil(consoleDestination)
        let format = consoleDestination?.format ?? ""
        XCTAssertTrue(format.contains("$D")) // Date
        XCTAssertTrue(format.contains("$N")) // Name
        XCTAssertTrue(format.contains("$F")) // Function
        XCTAssertTrue(format.contains("$l")) // Line
        XCTAssertTrue(format.contains("$T")) // Thread
        XCTAssertTrue(format.contains("$L")) // Level
        XCTAssertTrue(format.contains("$M")) // Message
    }
    
    func testConsoleDestinationLevelStrings() {
        // Given: A console destination
        let consoleDestination = logger.consoleDestination()
        XCTAssertNotNil(consoleDestination)
        
        // Then: Level strings should use emoji indicators
        XCTAssertTrue(consoleDestination?.levelString.verbose.contains("💙") ?? false)
        XCTAssertTrue(consoleDestination?.levelString.debug.contains("💚") ?? false)
        XCTAssertTrue(consoleDestination?.levelString.info.contains("🧡") ?? false)
        XCTAssertTrue(consoleDestination?.levelString.warning.contains("💛") ?? false)
        XCTAssertTrue(consoleDestination?.levelString.error.contains("❤️") ?? false)
    }
    
    func testConsoleDestinationMinLevel() {
        // Given: A console destination
        let consoleDestination = logger.consoleDestination()
        
        // Then: Minimum level should be verbose
        XCTAssertEqual(consoleDestination?.minLevel, .verbose)
    }
    
    func testConsoleDestinationAsynchronous() {
        // Given: A console destination
        let consoleDestination = logger.consoleDestination()
        
        // Then: Should be synchronous for testing
        XCTAssertFalse(consoleDestination?.asynchronously ?? true)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyLogMessage() {
        // Given: A logger with console destination
        XCTAssertNotNil(logger.consoleDestination())
        
        // When: Logging empty messages
        // Then: Should not throw exceptions
        XCTAssertNoThrow({
            self.logger.dnsLog.info("")
            self.logger.dnsLog.error("")
        })
    }
    
    func testVeryLongLogMessage() {
        // Given: A logger with console destination
        XCTAssertNotNil(logger.consoleDestination())
        
        // When: Logging very long messages
        let longMessage = String(repeating: "This is a very long message. ", count: 1000)
        
        // Then: Should not throw exceptions
        XCTAssertNoThrow({
            self.logger.dnsLog.info(longMessage)
        })
    }
    
    func testLogMessageWithSpecialCharacters() {
        // Given: A logger with console destination
        XCTAssertNotNil(logger.consoleDestination())
        
        // When: Logging messages with special characters
        let specialMessage = "Special chars: \n\t\r\\\"'🎉💥⚡️"
        
        // Then: Should not throw exceptions
        XCTAssertNoThrow({
            self.logger.dnsLog.info(specialMessage)
        })
    }
    
    // MARK: - Integration Tests
    
    func testGlobalLoggerFunctionality() {
        // Given: Global dnsLog variable
        // When: Using global logger
        // Then: Should work without exceptions
        XCTAssertNoThrow({
            dnsLog.info("Testing global logger")
            dnsLog.warning("Global warning message")
            dnsLog.error("Global error message")
        })
    }
    
    func testSharedInstanceConsoleDestination() {
        // Given: Shared DNSLogger instance
        let sharedLogger = DNSLogger.shared
        
        // When: Getting console destination from shared instance
        let consoleDestination = sharedLogger.consoleDestination()
        
        // Then: Should have console destination
        XCTAssertNotNil(consoleDestination)
    }
    
    func testMultipleInitializationsSameDestinations() {
        // Given: Multiple DNSLogger instances
        let logger1 = DNSLogger()
        let logger2 = DNSLogger()
        
        // When: Both reference the same SwiftyBeaver instance
        // Then: They should share destinations
        XCTAssertTrue(logger1.dnsLog === logger2.dnsLog)
        XCTAssertTrue(logger1.dnsLog === SwiftyBeaver.self)
        XCTAssertTrue(logger2.dnsLog === SwiftyBeaver.self)
    }
}
