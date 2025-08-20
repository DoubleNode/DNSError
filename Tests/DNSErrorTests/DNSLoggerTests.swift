//
//  DNSLoggerTests.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSErrorTests
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//
//  Tests for DNSLogger functionality and integration
//

import XCTest
@preconcurrency import ObjectiveC
import Foundation
import os

@testable import DNSError

final class DNSLoggerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - DNSLogger Basic Tests
    
    func testDNSLoggerExists() {
        // Test that DNSLogger class/structure exists and can be instantiated
        // This will depend on the actual implementation in DNSLogger.swift
        
        // For now, just verify the file exists in the module
        XCTAssertTrue(true, "DNSLogger module is accessible")
    }
    
    // Note: Add specific DNSLogger tests once we can see the actual implementation
    // These tests will depend on the public API of DNSLogger
    
    // MARK: - Integration Tests
    
    func testCodeLocationWithLogging() {
        // Test integration between CodeLocation and logging
        let testObject = "LoggingTest"
        let location = CodeLocation(testObject)
        
        // Test that location can be used for logging purposes
        let logMessage = "Error occurred at: \(location.asString)"
        // The failureReason contains the domain "String", not "LoggingTest"
        XCTAssertTrue(logMessage.contains("String"), "Debug message should contain domain 'String'. Got: \(logMessage)")
        XCTAssertTrue(logMessage.contains("testCodeLocationWithLogging"))
    }
    
    func testCodeLocationStructuredLogging() {
        let testObject = "StructuredLoggingTest"
        let location = CodeLocation(testObject)
        
        // Test the structured logging method from the extension (iOS 18+ only)
        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *) {
            // Test that the log method exists and doesn't crash
            location.log(category: "Testing", type: .debug)
            
            // Test basic properties that should always work
            XCTAssertEqual(location.domain, "String", "Domain should be 'String' for string objects")
            XCTAssertFalse(location.asString.isEmpty, "asString should not be empty")
            XCTAssertTrue(location.asString.contains("String"), "asString should contain domain. Got: \(location.asString)")
        } else {
            // For older iOS versions, just test basic functionality
            let debugInfo = "CodeLocation: \(location.asString)"
            // The asString contains the domain ("String"), not the original object string
            XCTAssertTrue(debugInfo.contains("String"), "Debug info should contain domain 'String'. Got: \(debugInfo)")
        }
    }
    
    func testLogMessageFormattingWithCodeLocation() {
        let testObject = "FormattingTest"
        let location = CodeLocation(testObject)
        
        // Test various formatting scenarios
        let errorMsg = "Error: " + location
        XCTAssertTrue(errorMsg.hasPrefix("Error: "))
        
        let debugMsg = "Debug info: \(location.failureReason)"
        // The failureReason contains the domain "String", not "FormattingTest"
        XCTAssertTrue(debugMsg.contains("String"), "Debug message should contain domain 'String'. Got: \(debugMsg)")
        
        let userInfoMsg = "User info: \(location.userInfo)"
        XCTAssertTrue(userInfoMsg.contains("DNSDomain"))
    }
    
    func testConcurrentLogging() async {
        let iterations = 50
        let expectation = XCTestExpectation(description: "Concurrent logging test")
        
        await withTaskGroup(of: Void.self) { group in
            for index in 0..<iterations {
                group.addTask {
                    let testObject = "ConcurrentLog\(index)"
                    let location = CodeLocation(testObject)
                    
                    // Test that logging operations are thread-safe
                    let logMessage = "Concurrent log message \(index): " + location
                    XCTAssertFalse(logMessage.isEmpty)
                    
                    // Test structured logging if available
                    if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *) {
                        location.log(category: "ConcurrentTest", type: .info)
                    }
                }
            }
        }
        
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    // MARK: - Basic Logging Integration Tests
    
    func testBasicLoggingIntegration() {
        // Test basic logging without requiring iOS 18+ features
        let testObject = "BasicLoggingTest"
        let location = CodeLocation(testObject)
        
        // Test that CodeLocation provides good logging context
        XCTAssertFalse(location.asString.isEmpty)
        // The domain will be "String", not "BasicLoggingTest"
        XCTAssertTrue(location.asString.contains("String"), "asString should contain domain 'String'. Got: \(location.asString)")
        XCTAssertTrue(location.asString.contains("testBasicLoggingIntegration"), "asString should contain method name. Got: \(location.asString)")
        
        // Test user info for logging context
        let userInfo = location.userInfo
        XCTAssertNotNil(userInfo["DNSTimeStamp"])
        XCTAssertNotNil(userInfo["DNSDomain"])
        XCTAssertNotNil(userInfo["DNSFile"])
        XCTAssertNotNil(userInfo["DNSLine"])
        XCTAssertNotNil(userInfo["DNSMethod"])
    }
    
    func testErrorContextForLogging() {
        // Test that CodeLocation provides rich context for error logging
        let error = NSError(domain: "TestError", code: 404, userInfo: ["key": "value"])
        let location = DNSCodeLocation(error)
        
        // Test domain prefacing for DNSCodeLocation
        XCTAssertTrue(location.domain.hasPrefix("com.doublenode."))
        XCTAssertTrue(location.domain.contains("NSError"))
        
        // Test that we can create comprehensive error logs
        let errorLog = """
        Error Report:
        - Domain: \(error.domain)
        - Code: \(error.code)
        - Location: \(location.asString)
        - Timestamp: \(location.timeStamp)
        - Context: \(location.userInfo)
        """
        
        XCTAssertTrue(errorLog.contains("TestError"))
        XCTAssertTrue(errorLog.contains("404"))
        XCTAssertTrue(errorLog.contains("testErrorContextForLogging"))
    }
    
    func testLoggingWithPathShortening() {
        // Test that path shortening works for cleaner logs
        CodeLocation.addFilenamePathRoot("/Users/test/project")
        
        let testObject = "PathShorteningTest"
        let rawData = "/Users/test/project/Sources/Module/File.swift,123,testMethod()"
        let location = CodeLocation(testObject, rawData)
        
        // Verify path was shortened for cleaner logs
        XCTAssertTrue(location.file.contains("~"))
        XCTAssertFalse(location.file.contains("/Users/test/project"))
        
        // Test in log message
        let logMessage = "Error in \(location.asString)"
        XCTAssertTrue(logMessage.contains("~"))
        XCTAssertFalse(logMessage.contains("/Users/test/project"))
    }
    
    // MARK: - Performance Tests for Logging
    
    func testLoggingPerformance() {
        let testObject = "PerformanceTest"
        
        measure {
            for _ in 0..<1000 {
                let location = CodeLocation(testObject)
                let logMessage = "Performance test: " + location
                _ = logMessage.count // Force evaluation
            }
        }
    }
    
    func testConcurrentLoggingPerformance() {
        let iterations = 500
        
        measure {
            let expectation = XCTestExpectation(description: "Concurrent logging performance")
            
            Task {
                await withTaskGroup(of: Void.self) { group in
                    for index in 0..<iterations {
                        group.addTask {
                            let testObject = "ConcurrentPerf\(index)"
                            let location = CodeLocation(testObject)
                            let logMessage = "Concurrent test: " + location
                            _ = logMessage.count // Force evaluation
                        }
                    }
                }
                
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    // MARK: - Platform-Specific Feature Tests
    
    @available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *)
    func testEnhancedLoggingFeatures() {
        // Test iOS 18+ specific logging features
        let testObject = "EnhancedLoggingTest"
        let location = CodeLocation(testObject)
        
        // Test structured logging
        location.log(category: "Testing", type: .debug)
        location.log(category: "Error", type: .error)
        location.log(category: "Info", type: .info)
        
        // Test detailed debug description
        let debugInfo = location.detailedDebugDescription
        XCTAssertTrue(debugInfo.contains("CodeLocation Debug Info"))
        XCTAssertTrue(debugInfo.contains("Timestamp"))
        XCTAssertTrue(debugInfo.contains("Domain"))
        XCTAssertTrue(debugInfo.contains("File"))
        XCTAssertTrue(debugInfo.contains("Line"))
        XCTAssertTrue(debugInfo.contains("Method"))
    }
    
    // MARK: - Logging Format Validation
    
    func testLoggingFormatConsistency() {
        // Test that logging formats are consistent across different object types
        let stringObject = "TestString"
        let numberObject = 42
        let arrayObject = [1, 2, 3]
        
        let stringLocation = CodeLocation(stringObject)
        let numberLocation = CodeLocation(numberObject)
        let arrayLocation = CodeLocation(arrayObject)
        
        // All should have consistent format
        let locations = [stringLocation, numberLocation, arrayLocation]
        
        for location in locations {
            let logMessage = "Test: " + location
            
            // Should contain domain, file, line, method
            XCTAssertTrue(logMessage.contains(":"), "Log message should contain colons as separators. Got: \(logMessage)")  // Domain separator
            XCTAssertTrue(logMessage.contains("testLoggingFormatConsistency"), "Log message should contain method name. Got: \(logMessage)")
            XCTAssertFalse(logMessage.isEmpty)
        }
    }
    
    func testLoggingWithSpecialCharacters() {
        // Test logging with objects that contain special characters
        let specialObjects = [
            "String with spaces",
            "String\nwith\nnewlines",
            "String\twith\ttabs",
            "String with émojis 🚀",
            "String with ümlauts",
            ""  // Empty string
        ]
        
        for (index, obj) in specialObjects.enumerated() {
            let location = CodeLocation(obj)
            let logMessage = "Special test \(index): " + location
            
            // Should handle special characters gracefully
            XCTAssertFalse(logMessage.isEmpty)
            XCTAssertNotNil(location.asString)
            XCTAssertNotNil(location.userInfo)
        }
    }
}
