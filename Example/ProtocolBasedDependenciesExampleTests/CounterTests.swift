@testable import ProtocolBasedDependenciesExample
import XCTest

final class ProtocolBasedDependenciesExampleTests: XCTestCase {
    func testCounter() {
        let counter: any CounterProtocol = MockCounter(
            count: { 999 },
            doSomething: { 100 }
        )
        XCTAssertEqual(counter.count, 999)
        XCTAssertEqual(counter.doSomething(), 100)
    }

    func testCounter2() {
        let counter: any CounterProtocol = MockCounter()

        // Fails when access to a property that is not provided in the initializer
        _ = counter.count
    }

    func testCounter3() {
        let counter: any CounterProtocol = MockCounter()

        // Fails when access to a property that is not provided in the initializer
        counter.doNothing()
    }
}
