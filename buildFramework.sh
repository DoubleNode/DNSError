#!/bin/sh
xcodebuild archive -scheme DNSErrorFramework-iOS -destination "generic/platform=iOS" \
    -archivePath ./Archives/iOS/DNSErrorFramework SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild archive -scheme DNSErrorFramework-iOS -destination "generic/platform=iOS Simulator" \
    -archivePath ./Archives/Simulator/DNSErrorFramework SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild archive -scheme DNSErrorFramework-macOS -destination "generic/platform=macOS" \
    -archivePath ./Archives/macOS/DNSErrorFramework SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

rm -rf ./Archives/DNSErrorFramework.xcframework

xcodebuild -create-xcframework \
    -framework ./Archives/iOS/DNSErrorFramework.xcarchive/Products/Library/Frameworks/DNSErrorFramework_iOS.framework \
    -framework ./Archives/Simulator/DNSErrorFramework.xcarchive/Products/Library/Frameworks/DNSErrorFramework_iOS.framework \
    -framework ./Archives/macOS/DNSErrorFramework.xcarchive/Products/Library/Frameworks/DNSErrorFramework_macOS.framework \
    -output ./Archives/DNSErrorFramework.xcframework
