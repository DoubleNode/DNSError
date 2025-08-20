//
//  DNSCodeLocation.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSError
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import Foundation
import os.lock

open class DNSCodeLocation: CodeLocation, @unchecked Sendable {
    override open class var domainPreface: String { "com.doublenode." }
}

open class CodeLocation: @unchecked Sendable {
    // Make this thread-safe with proper synchronization
    private static let _filenamePathRoots = OSAllocatedUnfairLock(initialState: [String]())
    
    static var filenamePathRoots: [String] {
        get {
            _filenamePathRoots.withLock { $0 }
        }
        set {
            _filenamePathRoots.withLock { $0 = newValue }
        }
    }

    open class var domainPreface: String { "" }

    public let timeStamp: Date
    public let domain: String
    public let file: String
    public let line: Int
    public let method: String
    
    public var asString: String { "\(domain):\(file):\(line):\(method)" }
    public var failureReason: String { self.asString }
    public var userInfo: [String: Any] {
        [
            "DNSTimeStamp": self.timeStamp,
            "DNSDomain": self.domain,
            "DNSFile": self.file,
            "DNSLine": self.line,
            "DNSMethod": self.method,
        ]
    }
    
    public required init(_ object: Any,
                         _ file: StaticString = #file,
                         _ line: UInt = #line,
                         _ function: StaticString = #function) {
        self.timeStamp = Date()
        self.domain = Self.domainPreface + Self.shortenErrorObject(object)
        self.file = Self.shortenErrorPath("\(file)")
        self.line = Int(line)
        self.method = "\(function)"
    }
    
    public required init(_ object: Any,
                         _ rawData: String) {
        var data = rawData.components(separatedBy: ",")
        if data.count == 1 && data[0].isEmpty {
            data = []
        }
        self.timeStamp = Date()
        self.domain = Self.domainPreface + Self.shortenErrorObject(object)
        self.file = !data.isEmpty ? Self.shortenErrorPath(data[0]) : "<UnknownFile>"
        self.line = (data.count > 1) ? (Int(data[1]) ?? 0) : 0
        self.method = (data.count > 2) ? data[2] : ""
    }

    public class func addFilenamePathRoot(_ pathRoot: String) {
        _filenamePathRoots.withLock { roots in
            roots.append(pathRoot)
        }
    }
    
    public class func shortenErrorObject(_ object: Any) -> String {
        var retval = "\(type(of: object))"
        retval = retval
            .replacingOccurrences(of: "Optional<", with: "")
            .replacingOccurrences(of: ">", with: "")
        return retval
    }
    
    public class func shortenErrorPath(_ filename: String) -> String {
        var retval = filename
        let roots = _filenamePathRoots.withLock { $0 }
        
        // Find the longest matching root
        let matchingRoot = roots
            .filter { filename.hasPrefix($0) }
            .max(by: { $0.count < $1.count })
        
        if let root = matchingRoot {
            retval = retval.replacingOccurrences(of: root, with: "~")
        }
        
        return retval
    }
    public static func + (left: String, right: CodeLocation) -> String {
        return "\(left)\(right.failureReason)"
    }
}
