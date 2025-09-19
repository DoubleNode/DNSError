//
//  DNSCodeLocation.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSError
//
//  Created by Darren Ehlers.
//  Copyright © 2025 - 2016 DoubleNode.com. All rights reserved.
//

import Foundation

open class DNSCodeLocation: CodeLocation {
    override open class var domainPreface: String { "com.doublenode." }
}
open class CodeLocation {
    private static var _filenamePathRoots: [String] = []
    private static let filenamePathRootsQueue = DispatchQueue(label: "com.doublenode.codelocation.pathrootsqueue", attributes: .concurrent)

    open class var domainPreface: String { "" }
    
    static var filenamePathRoots: [String] {
        return filenamePathRootsQueue.sync {
            return _filenamePathRoots
        }
    }

    public var timeStamp: Date = Date()
    public var domain: String
    public var file: String
    public var line: Int
    public var method: String
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
        domain = Self.domainPreface + Self.shortenErrorObject(object)
        self.file = Self.shortenErrorPath("\(file)")
        self.line = Int(line)
        self.method = "\(function)"
    }
    public required init(_ object: Any,
                         _ rawData: String) {
        let data = rawData.components(separatedBy: ",")
        domain = Self.domainPreface + Self.shortenErrorObject(object)
        file = !data.isEmpty ? Self.shortenErrorPath(data[0]) : "<UnknownFile>"
        line = (data.count > 1) ? (Int(data[1]) ?? 0) : 0
        method = (data.count > 2) ? data[2] : ""
    }


    public class func addFilenamePathRoot(_ pathRoot: String) {
        filenamePathRootsQueue.sync(flags: .barrier) {
            _filenamePathRoots.append(pathRoot)
        }
    }
    
    internal class func removeAllFilenamePathRoots() {
        filenamePathRootsQueue.sync(flags: .barrier) {
            _filenamePathRoots.removeAll()
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
        let pathRoots = filenamePathRootsQueue.sync {
            return _filenamePathRoots
        }
        pathRoots.forEach {
            retval = retval.replacingOccurrences(of: $0, with: "~")
        }
        return retval
    }
    
    public static func + (left: String, right: CodeLocation) -> String {
        return "\(left)\(right.failureReason)"
    }
}
