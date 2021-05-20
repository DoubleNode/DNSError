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
            targets: ["DNSErrorWrapper"]
        ),
        .library(
            name: "DNSErrorWrapper",
            targets: ["DNSErrorWrapper"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", from: "1.9.5"),
    ],
    targets: [
        .binaryTarget(
            name: "DNSError",
            path: "Archives/DNSError.xcframework"
        ),
        .target(
            name: "DNSErrorWrapper",
            dependencies: [
                "DNSError",
                "SwiftyBeaver",
//                .product(name: "SwiftyBeaver", package: "SwiftyBeaver", condition: .when(platforms: .some([.iOS]))),
//                .target(name: "DNSError", condition: .when(platforms: .some([.iOS]))),
            ],
            path: "Sources/DNSErrorWrapper"
        ),
        .testTarget(
            name: "DNSErrorTests",
            dependencies: ["DNSError"]
        ),
    ]
)
