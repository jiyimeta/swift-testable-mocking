import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ProtocolBasedDependenciesPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        FooAccessorMacro.self,
        FooPeerMacro.self,
        FooMemberAttributeMacro.self,
    ]
}
