import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(ProtocolBasedDependenciesMacros)
    import ProtocolBasedDependenciesMacros

    let testMacros: [String: Macro.Type] = [
        "stringify": StringifyMacro.self,
        "MemberAttribute": FooMemberAttributeMacro.self,
        "Peer": FooPeerMacro.self,
    ]
#endif

final class ProtocolBasedDependenciesTests: XCTestCase {
    func testMacro() throws {
        #if canImport(ProtocolBasedDependenciesMacros)
            assertMacroExpansion(
                """
                @MemberAttribute
                struct MockCounter {
                    func doNothing() {}

                    @MainActor
                    func doSomething(by value: Int) -> Int {
                        Mock.makeDummyCount()
                    }
                }
                """,
                expandedSource: """
                """,
                macros: testMacros
            )
            assertMacroExpansion(
                """
                #stringify(a + b)
                """,
                expandedSource: """
                (a + b, "a + b")
                """,
                macros: testMacros
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithStringLiteral() throws {
        #if canImport(ProtocolBasedDependenciesMacros)
            assertMacroExpansion(
                #"""
                #stringify("Hello, \(name)")
                """#,
                expandedSource: #"""
                ("Hello, \(name)", #""Hello, \(name)""#)
                """#,
                macros: testMacros
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
