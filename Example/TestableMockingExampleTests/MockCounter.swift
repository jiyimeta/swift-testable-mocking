import TestableMocking
@testable import TestableMockingExample
import XCTest

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
