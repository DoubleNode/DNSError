//
//  DNSErrorTests.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSErrorTests
//
//  Created by Darren Ehlers.
//  Copyright © 2025 - 2016 DoubleNode.com. All rights reserved.
//

import XCTest

@testable import DNSError

class DNSErrorTests: XCTestCase {
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - DNSError Protocol Tests
    
    func testDNSErrorProtocolConformance() {
        // Given: A custom error type conforming to DNSError
        struct TestError: DNSError {
            let errorDescription: String?
            
            init(description: String) {
                self.errorDescription = description
            }
        }
        
        // When: Creating an instance
        let error = TestError(description: "Test error message")
        
        // Then: It should conform to both DNSError and LocalizedError
        XCTAssertNotNil(error as DNSError)
        XCTAssertNotNil(error as LocalizedError)
        XCTAssertEqual(error.errorDescription, "Test error message")
    }
    
    func testDNSErrorWithNilDescription() {
        // Given: A custom error with nil description
        struct NilDescriptionError: DNSError {
            let errorDescription: String? = nil
        }
        
        // When: Creating an instance
        let error = NilDescriptionError()
        
        // Then: It should still conform to DNSError
        XCTAssertNotNil(error as DNSError)
        XCTAssertNil(error.errorDescription)
    }
    
    func testDNSErrorWithFailureReason() {
        // Given: A custom error with failure reason
        struct DetailedError: DNSError {
            let errorDescription: String?
            let failureReason: String?
            
            init(description: String, reason: String) {
                self.errorDescription = description
                self.failureReason = reason
            }
        }
        
        // When: Creating an instance
        let error = DetailedError(description: "Something went wrong", reason: "Network connection failed")
        
        // Then: Both properties should be accessible
        XCTAssertEqual(error.errorDescription, "Something went wrong")
        XCTAssertEqual(error.failureReason, "Network connection failed")
    }
    
    func testDNSErrorWithRecoverySuggestion() {
        // Given: A custom error with recovery suggestion
        struct RecoverableError: DNSError {
            let errorDescription: String?
            let recoverySuggestion: String?
            
            init(description: String, suggestion: String) {
                self.errorDescription = description
                self.recoverySuggestion = suggestion
            }
        }
        
        // When: Creating an instance
        let error = RecoverableError(description: "Authentication failed", suggestion: "Please check your credentials")
        
        // Then: Recovery suggestion should be accessible
        XCTAssertEqual(error.errorDescription, "Authentication failed")
        XCTAssertEqual(error.recoverySuggestion, "Please check your credentials")
    }
    
    func testDNSErrorAsNSError() {
        // Given: A custom DNSError
        struct TestError: DNSError {
            let errorDescription: String? = "Test error"
            let failureReason: String? = "Test failure reason"
        }
        
        // When: Converting to NSError
        let dnsError = TestError()
        let nsError = dnsError as NSError
        
        // Then: NSError conversion should work
        XCTAssertNotNil(nsError)
        XCTAssertEqual(nsError.localizedDescription, "Test error")
        XCTAssertEqual(nsError.localizedFailureReason, "Test failure reason")
    }
}

// MARK: - Test Helper Classes

struct MockDNSError: DNSError {
    let errorDescription: String?
    let failureReason: String?
    let recoverySuggestion: String?
    
    init(description: String? = nil, reason: String? = nil, suggestion: String? = nil) {
        self.errorDescription = description
        self.failureReason = reason
        self.recoverySuggestion = suggestion
    }
}

enum TestErrorType: DNSError {
    case networkError
    case validationError(String)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network connection failed"
        case .validationError(let field):
            return "Validation failed for field: \(field)"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .networkError:
            return "Unable to reach the server"
        case .validationError:
            return "Input validation failed"
        case .unknownError:
            return "Unexpected error condition"
        }
    }
}
