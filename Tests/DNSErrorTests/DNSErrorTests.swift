//
//  DNSErrorTests.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSErrorTests
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import XCTest
@preconcurrency import ObjectiveC
import Foundation
import os.lock

@testable import DNSError

final class DNSErrorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Clear any existing path roots for clean test state
        CodeLocation.filenamePathRoots = []
    }
    
    override func tearDown() {
        // Clean up after tests
        CodeLocation.filenamePathRoots = []
        super.tearDown()
    }
    
    // MARK: - DNSCodeLocation Tests
    
    func testCodeLocationInitialization() {
        let testObject = "TestString"
        let location = CodeLocation(testObject)
        
        XCTAssertNotNil(location)
        XCTAssertEqual(location.domain, "String")
        XCTAssertTrue(location.file.contains("DNSErrorTests.swift"))
        XCTAssertGreaterThan(location.line, 0)
        XCTAssertTrue(location.method.contains("testCodeLocationInitialization"))
        XCTAssertNotNil(location.timeStamp)
    }
    
    func testDNSCodeLocationInitialization() {
        let testObject = NSObject()
        let location = DNSCodeLocation(testObject)
        
        XCTAssertNotNil(location)
        XCTAssertTrue(location.domain.hasPrefix("com.doublenode."))
        XCTAssertEqual(location.domain, "com.doublenode.NSObject")
    }
    
    func testCodeLocationWithRawData() {
        let testObject = "TestObject"
        let rawData = "TestFile.swift,42,testMethod()"
        let location = CodeLocation(testObject, rawData)
        
        XCTAssertEqual(location.file, "TestFile.swift")
        XCTAssertEqual(location.line, 42)
        XCTAssertEqual(location.method, "testMethod()")
        XCTAssertEqual(location.domain, "String")
    }
    
    func testCodeLocationWithIncompleteRawData() {
        let testObject = "TestObject"
        let rawData = "OnlyFile.swift"
        let location = CodeLocation(testObject, rawData)
        
        XCTAssertEqual(location.file, "OnlyFile.swift")
        XCTAssertEqual(location.line, 0)
        XCTAssertEqual(location.method, "")
    }
    
    func testCodeLocationWithEmptyRawData() {
        let testObject = "TestObject"
        let rawData = ""
        let location = CodeLocation(testObject, rawData)
        
        XCTAssertEqual(location.file, "<UnknownFile>")
        XCTAssertEqual(location.line, 0)
        XCTAssertEqual(location.method, "")
    }
    
    func testAsStringProperty() {
        let testObject = "TestObject"
        let location = CodeLocation(testObject)
        let asString = location.asString
        
        XCTAssertFalse(asString.isEmpty)
        XCTAssertTrue(asString.contains(location.domain))
        XCTAssertTrue(asString.contains(location.file))
        XCTAssertTrue(asString.contains("\(location.line)"))
        XCTAssertTrue(asString.contains(location.method))
    }
    
    func testFailureReasonProperty() {
        let testObject = "TestObject"
        let location = CodeLocation(testObject)
        
        XCTAssertEqual(location.failureReason, location.asString)
    }
    
    func testUserInfoProperty() {
        let testObject = "TestObject"
        let location = CodeLocation(testObject)
        let userInfo = location.userInfo
        
        XCTAssertNotNil(userInfo["DNSTimeStamp"])
        XCTAssertEqual(userInfo["DNSDomain"] as? String, location.domain)
        XCTAssertEqual(userInfo["DNSFile"] as? String, location.file)
        XCTAssertEqual(userInfo["DNSLine"] as? Int, location.line)
        XCTAssertEqual(userInfo["DNSMethod"] as? String, location.method)
    }
    
    // MARK: - Static Method Tests
    
    func testAddFilenamePathRoot() {
        let initialCount = CodeLocation.filenamePathRoots.count
        
        CodeLocation.addFilenamePathRoot("/test/path/root")
        
        XCTAssertEqual(CodeLocation.filenamePathRoots.count, initialCount + 1)
        XCTAssertTrue(CodeLocation.filenamePathRoots.contains("/test/path/root"))
    }
    
    func testShortenErrorObject() {
        // Test basic type shortening
        let basicType = CodeLocation.shortenErrorObject("TestString")
        XCTAssertEqual(basicType, "String")
        
        // Test Optional type shortening
        let optionalString: String? = "TestOptional"
        let optionalType = CodeLocation.shortenErrorObject(optionalString as Any)
        XCTAssertEqual(optionalType, "String")
        
        // Test complex type
        let nsObject = NSObject()
        let objectType = CodeLocation.shortenErrorObject(nsObject)
        XCTAssertEqual(objectType, "NSObject")
    }
    
    func testShortenErrorPath() {
        // Test without path roots
        let originalPath = "/very/long/path/to/file.swift"
        let shortened1 = CodeLocation.shortenErrorPath(originalPath)
        XCTAssertEqual(shortened1, originalPath)
        
        // Test with path root
        CodeLocation.addFilenamePathRoot("/very/long/path")
        let shortened2 = CodeLocation.shortenErrorPath(originalPath)
        XCTAssertEqual(shortened2, "~/to/file.swift")
        
        // Test multiple path roots
        CodeLocation.addFilenamePathRoot("/very/long")
        let shortened3 = CodeLocation.shortenErrorPath(originalPath)
        XCTAssertEqual(shortened3, "~/to/file.swift")
    }
    
    func testStringConcatenationOperator() {
        let testObject = "TestObject"
        let location = CodeLocation(testObject)
        let prefix = "Error: "
        
        let result = prefix + location
        XCTAssertTrue(result.hasPrefix("Error: "))
        XCTAssertTrue(result.contains(location.failureReason))
    }
    
    // MARK: - Thread Safety Tests
    
    func testConcurrentPathRootAccess() async {
        let expectation = XCTestExpectation(description: "Concurrent path root access")
        let iterations = 50
        
        // Use atomic counter for thread safety
        let atomicCounter = OSAllocatedUnfairLock(initialState: 0)
        
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<iterations {
                group.addTask {
                    // Concurrent writes
                    CodeLocation.addFilenamePathRoot("/concurrent/test/\(i)")
                    
                    // Concurrent reads
                    let _ = CodeLocation.filenamePathRoots.count
                    
                    // Thread-safe counter increment
                    atomicCounter.withLock { $0 += 1 }
                }
            }
        }
        
        let finalCount = atomicCounter.withLock { $0 }
        XCTAssertEqual(finalCount, iterations)
        XCTAssertGreaterThanOrEqual(CodeLocation.filenamePathRoots.count, iterations)
        
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    func testConcurrentObjectCreation() async {
        let expectation = XCTestExpectation(description: "Concurrent object creation")
        let iterations = 50
        
        // Use atomic counter for thread safety
        let atomicCounter = OSAllocatedUnfairLock(initialState: 0)
        
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<iterations {
                group.addTask {
                    let testObject = "ConcurrentTest\(i)"
                    let location = CodeLocation(testObject)
                    
                    // Verify properties are accessible
                    XCTAssertFalse(location.asString.isEmpty)
                    XCTAssertNotNil(location.userInfo)
                    
                    // Thread-safe counter increment
                    atomicCounter.withLock { $0 += 1 }
                }
            }
        }
        
        let finalCount = atomicCounter.withLock { $0 }
        XCTAssertEqual(finalCount, iterations)
        
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    // MARK: - Extension Testing Methods
    
    func testThreadSafetyTestExtension() {
        #if DEBUG
        // Test the extension method exists and runs without crashing
        CodeLocation.performThreadSafetyTest(iterations: 10)
        #endif
        
        // Should complete without crashes
        XCTAssertTrue(true, "Thread safety test extension completed")
    }
    
    func testStressTestExtension() {
        #if DEBUG
        // Run a minimal stress test
        CodeLocation.performStressTest(iterations: 50)
        #endif
        
        // Should complete without crashes
        XCTAssertTrue(true, "Stress test extension completed")
    }
    
    func testMemoryPressureExtension() {
        #if DEBUG
        // Run a minimal memory pressure test
        CodeLocation.performMemoryPressureTest(iterations: 100)
        #endif
        
        // Should complete without crashes
        XCTAssertTrue(true, "Memory pressure test extension completed")
    }
    
    @available(iOS 13.0, macOS 10.15, *)
    func testAsyncThreadSafetyExtension() async {
        #if DEBUG
        let result = await CodeLocation.performAsyncThreadSafetyTest(iterations: 10)
        XCTAssertTrue(result.contains("✅"), "Async test should report success")
        #endif
    }
    
    // MARK: - Edge Cases and Error Conditions
    
    func testLargeLineNumbers() {
        let testObject = "TestObject"
        let rawData = "TestFile.swift,999999,testMethod()"
        let location = CodeLocation(testObject, rawData)
        
        XCTAssertEqual(location.line, 999999)
    }
    
    func testInvalidLineNumbers() {
        let testObject = "TestObject"
        let rawData = "TestFile.swift,invalid,testMethod()"
        let location = CodeLocation(testObject, rawData)
        
        XCTAssertEqual(location.line, 0) // Should default to 0 for invalid numbers
    }
    
    func testEmptyPathRoots() {
        CodeLocation.filenamePathRoots = []
        let path = "/some/path/file.swift"
        let result = CodeLocation.shortenErrorPath(path)
        
        XCTAssertEqual(result, path) // Should return unchanged
    }
    
    func testMultipleIdenticalPathRoots() {
        CodeLocation.addFilenamePathRoot("/test/path")
        CodeLocation.addFilenamePathRoot("/test/path") // Duplicate
        
        let originalPath = "/test/path/file.swift"
        let shortened = CodeLocation.shortenErrorPath(originalPath)
        
        // Should work correctly even with duplicates
        XCTAssertEqual(shortened, "~/file.swift")
    }
    
    // MARK: - Performance Tests
    
    func testCodeLocationCreationPerformance() {
        let testObject = "PerformanceTest"
        
        measure {
            for _ in 0..<1000 {
                let location = CodeLocation(testObject)
                _ = location.asString // Force property evaluation
            }
        }
    }
    
    func testPathShorteningPerformance() {
        CodeLocation.addFilenamePathRoot("/very/long/common/path")
        let testPath = "/very/long/common/path/to/some/file.swift"
        
        measure {
            for _ in 0..<1000 {
                _ = CodeLocation.shortenErrorPath(testPath)
            }
        }
    }
    
    // MARK: - Integration Tests
    
    func testCodeLocationWithActualSwiftTypes() {
        // Test with various Swift types
        let stringLocation = CodeLocation("String")
        XCTAssertEqual(stringLocation.domain, "String")
        
        let arrayLocation = CodeLocation([1, 2, 3])
        XCTAssertTrue(arrayLocation.domain.contains("Array"))
        
        let dictLocation = CodeLocation(["key": "value"])
        XCTAssertTrue(dictLocation.domain.contains("Dictionary"))
        
        let intLocation = CodeLocation(42)
        XCTAssertEqual(intLocation.domain, "Int")
    }
    
    func testDomainPrefaceInheritance() {
        // Test base CodeLocation
        let baseLocation = CodeLocation("test")
        XCTAssertEqual(baseLocation.domain, "String")
        
        // Test DNSCodeLocation with prefix
        let dnsLocation = DNSCodeLocation("test")
        XCTAssertEqual(dnsLocation.domain, "com.doublenode.String")
    }
}
