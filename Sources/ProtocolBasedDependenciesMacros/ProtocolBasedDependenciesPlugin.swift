import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ProtocolBasedDependenciesPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        MockHandlerNameMacro.self,
        MockMacro.self,
    ]
}
