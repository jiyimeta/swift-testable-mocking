@testable import TestableMockingExample
import XCTest

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
