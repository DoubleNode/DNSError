//
//  CodeLocationThreadSafetyTests.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSErrorTests
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//
//  Dedicated thread safety tests for CodeLocation with Thread Sanitizer support
//

import XCTest
@preconcurrency import ObjectiveC
import Foundation
import os.lock

@testable import DNSError

final class CodeLocationThreadSafetyTests: XCTestCase {
    
    // Thread-safe test infrastructure using sendable types
    private let atomicCounter = OSAllocatedUnfairLock(initialState: 0)
    
    // Sendable test object for Swift 6 compliance
    private struct SendableTestObject: Sendable {
        let identifier: String
        let timestamp: Date
        
        init(identifier: String) {
            self.identifier = identifier
            self.timestamp = Date()
        }
    }
    
    override func setUp() {
        super.setUp()
        atomicCounter.withLock { $0 = 0 }
        CodeLocation.filenamePathRoots = []
    }
    
    override func tearDown() {
        CodeLocation.filenamePathRoots = []
        super.tearDown()
    }
    
    // MARK: - Swift 6 TaskGroup Tests
    
    func testConcurrentCodeLocationCreation() async {
        let iterations = 100
        let expectation = XCTestExpectation(description: "Concurrent CodeLocation creation")
        
        // Capture the counter reference to avoid self capture
        let counter = self.atomicCounter
        
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<iterations {
                group.addTask {
                    let testObject = SendableTestObject(identifier: UUID().uuidString)
                    let location = CodeLocation(testObject)
                    
                    // Verify all properties are accessible
                    XCTAssertFalse(location.asString.isEmpty)
                    XCTAssertNotNil(location.userInfo)
                    XCTAssertNotNil(location.timeStamp)
                    
                    // Thread-safe counter increment
                    counter.withLock { $0 += 1 }
                }
            }
        }
        
        let finalCount = counter.withLock { $0 }
        XCTAssertEqual(finalCount, iterations)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 30.0)
    }
    
    func testConcurrentPathRootManagement() async {
        let iterations = 50
        let expectation = XCTestExpectation(description: "Concurrent path root management")
        
        await withTaskGroup(of: Void.self) { group in
            // Concurrent additions
            for index in 0..<iterations {
                group.addTask {
                    CodeLocation.addFilenamePathRoot("/concurrent/path/\(index)")
                }
            }
            
            // Concurrent reads
            for _ in 0..<iterations {
                group.addTask {
                    let roots = CodeLocation.filenamePathRoots
                    XCTAssertNotNil(roots)
                }
            }
            
            // Concurrent path shortening
            for index in 0..<iterations {
                group.addTask {
                    let path = "/some/test/path/\(index)/file.swift"
                    let shortened = CodeLocation.shortenErrorPath(path)
                    XCTAssertNotNil(shortened)
                }
            }
        }
        
        // Verify path roots were added
        let finalRoots = CodeLocation.filenamePathRoots
        XCTAssertGreaterThanOrEqual(finalRoots.count, iterations)
        
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 30.0)
    }
    
    func testConcurrentStringOperations() async {
        let iterations = 100
        let expectation = XCTestExpectation(description: "Concurrent string operations")
        
        // Capture counter reference to avoid self capture
        let counter = self.atomicCounter
        
        await withTaskGroup(of: Void.self) { group in
            for index in 0..<iterations {
                group.addTask {
                    // Test shortenErrorObject concurrently
                    let objectName = CodeLocation.shortenErrorObject("TestObject\(index)")
                    XCTAssertFalse(objectName.isEmpty)
                    
                    // Test shortenErrorPath concurrently
                    let path = CodeLocation.shortenErrorPath("/path/\(index)/file.swift")
                    XCTAssertFalse(path.isEmpty)
                    
                    // Test string concatenation operator
                    let testObject = SendableTestObject(identifier: "StringTest\(index)")
                    let location = CodeLocation(testObject)
                    let combined = "Error: " + location
                    XCTAssertTrue(combined.hasPrefix("Error: "))
                    
                    // Thread-safe counter
                    counter.withLock { $0 += 1 }
                }
            }
        }
        
        let finalCount = counter.withLock { $0 }
        XCTAssertEqual(finalCount, iterations)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 30.0)
    }
    
    // MARK: - High-Concurrency Stress Tests
    
    func testHighConcurrencyStress() async {
        let iterations = 500
        let concurrentTasks = 20
        let expectation = XCTestExpectation(description: "High concurrency stress test")
        
        // Capture counter reference
        let counter = self.atomicCounter
        
        await withTaskGroup(of: Void.self) { group in
            for taskIndex in 0..<concurrentTasks {
                group.addTask {
                    let taskIterations = iterations / concurrentTasks
                    
                    for innerIndex in 0..<taskIterations {
                        autoreleasepool {
                            let testObject = SendableTestObject(
                                identifier: "Task\(taskIndex)-Item\(innerIndex)"
                            )
                            
                            // Create location with concurrent access
                            let location = CodeLocation(testObject)
                            
                            // Exercise all properties
                            _ = location.asString
                            _ = location.userInfo
                            _ = location.failureReason
                            _ = location.domain
                            _ = location.file
                            _ = location.line
                            _ = location.method
                            _ = location.timeStamp
                            
                            // Perform operations on shared state
                            CodeLocation.addFilenamePathRoot("/stress/\(taskIndex)/\(innerIndex)")
                            _ = CodeLocation.filenamePathRoots.count
                            _ = CodeLocation.shortenErrorPath("/test/path/\(innerIndex)")
                            
                            // Thread-safe counting
                            counter.withLock { $0 += 1 }
                        }
                    }
                }
            }
        }
        
        let finalCount = counter.withLock { $0 }
        XCTAssertEqual(finalCount, iterations)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 60.0)
    }
    
    // MARK: - Memory Pressure Tests
    
    func testMemoryPressureWithConcurrency() async {
        let iterations = 1000
        let batchCount = 10
        let expectation = XCTestExpectation(description: "Memory pressure test")
        
        await withTaskGroup(of: Void.self) { group in
            for batchIndex in 0..<batchCount {
                group.addTask {
                    let batchSize = iterations / batchCount
                    
                    for itemIndex in 0..<batchSize {
                        autoreleasepool {
                            let testObject = SendableTestObject(
                                identifier: "Batch\(batchIndex)-Item\(itemIndex)"
                            )
                            let location = CodeLocation(testObject)
                            
                            // Force property evaluation to ensure full object lifecycle
                            _ = location.asString.count
                            _ = location.userInfo.keys.count
                            _ = location.domain.count
                            
                            // Occasional shared state access
                            if itemIndex % 50 == 0 {
                                CodeLocation.addFilenamePathRoot("/memory/\(batchIndex)/\(itemIndex)")
                            }
                        }
                    }
                }
            }
        }
        
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 60.0)
    }
    
    // MARK: - Edge Case Handling Under Concurrency
    
    func testEdgeCaseHandlingWithConcurrentAccess() async {
        let iterations = 100
        let expectation = XCTestExpectation(description: "Edge case handling with concurrent access")
        
        // Capture counter reference
        let counter = self.atomicCounter
        
        await withTaskGroup(of: Void.self) { group in
            for index in 0..<iterations {
                group.addTask {
                    // Test with various problematic inputs
                    let testInputs = [
                        "ValidObject\(index)",
                        "", // Empty string
                        "Object with spaces \(index)",
                        "Object/with/slashes/\(index)",
                        "Object\nwith\nnewlines\(index)"
                    ]
                    
                    for input in testInputs {
                        let location = CodeLocation(input)
                        
                        // All operations should succeed without throwing
                        _ = location.asString
                        _ = location.userInfo
                        _ = location.failureReason
                        
                        // Test string operations with edge cases
                        _ = CodeLocation.shortenErrorObject(input)
                        _ = CodeLocation.shortenErrorPath("/path/\(input)/file.swift")
                    }
                    
                    counter.withLock { $0 += 1 }
                }
            }
        }
        
        let finalCount = counter.withLock { $0 }
        
        XCTAssertEqual(finalCount, iterations, "All operations should complete successfully")
        
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 30.0)
    }
    
    // MARK: - Thread Sanitizer Validation
    
    func testThreadSanitizerValidation() async {
        // Use the extension methods for comprehensive validation
        #if DEBUG
        CodeLocation.performThreadSafetyTest(iterations: 50)
        #endif
        
        // Additional manual validation
        let expectation = XCTestExpectation(description: "Thread sanitizer validation")
        let iterations = 50
        
        // Capture counter reference
        let counter = self.atomicCounter
        
        await withTaskGroup(of: Void.self) { group in
            for index in 0..<iterations {
                group.addTask {
                    // Mix of read and write operations
                    if index % 2 == 0 {
                        // Write operations
                        CodeLocation.addFilenamePathRoot("/sanitizer/write/\(index)")
                        let testObject = SendableTestObject(identifier: "WriteTest\(index)")
                        let location = CodeLocation(testObject)
                        _ = location.asString
                    } else {
                        // Read operations
                        _ = CodeLocation.filenamePathRoots.count
                        let testObject = SendableTestObject(identifier: "ReadTest\(index)")
                        let location = CodeLocation(testObject)
                        _ = location.userInfo
                    }
                    
                    counter.withLock { $0 += 1 }
                }
            }
        }
        
        let finalCount = counter.withLock { $0 }
        XCTAssertEqual(finalCount, iterations)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 15.0)
    }
    
    // MARK: - Performance Under Concurrency
    
    func testPerformanceWithConcurrency() {
        let iterations = 1000
        
        measure {
            let expectation = XCTestExpectation(description: "Performance measurement")
            
            Task {
                await withTaskGroup(of: Void.self) { group in
                    for index in 0..<iterations {
                        group.addTask {
                            let testObject = SendableTestObject(identifier: "PerfTest\(index)")
                            let location = CodeLocation(testObject)
                            _ = location.asString
                            _ = location.userInfo
                        }
                    }
                }
                
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    // MARK: - Race Condition Detection
    
    func testRaceConditionDetection() async {
        let iterations = 200
        let expectation = XCTestExpectation(description: "Race condition detection")
        
        // Capture counter reference
        let counter = self.atomicCounter
        
        // This test specifically tries to trigger race conditions
        await withTaskGroup(of: Void.self) { group in
            // Simultaneous readers and writers
            for index in 0..<iterations {
                // Writer task
                group.addTask {
                    CodeLocation.addFilenamePathRoot("/race/writer/\(index)")
                }
                
                // Reader task
                group.addTask {
                    _ = CodeLocation.filenamePathRoots
                }
                
                // Mixed operation task
                group.addTask {
                    let testObject = SendableTestObject(identifier: "RaceTest\(index)")
                    let location = CodeLocation(testObject)
                    _ = location.asString
                    
                    counter.withLock { $0 += 1 }
                }
            }
        }
        
        let finalCount = counter.withLock { $0 }
        XCTAssertEqual(finalCount, iterations)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 30.0)
    }
    
    // MARK: - Traditional DispatchQueue Tests (for comparison)
    
    func testTraditionalConcurrentAccess() {
        let iterations = 50
        let expectation = XCTestExpectation(description: "Traditional concurrent access")
        let queue = DispatchQueue(label: "test.concurrent", attributes: .concurrent)
        let group = DispatchGroup()
        
        // Capture counter reference
        let counter = self.atomicCounter
        
        for i in 0..<iterations {
            group.enter()
            queue.async {
                defer { group.leave() }
                
                let testObject = SendableTestObject(identifier: "Traditional\(i)")
                let location = CodeLocation(testObject)
                
                // Test concurrent access
                _ = location.asString
                _ = location.userInfo
                
                // Add path roots concurrently
                CodeLocation.addFilenamePathRoot("/traditional/\(i)")
                
                counter.withLock { $0 += 1 }
            }
        }
        
        group.notify(queue: .main) {
            let finalCount = counter.withLock { $0 }
            XCTAssertEqual(finalCount, iterations)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    // MARK: - Swift 6 Actor Pattern Preparation (Future)
    
    @available(iOS 16.0, *)
    func testActorCompatibilityPreparation() async {
        // Test that CodeLocation works well with actor isolation
        actor TestActor {
            private var errorCount = 0
            
            func processError(_ object: String) -> CodeLocation {
                errorCount += 1
                return CodeLocation(object)
            }
            
            func getErrorCount() -> Int {
                errorCount
            }
        }
        
        let testActor = TestActor()
        
        // Test multiple concurrent calls to actor
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask {
                    let location = await testActor.processError("ActorTest\(i)")
                    XCTAssertFalse(location.asString.isEmpty)
                }
            }
        }
        
        let finalCount = await testActor.getErrorCount()
        XCTAssertEqual(finalCount, 10)
    }
}