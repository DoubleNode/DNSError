# DNSError Package Test Plan

## Overview
Comprehensive test suite for the DNSError package with Swift 6 compatibility and Thread Sanitizer validation.

## Test Structure

### Core Test Files
1. **DNSErrorTests.swift** - Main test suite for basic functionality
2. **CodeLocationThreadSafetyTests.swift** - Dedicated thread safety and concurrency tests
3. **DNSLoggerTests.swift** - Logger integration and functionality tests
4. **DNSErrorIntegrationTests.swift** - End-to-end and integration scenarios

### Extension Support
- **CodeLocation+Testing.swift** - Production testing extension with comprehensive validation methods

## Test Categories

### 1. Basic Functionality Tests (`DNSErrorTests.swift`)
- ✅ CodeLocation initialization and properties
- ✅ DNSCodeLocation inheritance and domain prefacing
- ✅ Raw data parsing and edge cases
- ✅ Static utility methods (path shortening, object shortening)
- ✅ String concatenation operators
- ✅ User info dictionary generation
- ✅ Performance benchmarks

### 2. Thread Safety Tests (`CodeLocationThreadSafetyTests.swift`)
- ✅ Swift 6 TaskGroup-based concurrent operations
- ✅ High-concurrency stress testing
- ✅ Memory pressure validation
- ✅ Race condition detection
- ✅ Thread Sanitizer validation scenarios
- ✅ Atomic operation verification

### 3. Integration Tests (`DNSErrorIntegrationTests.swift`)
- ✅ End-to-end error reporting workflows
- ✅ Real-world usage scenarios (networking, database errors)
- ✅ High-volume error processing
- ✅ Memory usage patterns under load
- ✅ Extension method integration
- ✅ Malformed data handling

### 4. Logger Tests (`DNSLoggerTests.swift`)
- ✅ Basic logging functionality
- ✅ Structured logging integration (iOS 18+)
- ✅ Concurrent logging operations
- ✅ Message formatting with CodeLocation

## Swift 6 Compliance Features

### ✅ Sendable Conformance
- All test objects implement `Sendable` protocol
- No `@unchecked Sendable` usage
- Proper thread-safe patterns

### ✅ Strict Concurrency
- TaskGroup usage for async operations
- OSAllocatedUnfairLock for atomic operations
- No data race warnings

### ✅ Modern Async/Await
- Comprehensive async test methods
- Proper continuation handling
- Timeout management

## Thread Sanitizer Integration

### Validation Methods
```swift
// Built-in extension methods for comprehensive testing
CodeLocation.performThreadSafetyTest(iterations: 100)
CodeLocation.performStressTest(iterations: 1000)
CodeLocation.performMemoryPressureTest(iterations: 5000)
CodeLocation.performComprehensiveTest()
```

### Async Testing (iOS 13+)
```swift
let result = await CodeLocation.performAsyncThreadSafetyTest(iterations: 100)
```

## Running Tests

### Command Line (with Thread Sanitizer)
```bash
# Build with Thread Sanitizer
xcodebuild -package-path . \
           -scheme DNSError \
           -configuration Debug \
           -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
           OTHER_CFLAGS='-fsanitize=thread -g' \
           OTHER_LDFLAGS='-fsanitize=thread' \
           ENABLE_THREAD_SANITIZER=YES \
           test

# Run specific test class
xcodebuild test -package-path . \
               -scheme DNSError \
               -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
               -only-testing:DNSErrorTests/CodeLocationThreadSafetyTests
```

### Xcode Integration
1. Enable Thread Sanitizer: Product → Scheme → Edit Scheme → Diagnostics
2. Run tests: Cmd+U
3. Check console for Thread Sanitizer output

## Test Coverage Goals

### ✅ Functional Coverage
- All public APIs tested
- Edge cases and error conditions
- Input validation and sanitization

### ✅ Concurrency Coverage
- All shared state access patterns
- Lock contention scenarios
- High-load stress testing

### ✅ Performance Coverage
- Baseline performance measurements
- Memory usage validation
- Scalability under load

### ✅ Integration Coverage
- Real-world usage patterns
- Cross-component interactions
- Extension method validation

## Expected Results

### Thread Sanitizer Output (Success)
```
==================
ThreadSanitizer: no issues found.
==================
```

### Performance Benchmarks
- CodeLocation creation: < 0.001s per operation
- Path shortening: < 0.0001s per operation
- Concurrent operations: > 1000 ops/sec

### Memory Usage
- No memory leaks under sustained load
- Proper cleanup in autoreleasepool blocks
- Stable memory pattern over time

## iOS Version Compatibility

### iOS 17+ (Required)
- All basic functionality
- Core thread safety features
- Standard logging integration

### iOS 18+ (Enhanced)
- Structured logging with Logger
- Enhanced debugging features
- Advanced performance metrics

### Future iOS 26 Readiness
- Actor-based patterns prepared
- Modern concurrency adoption
- Backwards compatibility maintained

## Continuous Integration

### Automated Testing
- Run on all supported platforms
- Thread Sanitizer validation
- Performance regression detection
- Memory leak monitoring

### Quality Gates
- Zero Thread Sanitizer warnings
- All tests passing
- Performance within thresholds
- Memory usage stable

## Troubleshooting

### Common Issues
1. **Thread Sanitizer Warnings**: Check OSAllocatedUnfairLock usage
2. **Performance Degradation**: Review autoreleasepool placement
3. **Memory Issues**: Verify proper cleanup in concurrent operations
4. **Test Timeouts**: Adjust expectations for CI environments

### Debug Commands
```bash
# Verbose test output
xcodebuild test -package-path . -scheme DNSError -verbose

# Memory usage monitoring
xcodebuild test -package-path . -scheme DNSError \
               -resultBundlePath ./TestResults.xcresult

# Thread Sanitizer detailed output
export TSAN_OPTIONS="verbosity=2:halt_on_error=1"
xcodebuild test -package-path . -scheme DNSError
```

## Future Enhancements

### Planned Additions
- Swift Testing framework integration (when mature)
- Actor-based testing patterns for iOS 26
- Enhanced performance profiling
- Automated stress testing in CI

### Maintenance
- Regular Swift version updates
- Platform-specific optimizations
- Test coverage expansion
- Performance baseline updates
