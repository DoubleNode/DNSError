// swift-tools-version:5.7
//
//  Package.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSCoreThreading
//
//  Created by Darren Ehlers.
//  Copyright © 2023 - 2016 DoubleNode.com. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "DNSError",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16),
        .macOS(.v13),
        .watchOS(.v9),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "DNSError",
            type: .static,
            targets: ["DNSError"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", from: "2.1.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "DNSError",
            dependencies: ["SwiftyBeaver"]),
        .testTarget(
            name: "DNSErrorTests",
            dependencies: ["DNSError"]),
    ]
)
