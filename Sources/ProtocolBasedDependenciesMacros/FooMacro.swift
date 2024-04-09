import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct FooExtensionMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        []
    }
}

struct MacroError: Error {
    var node: any SyntaxProtocol
    var message: String
}

struct SimpleDiagnosticMessage: DiagnosticMessage {
    var message: String
    var diagnosticID: MessageID
    var severity: DiagnosticSeverity
}

public struct FooDeclarationMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let protocolExpr = node.argumentList.first?.expression.as(TypeExprSyntax.self) else {
            throw MacroError(node: node, message: "error")
        }

        context.diagnose(
            Diagnostic(
                node: node,
                message: SimpleDiagnosticMessage(
                    message: "warning",
                    diagnosticID: MessageID(domain: "test", id: "error"),
                    severity: .warning
                )
            )
        )

        return []
    }
}

public struct FooCodeItemMacro: CodeItemMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        []
    }
}

public struct FooAccessorMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let functionDecl = declaration.as(FunctionDeclSyntax.self) else {
            throw MacroError(node: node, message: "error")
        }

        return [
            """
            print("foo")
            """,
        ]
    }
}

public struct FooMemberAttributeMacro: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard member.is(FunctionDeclSyntax.self) else {
            return []
        }

        return [
            AttributeSyntax(attributeName: IdentifierTypeSyntax(name: .identifier("available(*, unavailable)"))),
            AttributeSyntax(attributeName: IdentifierTypeSyntax(name: .identifier("_disfavoredOverload"))),
            AttributeSyntax(attributeName: IdentifierTypeSyntax(name: .identifier("Peer"))),
        ]
    }
}
