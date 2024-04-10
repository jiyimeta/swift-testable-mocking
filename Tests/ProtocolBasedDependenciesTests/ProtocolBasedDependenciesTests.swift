import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(ProtocolBasedDependenciesMacros)
    import ProtocolBasedDependenciesMacros

    let testMacros: [String: Macro.Type] = [
        "Mock": MockMacro.self,
        "MockHandlerName": MockHandlerNameMacro.self,
    ]
#endif

final class ProtocolBasedDependenciesTests: XCTestCase {
    func testMacro() throws {
        #if canImport(ProtocolBasedDependenciesMacros)
            assertMacroExpansion(
                """
                @Mock
                struct MockCounter: CounterProtocol {
                    struct Conformance: CounterProtocol {
                        var count: Int = 1

                        func doNothing() {}

                        @MockHandlerName("doSomethingWithImplicitlyReturningValue")
                        @MainActor
                        func doSomething(withImplicitlyReturning value: Int) -> Int {
                            value
                        }

                        @MockHandlerName("doSomethingWithExplicitlyReturningValue")
                        func doSomething(withExplicitlyReturning value: Int) -> Int {
                            print("Hello, world!")
                            return value
                        }

                        @MockHandlerName("doSomethingWithThrowingError")
                        func doSomething(_ error: (some Error)?) throws -> Int {
                            print("Hello, world!")
                            if let error {
                                throw error
                            } else {
                                return 0
                            }
                        }

                        @MockHandlerName("doSomethingWithMultipleParams")
                        func doSomething(_ a: Int, _ b: Int) -> Int {
                            a + b
                        }
                    }
                }
                """,
                expandedSource: """
                struct MockCounter: CounterProtocol {
                    @available(*, unavailable)
                    struct Conformance: CounterProtocol {
                        var count: Int = 1

                        func doNothing() {}
                        @MainActor
                        func doSomething(withImplicitlyReturning value: Int) -> Int {
                            value
                        }
                        func doSomething(withExplicitlyReturning value: Int) -> Int {
                            print("Hello, world!")
                            return value
                        }
                        func doSomething(_ error: (some Error)?) throws -> Int {
                            print("Hello, world!")
                            if let error {
                                throw error
                            } else {
                                return 0
                            }
                        }
                        func doSomething(_ a: Int, _ b: Int) -> Int {
                            a + b
                        }
                    }

                    private let failureHandler: (_ message: String) -> Void

                    @PresenceAssertedWhenAccessedProperty var count: Int

                    private let _doNothing: (() -> Void)?

                    private let _doSomethingWithImplicitlyReturningValue: ((_ value: Int) -> Int)?

                    private let _doSomethingWithExplicitlyReturningValue: ((_ value: Int) -> Int)?

                    private let _doSomethingWithThrowingError: ((_ error: (any Error)?) throws -> Int)?

                    private let _doSomethingWithMultipleParams: ((_ a: Int, _ b: Int) -> Int)?

                    init(count: (() -> Int)? = nil, doNothing: (() -> Void)? = nil, doSomethingWithImplicitlyReturningValue: ((_ value: Int) -> Int)? = nil, doSomethingWithExplicitlyReturningValue: ((_ value: Int) -> Int)? = nil, doSomethingWithThrowingError: ((_ error: (any Error)?) throws -> Int)? = nil, doSomethingWithMultipleParams: ((_ a: Int, _ b: Int) -> Int)? = nil, file: StaticString = #file, line: UInt = #line) {
                        let failureHandler: (String) -> Void = {
                            #if canImport (XCTest)
                            XCTFail($0, file: file, line: line)
                            #else
                            assertionFailure($0, file: file, line: line)
                            #endif
                        }
                        _count = PresenceAssertedWhenAccessedProperty(
                            name: "count",
                            value: count,
                            default: 1,
                            failureHandler: failureHandler
                        )
                        _doNothing = doNothing
                        _doSomethingWithImplicitlyReturningValue = doSomethingWithImplicitlyReturningValue
                        _doSomethingWithExplicitlyReturningValue = doSomethingWithExplicitlyReturningValue
                        _doSomethingWithThrowingError = doSomethingWithThrowingError
                        _doSomethingWithMultipleParams = doSomethingWithMultipleParams
                        self.failureHandler = failureHandler
                    }

                    func doNothing() {
                        guard let _doNothing else {
                            failureHandler("\\(#function) has not been implemented.")
                            return
                        }
                        return _doNothing()
                    }
                            @MainActor
                            func doSomething(withImplicitlyReturning value: Int) -> Int {
                        guard let _doSomethingWithImplicitlyReturningValue else {
                            failureHandler("\\(#function) has not been implemented.")
                            return
                                        value
                        }
                        return _doSomethingWithImplicitlyReturningValue(value)
                            }
                            func doSomething(withExplicitlyReturning value: Int) -> Int {
                        guard let _doSomethingWithExplicitlyReturningValue else {
                            failureHandler("\\(#function) has not been implemented.")
                                        print("Hello, world!")
                                        return value
                        }
                        return _doSomethingWithExplicitlyReturningValue(value)
                            }
                            func doSomething(_ error: (some Error)?) throws -> Int {
                        guard let _doSomethingWithThrowingError else {
                            failureHandler("\\(#function) has not been implemented.")
                                        print("Hello, world!")
                                        if let error {
                                            throw error
                                        } else {
                                            return 0
                                        }
                        }
                        return try _doSomethingWithThrowingError(error)
                            }
                            func doSomething(_ a: Int, _ b: Int) -> Int {
                        guard let _doSomethingWithMultipleParams else {
                            failureHandler("\\(#function) has not been implemented.")
                            return
                                        a + b
                        }
                        return _doSomethingWithMultipleParams(a, b)
                            }
                }
                """,
                macros: testMacros
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
