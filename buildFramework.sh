#!/bin/sh
xcodebuild archive -scheme DNSError-iOS -destination "generic/platform=iOS" -archivePath ./Archives/iOS/DNSError SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild archive -scheme DNSError-iOS -destination "generic/platform=iOS Simulator" -archivePath ./Archives/Simulator/DNSError SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild archive -scheme DNSError-macOS -destination "generic/platform=macOS" -archivePath ./Archives/macOS/DNSError SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

rm ./Archives/DNSError.xcframework
xcodebuild -create-xcframework \
-framework ./Archives/iOS/DNSError.xcarchive/Products/Library/Frameworks/DNSError_iOS.framework \
-framework ./Archives/Simulator/DNSError.xcarchive/Products/Library/Frameworks/DNSError_iOS.framework \
-framework ./Archives/macOS/DNSError.xcarchive/Products/Library/Frameworks/DNSError_macOS.framework \
-output ./Archives/DNSError.xcframework
