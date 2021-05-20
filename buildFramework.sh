#!/bin/sh
xcodebuild archive -scheme DNSError-iOS -destination "generic/platform=iOS" \
    -archivePath ./Archives/iOS/DNSErrorFramework SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild archive -scheme DNSError-iOS -destination "generic/platform=iOS Simulator" \
    -archivePath ./Archives/Simulator/DNSErrorFramework SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild archive -scheme DNSError-macOS -destination "generic/platform=macOS" \
    -archivePath ./Archives/macOS/DNSErrorFramework SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

rm -rf ./Archives/DNSErrorFramework.xcframework

xcodebuild -create-xcframework \
    -framework ./Archives/iOS/DNSErrorFramework.xcarchive/Products/Library/Frameworks/DNSError_iOS.framework \
    -framework ./Archives/Simulator/DNSErrorFramework.xcarchive/Products/Library/Frameworks/DNSError_iOS.framework \
    -framework ./Archives/macOS/DNSErrorFramework.xcarchive/Products/Library/Frameworks/DNSError_macOS.framework \
    -output ./Archives/DNSErrorFramework.xcframework
