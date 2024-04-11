# swift-testable-mocking

A mocking tool for protocol-based dependencies inspired by [swift-dependencies](https://github.com/pointfreeco/swift-dependencies).

## Overview

swift-dependencies and other libraries provide powerful DI (dependency injection) and mocking systems.
We can benefit from them by applying them to our code base.

However, our code base has already been so large that we cannot replace soon.
In addition, when introducing external frameworks for product code, we need to select carefully.

So I developed a library that can be used for tests or previews without changing product code.
With this tool, we can test rigorously and easily create mocks for protocol-based DI.

## Example

### Protocol

```swift
protocol CounterProtocol {
    var count: Int { get set }
    var title: String { get }

    func doNothing()
    func doSomething() -> Int
    func doSomething(with parameter: Int) throws -> Int
}
```

### Unit test

```swift
final class CounterTests: XCTestCase {
    func testCounter() throws {
        let counter: any CounterProtocol = MockCounter(
            // Provide a value for a property
            count: { 999 },
            // Implement method
            doSomethingWithParameter: { _ in 100 }
        )

        // These assertions will succeed.
        XCTAssertEqual(counter.count, 999)
        XCTAssertEqual(try counter.doSomething(with: 1), 100)

        // This line will cause XCTAssertFailure due to access to a property that is not provided in the initializer.
        _ = counter.title

        // This line will cause XCTAssertFailure due to calling a method that is not implemented in the initializer.
        counter.doNothing()
    }
}
```

### Mock

```swift
@Mock
struct MockCounter: CounterProtocol {
    struct Conformance: CounterProtocol {
        var count: Int = 0
        var title: String = ""

        func doNothing() {}

        func doSomething() -> Int { 0 }

        @MockHandlerName("doSomethingWithParameter")
        func doSomething(with parameter: Int) throws -> Int { 0 }
    }
}
```

In this case, `MockCounter` has to contain an inner object named `Conformance` that implements the target protocol.

`@Mock` macro generates mock object with reference to the parameter of `@MockHandlerName` macro like:

```swift
struct MockCounter: CounterProtocol {
    var count: Int
    var title: String

    init(
        count: (() -> Int)? = nil,
        title: (() -> String)? = nil,
        doNothing: (() -> Void)? = nil,
        doSomething: (() -> Int)? = nil,
        doSomethingWithParameter: ((_ parameter: Int) throws -> Int)? = nil
    ) { /* ... */ }

    func doNothing() {}
    func doSomething() -> Int { /* ... */ }
    func doSomething(with parameter: Int) throws -> Int { /* ... */ }
}
```
