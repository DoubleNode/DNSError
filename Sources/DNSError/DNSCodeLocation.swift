//
//  DNSCodeLocation.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSError
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import Foundation

open class DNSCodeLocation: CodeLocation {
    override open class var domainPreface: String { "com.doublenode." }
}
open class CodeLocation {
    static var filenamePathRoots: [String] = []

    open class var domainPreface: String { "" }

    public var timeStamp: Date = Date()
    public var domain: String
    public var file: String
    public var line: Int
    public var method: String
    public var failureReason: String { "\(domain):\(file):\(line):\(method)" }
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
        Self.filenamePathRoots.append(pathRoot)
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
        Self.filenamePathRoots.forEach {
            retval = retval.replacingOccurrences(of: $0, with: "~")
        }
        return retval
    }
}
