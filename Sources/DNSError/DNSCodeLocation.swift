//
//  DNSCodeLocation.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSError
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import Foundation

public class DNSCodeLocation: CodeLocation {
    override public class var domainPreface: String { "com.doublenode." }
}
public class CodeLocation {
    public static var filenamePathRoots: [String] = []
    public class var domainPreface: String { "" }
    public var domain: String
    public var file: String
    public var line: Int
    public var method: String
    public var failureReason: String { "\(domain):\(file):\(line):\(method)" }
    
    public required init(_ object: Any,
                         _ rawData: String) {
        let data = rawData.components(separatedBy: ",")
        domain = Self.domainPreface + "\(type(of: object))"
        file = !data.isEmpty ? Self.shortenErrorPath(data[0]) : "<UnknownFile>"
        line = (data.count > 1) ? (Int(data[1]) ?? 0) : 0
        method = (data.count > 2) ? data[2] : ""
    }
    
    public class func shortenErrorPath(_ filename: String) -> String {
        var retval = filename
        Self.filenamePathRoots.forEach {
            retval = retval.replacingOccurrences(of: $0, with: "~")
        }
        return retval
    }

}
