// swift-tools-version:5.3
//
//  Package.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSCoreThreading
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "DNSError",
    platforms: [
        .iOS(.v13),
//        .tvOS(.v13),
//        .macOS(.v10_15),
//        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "DNSError",
            type: .dynamic,
            targets: ["DNSErrorTarget", "DNSError"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", from: "1.9.5"),
    ],
    targets: [
        .target(
            name: "DNSErrorTarget",
            dependencies: [
                "SwiftyBeaver",
                .target(name: "DNSError", condition: .when(platforms: [.iOS]))
            ],
            path: "Sources/DNSErrorTarget"
        ),
        .binaryTarget(
            name: "DNSError",
            path: "Archives/DNSError.xcframework"
        ),
        .testTarget(
            name: "DNSErrorTests",
            dependencies: ["DNSErrorTarget"]
        ),
    ]
)
