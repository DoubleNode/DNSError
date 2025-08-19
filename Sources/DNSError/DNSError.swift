//
//  DNSError.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSError
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import Foundation

// Make DNSError Sendable for Swift 6 concurrency
public protocol DNSError: LocalizedError, Sendable {
}
