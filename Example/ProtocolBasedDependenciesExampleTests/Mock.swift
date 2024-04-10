@testable import ProtocolBasedDependenciesExample
import ProtocolBasedDependencies
import XCTest

@Mock
struct MockCounter: CounterProtocol {
    struct Conformance: CounterProtocol {
        var count: Int = 0
        var title: String = ""

        func doNothing() {}

        func doSomething() -> Int { 1 }

        @MockHandlerName("doSomethingWithThrowingError")
        func doSomething(throwing error: some Error) async throws -> Int { throw error }
    }
}
