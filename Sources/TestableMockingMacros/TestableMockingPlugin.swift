import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct TestableMockingPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        MockHandlerNameMacro.self,
        MockMacro.self,
    ]
}
