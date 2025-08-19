// swift-tools-version: 6.0
//
//  Package.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSError
//
//  Created by Darren Ehlers.
//  Copyright © 2023 - 2016 DoubleNode.com. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "DNSError",
    platforms: [
        .iOS(.v17),
        .tvOS(.v18),
        .macCatalyst(.v18),
        .macOS(.v15),
        .watchOS(.v11),
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
            dependencies: ["SwiftyBeaver"],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ForwardTrailingClosures"),
                .enableUpcomingFeature("ImportObjcForwardDeclarations"),
                .enableUpcomingFeature("DisableOutwardActorInference"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("StrictConcurrency"),
                .enableUpcomingFeature("GlobalConcurrency")
            ]),
        .testTarget(
            name: "DNSErrorTests",
            dependencies: ["DNSError"],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ForwardTrailingClosures"),
                .enableUpcomingFeature("ImportObjcForwardDeclarations"),
                .enableUpcomingFeature("DisableOutwardActorInference"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("StrictConcurrency"),
                .enableUpcomingFeature("GlobalConcurrency")
            ]),
    ],
    swiftLanguageModes: [.v6]
)
