//
//  DNSError.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSError
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import Foundation

public protocol DNSError: LocalizedError {
}

//public class DNSError: LocalizedError {
//    public var errorString: String { _errorString() }
//    public var nsError: NSError! { _nsError() }
//
//    open func _errorString() -> String {
//        return ""
//    }
//    open func _nsError() -> NSError! {
//        return nil
//    }
//}
