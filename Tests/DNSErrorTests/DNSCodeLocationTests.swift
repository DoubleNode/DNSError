//
//  DNSCodeLocationTests.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSErrorTests
//
//  Created by Darren Ehlers.
//  Copyright © 2025 - 2016 DoubleNode.com. All rights reserved.
//

import XCTest

@testable import DNSError

class DNSCodeLocationTests: XCTestCase {
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        // Clear any existing filename path roots for clean testing
        CodeLocation.removeAllFilenamePathRoots()
    }
    
    override func tearDown() {
        // Clean up after tests
        CodeLocation.removeAllFilenamePathRoots()
        super.tearDown()
    }
    
    // MARK: - CodeLocation Tests
    
    func testCodeLocationInitializationWithDefaults() {
        // Given: A test object
        let testObject = "TestString"
        
        // When: Creating a CodeLocation with default parameters
        let codeLocation = CodeLocation(testObject)
        
        // Then: Properties should be set correctly
        XCTAssertEqual(codeLocation.domain, "String")
        XCTAssertTrue(codeLocation.file.contains("DNSCodeLocationTests.swift"))
        XCTAssertGreaterThan(codeLocation.line, 0) // Should be a positive line number
        XCTAssertTrue(codeLocation.method.contains("testCodeLocationInitializationWithDefaults"))
        XCTAssertTrue(codeLocation.asString.contains("String:"))
        XCTAssertTrue(codeLocation.asString.contains("DNSCodeLocationTests.swift"))
    }
    
    func testCodeLocationInitializationWithRawData() {
        // Given: A test object and raw data
        let testObject = "TestString"
        let rawData = "/path/to/file.swift,42,testMethod()"
        
        // When: Creating a CodeLocation with raw data
        let codeLocation = CodeLocation(testObject, rawData)
        
        // Then: Properties should be parsed correctly
        XCTAssertEqual(codeLocation.domain, "String")
        XCTAssertEqual(codeLocation.file, "/path/to/file.swift")
        XCTAssertEqual(codeLocation.line, 42)
        XCTAssertEqual(codeLocation.method, "testMethod()")
    }
    
    func testCodeLocationInitializationWithIncompleteRawData() {
        // Given: A test object and incomplete raw data
        let testObject = "TestString"
        let rawData = "/path/to/file.swift"
        
        // When: Creating a CodeLocation with incomplete raw data
        let codeLocation = CodeLocation(testObject, rawData)
        
        // Then: Properties should have defaults for missing data
        XCTAssertEqual(codeLocation.domain, "String")
        XCTAssertEqual(codeLocation.file, "/path/to/file.swift")
        XCTAssertEqual(codeLocation.line, 0)
        XCTAssertEqual(codeLocation.method, "")
    }
    
    func testCodeLocationInitializationWithEmptyRawData() {
        // Given: A test object and empty raw data
        let testObject = "TestString"
        let rawData = ""
        
        // When: Creating a CodeLocation with empty raw data
        let codeLocation = CodeLocation(testObject, rawData)
        
        // Then: Properties should have defaults
        XCTAssertEqual(codeLocation.domain, "String")
        XCTAssertEqual(codeLocation.file, "")
        XCTAssertEqual(codeLocation.line, 0)
        XCTAssertEqual(codeLocation.method, "")
    }
    
    func testCodeLocationAsString() {
        // Given: A CodeLocation with known values
        let testObject = "TestString"
        let rawData = "/path/to/file.swift,42,testMethod()"
        let codeLocation = CodeLocation(testObject, rawData)
        
        // When: Getting the string representation
        let stringRepresentation = codeLocation.asString
        
        // Then: It should contain all components
        XCTAssertEqual(stringRepresentation, "String:/path/to/file.swift:42:testMethod()")
    }
    
    func testCodeLocationFailureReason() {
        // Given: A CodeLocation
        let testObject = "TestString"
        let rawData = "/path/to/file.swift,42,testMethod()"
        let codeLocation = CodeLocation(testObject, rawData)
        
        // When: Getting the failure reason
        let failureReason = codeLocation.failureReason
        
        // Then: It should match the string representation
        XCTAssertEqual(failureReason, codeLocation.asString)
    }
    
    func testCodeLocationUserInfo() {
        // Given: A CodeLocation
        let testObject = "TestString"
        let codeLocation = CodeLocation(testObject)
        
        // When: Getting user info
        let userInfo = codeLocation.userInfo
        
        // Then: It should contain all expected keys
        XCTAssertNotNil(userInfo["DNSTimeStamp"] as? Date)
        XCTAssertEqual(userInfo["DNSDomain"] as? String, "String")
        XCTAssertNotNil(userInfo["DNSFile"] as? String)
        XCTAssertNotNil(userInfo["DNSLine"] as? Int)
        XCTAssertNotNil(userInfo["DNSMethod"] as? String)
    }
    
    func testCodeLocationTimeStamp() {
        // Given: Time before creating CodeLocation
        let timeBefore = Date()
        
        // When: Creating a CodeLocation
        let codeLocation = CodeLocation("TestString")
        
        // Given: Time after creating CodeLocation
        let timeAfter = Date()
        
        // Then: TimeStamp should be within the expected range
        XCTAssertGreaterThanOrEqual(codeLocation.timeStamp, timeBefore)
        XCTAssertLessThanOrEqual(codeLocation.timeStamp, timeAfter)
    }
    
    // MARK: - CodeLocation Class Methods Tests
    
    func testAddFilenamePathRoot() {
        // Given: An initial state with no path roots
        XCTAssertTrue(CodeLocation.filenamePathRoots.isEmpty)
        
        // When: Adding a filename path root
        CodeLocation.addFilenamePathRoot("/Users/developer/project")
        
        // Then: It should be added to the array
        XCTAssertEqual(CodeLocation.filenamePathRoots.count, 1)
        XCTAssertEqual(CodeLocation.filenamePathRoots.first, "/Users/developer/project")
    }
    
    func testAddMultipleFilenamePathRoots() {
        // Given: An initial state with no path roots
        XCTAssertTrue(CodeLocation.filenamePathRoots.isEmpty)
        
        // When: Adding multiple filename path roots
        CodeLocation.addFilenamePathRoot("/Users/developer/project")
        CodeLocation.addFilenamePathRoot("/opt/homebrew")
        
        // Then: Both should be added
        XCTAssertEqual(CodeLocation.filenamePathRoots.count, 2)
        XCTAssertEqual(CodeLocation.filenamePathRoots[0], "/Users/developer/project")
        XCTAssertEqual(CodeLocation.filenamePathRoots[1], "/opt/homebrew")
    }
    
    func testShortenErrorObject() {
        // Given: Various object types
        let stringObject = "Test"
        let intObject = 42
        let optionalString: String? = "OptionalTest"
        let nilOptional: String? = nil
        
        // When: Getting shortened error object strings
        let stringResult = CodeLocation.shortenErrorObject(stringObject)
        let intResult = CodeLocation.shortenErrorObject(intObject)
        let optionalResult = CodeLocation.shortenErrorObject(optionalString as Any)
        let nilResult = CodeLocation.shortenErrorObject(nilOptional as Any)
        
        // Then: Results should be properly formatted
        XCTAssertEqual(stringResult, "String")
        XCTAssertEqual(intResult, "Int")
        XCTAssertEqual(optionalResult, "String")
        XCTAssertEqual(nilResult, "String")
    }
    
    func testShortenErrorObjectWithComplexOptional() {
        // Given: A complex optional type
        let complexOptional: Optional<Optional<String>> = Optional(Optional("nested"))
        
        // When: Getting shortened error object string
        let result = CodeLocation.shortenErrorObject(complexOptional as Any)
        
        // Then: Multiple optionals should be removed
        XCTAssertEqual(result, "String")
    }
    
    func testShortenErrorPath() {
        // Given: A long file path
        let longPath = "/Users/developer/MyProject/Sources/MyModule/MyFile.swift"
        
        // When: No path roots are set
        let resultWithoutRoots = CodeLocation.shortenErrorPath(longPath)
        
        // Then: Path should remain unchanged
        XCTAssertEqual(resultWithoutRoots, longPath)
    }
    
    func testShortenErrorPathWithRoot() {
        // Given: A long file path and a path root
        let longPath = "/Users/developer/MyProject/Sources/MyModule/MyFile.swift"
        CodeLocation.addFilenamePathRoot("/Users/developer/MyProject/")
        
        // When: Shortening the path
        let result = CodeLocation.shortenErrorPath(longPath)
        
        // Then: Path should be shortened
        XCTAssertEqual(result, "~Sources/MyModule/MyFile.swift")
    }
    
    func testShortenErrorPathWithMultipleRoots() {
        // Given: A file path and multiple path roots
        let longPath = "/opt/homebrew/lib/MyFramework/MyFile.swift"
        CodeLocation.addFilenamePathRoot("/Users/developer/")
        CodeLocation.addFilenamePathRoot("/opt/homebrew/")
        
        // When: Shortening the path
        let result = CodeLocation.shortenErrorPath(longPath)
        
        // Then: The matching path root should be replaced
        XCTAssertEqual(result, "~lib/MyFramework/MyFile.swift")
    }
    
    func testStringPlusCodeLocationOperator() {
        // Given: A string and a CodeLocation
        let prefix = "Error occurred at: "
        let codeLocation = CodeLocation("TestObject", "/path/file.swift,10,testMethod()")
        
        // When: Using the + operator
        let result = prefix + codeLocation
        
        // Then: Should concatenate string and failure reason
        XCTAssertEqual(result, "Error occurred at: String:/path/file.swift:10:testMethod()")
    }
    
    // MARK: - DNSCodeLocation Tests
    
    func testDNSCodeLocationDomainPreface() {
        // Given: DNSCodeLocation class
        // When: Getting domain preface
        let domainPreface = DNSCodeLocation.domainPreface
        
        // Then: It should have the expected value
        XCTAssertEqual(domainPreface, "com.doublenode.")
    }
    
    func testDNSCodeLocationInitialization() {
        // Given: A test object
        let testObject = "TestString"
        
        // When: Creating a DNSCodeLocation
        let dnsCodeLocation = DNSCodeLocation(testObject)
        
        // Then: Domain should include the DNS prefix
        XCTAssertTrue(dnsCodeLocation.domain.hasPrefix("com.doublenode."))
        XCTAssertTrue(dnsCodeLocation.domain.contains("String"))
    }
    
    func testDNSCodeLocationWithRawData() {
        // Given: A test object and raw data
        let testObject = "TestString"
        let rawData = "/path/to/file.swift,42,testMethod()"
        
        // When: Creating a DNSCodeLocation with raw data
        let dnsCodeLocation = DNSCodeLocation(testObject, rawData)
        
        // Then: Properties should be set correctly with DNS domain prefix
        XCTAssertEqual(dnsCodeLocation.domain, "com.doublenode.String")
        XCTAssertEqual(dnsCodeLocation.file, "/path/to/file.swift")
        XCTAssertEqual(dnsCodeLocation.line, 42)
        XCTAssertEqual(dnsCodeLocation.method, "testMethod()")
    }
    
    // MARK: - Edge Cases and Error Handling
    
    func testCodeLocationWithInvalidLineNumber() {
        // Given: Raw data with invalid line number
        let testObject = "TestString"
        let rawData = "/path/to/file.swift,invalid_line,testMethod()"
        
        // When: Creating a CodeLocation
        let codeLocation = CodeLocation(testObject, rawData)
        
        // Then: Line should default to 0
        XCTAssertEqual(codeLocation.line, 0)
    }
    
    func testCodeLocationWithNegativeLineNumber() {
        // Given: Raw data with negative line number
        let testObject = "TestString"
        let rawData = "/path/to/file.swift,-5,testMethod()"
        
        // When: Creating a CodeLocation
        let codeLocation = CodeLocation(testObject, rawData)
        
        // Then: Line should be set to the negative value
        XCTAssertEqual(codeLocation.line, -5)
    }
    
    func testCodeLocationWithExtremelyLongPath() {
        // Given: An extremely long file path
        let longPath = String(repeating: "/verylongdirectoryname", count: 100) + "/file.swift"
        let rawData = "\(longPath),42,testMethod()"
        
        // When: Creating a CodeLocation
        let codeLocation = CodeLocation("TestString", rawData)
        
        // Then: It should handle the long path gracefully
        XCTAssertEqual(codeLocation.file, longPath)
        XCTAssertEqual(codeLocation.line, 42)
    }
    
    func testCodeLocationConcurrentAccess() {
        // Given: Concurrent access setup
        let expectation = XCTestExpectation(description: "Concurrent access")
        expectation.expectedFulfillmentCount = 10
        
        // When: Creating multiple CodeLocations concurrently
        for i in 0..<10 {
            DispatchQueue.global().async {
                let codeLocation = CodeLocation("TestObject\(i)")
                XCTAssertNotNil(codeLocation.domain)
                XCTAssertNotNil(codeLocation.file)
                XCTAssertNotNil(codeLocation.method)
                expectation.fulfill()
            }
        }
        
        // Then: All should complete successfully
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFilenamePathRootsConcurrentAccess() {
        // Given: Concurrent access setup
        let expectation = XCTestExpectation(description: "Concurrent path roots access")
        expectation.expectedFulfillmentCount = 10
        
        // When: Adding path roots concurrently
        for i in 0..<10 {
            DispatchQueue.global().async {
                CodeLocation.addFilenamePathRoot("/path\(i)/")
                expectation.fulfill()
            }
        }
        
        // Then: All should complete successfully
        wait(for: [expectation], timeout: 5.0)
        
        // And: Should have all 10 path roots
        XCTAssertEqual(CodeLocation.filenamePathRoots.count, 10)
    }
}
