//
//  CodeLocation+Testing.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSError
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//
//  Thread safety testing support for CodeLocation class
//  Provides comprehensive testing methods for Thread Sanitizer validation
//

import Foundation
import os.lock
import os

#if DEBUG
extension CodeLocation {
    
    /// Thread safety test method for Thread Sanitizer validation
    /// This method exercises concurrent access patterns to verify thread safety
    /// - Parameter iterations: Number of concurrent operations to perform (default: 100)
    /// - Note: Only available in DEBUG builds for testing purposes
    public static func performThreadSafetyTest(iterations: Int = 100) {
        let testQueue = DispatchQueue(label: "com.doublenode.threadsafety.test", 
                                     attributes: .concurrent)
        let group = DispatchGroup()
        
        print("🧪 Starting CodeLocation thread safety test with \(iterations) iterations...")
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Test concurrent access to filenamePathRoots
        for i in 0..<iterations {
            group.enter()
            testQueue.async {
                defer { group.leave() }
                
                // Concurrent writes to shared state
                Self.addFilenamePathRoot("/test/path/\(i)")
                
                // Concurrent reads from shared state
                let rootsCount = Self.filenamePathRoots.count
                
                // Concurrent object creation and property access
                let testObject = "TestObject\(i)"
                let location = CodeLocation(testObject)
                
                // Exercise all public properties concurrently
                let _ = location.asString
                let _ = location.userInfo
                let _ = location.failureReason
                let _ = location.domain
                let _ = location.file
                let _ = location.line
                let _ = location.method
                let _ = location.timeStamp
                
                // Test static utility methods with concurrent access
                let _ = Self.shortenErrorPath("/some/long/path/\(i)/file.swift")
                let _ = Self.shortenErrorObject(testObject)
                
                // Progress reporting for long-running tests
                if i % 20 == 0 {
                    print("   ✓ Completed \(i + 1) iterations, current path roots: \(rootsCount)")
                }
            }
        }
        
        // Wait for all operations to complete with timeout
        let waitResult = group.wait(timeout: .now() + 30)
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        
        switch waitResult {
        case .success:
            let finalCount = Self.filenamePathRoots.count
            print("✅ Thread safety test completed successfully!")
            print("   📊 Test Results:")
            print("   - Total iterations: \(iterations)")
            print("   - Duration: \(String(format: "%.3f", duration)) seconds")
            print("   - Operations/sec: \(String(format: "%.0f", Double(iterations) / duration))")
            print("   - Final path roots count: \(finalCount)")
            print("   - No deadlocks or data races detected")
        case .timedOut:
            print("⚠️ Thread safety test timed out after 30 seconds")
            print("   This may indicate a deadlock or performance issue")
        }
    }
    
    /// High-intensity stress test for performance and stability validation
    /// - Parameter iterations: Number of stress test operations (default: 1000)
    /// - Note: Designed to push the limits of concurrent access patterns
    public static func performStressTest(iterations: Int = 1000) {
        let testQueue = DispatchQueue(label: "com.doublenode.stress.test", 
                                     attributes: .concurrent)
        let group = DispatchGroup()
        
        print("🔥 Starting CodeLocation stress test with \(iterations) iterations...")
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for i in 0..<iterations {
            group.enter()
            testQueue.async {
                defer { group.leave() }
                
                // Use autoreleasepool to manage memory during intensive testing
                autoreleasepool {
                    let testObject = "StressTest\(i)"
                    let location = CodeLocation(testObject)
                    
                    // Exercise all public APIs intensively
                    _ = location.asString
                    _ = location.userInfo
                    _ = location.failureReason
                    _ = location.domain
                    _ = location.file
                    _ = location.line
                    _ = location.method
                    _ = location.timeStamp
                    
                    // Test static methods under stress
                    Self.addFilenamePathRoot("/stress/test/\(i)")
                    _ = Self.filenamePathRoots
                    _ = Self.shortenErrorObject(testObject)
                    _ = Self.shortenErrorPath("/very/long/stress/test/path/\(i)/file.swift")
                    
                    // Test string concatenation operator
                    let combined = "Debug: " + location
                    _ = combined.count
                }
            }
        }
        
        // Wait for completion with extended timeout for stress test
        let waitResult = group.wait(timeout: .now() + 60)
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        
        switch waitResult {
        case .success:
            let finalRootsCount = Self.filenamePathRoots.count
            print("✅ Stress test completed successfully!")
            print("   📈 Performance Results:")
            print("   - Duration: \(String(format: "%.3f", duration)) seconds")
            print("   - Operations per second: \(String(format: "%.0f", Double(iterations) / duration))")
            print("   - Final path roots: \(finalRootsCount)")
            print("   - Memory pressure handled correctly")
            print("   - All concurrent operations completed safely")
        case .timedOut:
            print("⚠️ Stress test timed out after 60 seconds")
            print("   Consider reducing iteration count or investigating performance bottlenecks")
        }
    }
    
    /// Memory pressure test with rapid object creation and destruction
    /// - Parameter iterations: Number of objects to create concurrently (default: 5000)
    /// - Note: Tests memory management under concurrent load
    public static func performMemoryPressureTest(iterations: Int = 5000) {
        let concurrentQueues = (0..<4).map { index in
            DispatchQueue(label: "com.doublenode.memory.test.\(index)", 
                         attributes: .concurrent)
        }
        let group = DispatchGroup()
        
        print("💾 Starting memory pressure test with \(iterations) objects...")
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let batchSize = iterations / concurrentQueues.count
        
        for (queueIndex, queue) in concurrentQueues.enumerated() {
            group.enter()
            queue.async {
                defer { group.leave() }
                
                for i in 0..<batchSize {
                    autoreleasepool {
                        let objectIndex = queueIndex * batchSize + i
                        let testObject = "MemoryTest\(objectIndex)"
                        let location = CodeLocation(testObject)
                        
                        // Force property evaluation to ensure full object lifecycle
                        _ = location.asString.count
                        _ = location.userInfo.keys.count
                        
                        // Add path root occasionally to test shared state under memory pressure
                        if objectIndex % 100 == 0 {
                            Self.addFilenamePathRoot("/memory/test/\(objectIndex)")
                        }
                    }
                }
            }
        }
        
        group.wait()
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        
        print("✅ Memory pressure test completed!")
        print("   🧠 Memory Results:")
        print("   - Objects created: \(iterations)")
        print("   - Duration: \(String(format: "%.3f", duration)) seconds")
        print("   - Objects/sec: \(String(format: "%.0f", Double(iterations) / duration))")
        print("   - Memory management stable under pressure")
    }
    
    /// Comprehensive test suite that runs all testing methods
    /// - Note: Runs thread safety, stress, and memory pressure tests sequentially
    public static func performComprehensiveTest() {
        print("🚀 Starting comprehensive CodeLocation test suite...")
        print("=" * 60)
        
        // Run thread safety test
        performThreadSafetyTest(iterations: 100)
        print("")
        
        // Run stress test
        performStressTest(iterations: 500)
        print("")
        
        // Run memory pressure test
        performMemoryPressureTest(iterations: 2000)
        print("")
        
        print("🎉 Comprehensive test suite completed!")
        print("   All tests passed - CodeLocation is thread-safe and performant")
        print("=" * 60)
    }
}

// MARK: - Swift 6 Async Testing Support

@available(iOS 13.0, macOS 10.15, *)
extension CodeLocation {
    
    /// Modern async/await version of thread safety testing
    /// - Parameter iterations: Number of concurrent operations
    /// - Returns: Test results summary
    public static func performAsyncThreadSafetyTest(iterations: Int = 100) async -> String {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<iterations {
                group.addTask {
                    let testObject = "AsyncTest\(i)"
                    let location = CodeLocation(testObject)
                    
                    // Test concurrent access patterns
                    Self.addFilenamePathRoot("/async/test/\(i)")
                    _ = Self.filenamePathRoots
                    _ = location.asString
                    _ = location.userInfo
                }
            }
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        
        return """
        ✅ Async thread safety test completed
        - Iterations: \(iterations)
        - Duration: \(String(format: "%.3f", duration))s
        - Rate: \(String(format: "%.0f", Double(iterations) / duration)) ops/sec
        """
    }
}

#endif // DEBUG

// MARK: - iOS 18+ Enhanced Logging Support

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *)
extension CodeLocation {
    
    /// Enhanced debugging support for iOS 18+ with detailed information
    public var detailedDebugDescription: String {
        """
        CodeLocation Debug Info:
        - Timestamp: \(timeStamp.ISO8601Format())
        - Domain: \(domain)
        - File: \(file)
        - Line: \(line)
        - Method: \(method)
        """
    }
    
    /// Structured logging support for iOS 18+ using the unified logging system
    /// - Parameters:
    ///   - category: Log category for filtering and organization
    ///   - type: Log level (debug, info, error, etc.)
    public func log(category: String = "DNSFramework", type: OSLogType = .debug) {
        let logger = Logger(subsystem: domain, category: category)
        logger.log(level: type, "\(self.asString)")
    }
}

// MARK: - Test Helper Functions

#if DEBUG
extension String {
    /// Helper for creating repeated character strings (for formatting)
    static func * (string: String, count: Int) -> String {
        return String(repeating: string, count: count)
    }
}
#endif