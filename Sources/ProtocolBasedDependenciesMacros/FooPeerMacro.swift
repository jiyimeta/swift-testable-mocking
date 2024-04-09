import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct FooPeerMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard
            let functionDecl = declaration.as(FunctionDeclSyntax.self),
            let body = functionDecl.body
        else {
            throw MacroError(node: node, message: "error")
        }

        print(functionDecl.debugDescription)

        let newFunctionDecl = functionDecl
            .with(
                \.body,
                body.with(\.statements) {
                    transformStatements(statements: $0, functionName: functionDecl.name)
                }
            )
            .with(\.attributes) {
                $0.filter {
                    ![
                        .identifier("Peer"),
                        .identifier("available"),
                        .identifier("_disfavoredOverload")
                    ].contains(
                        $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.tokenKind
                    )
                }
            }

        guard let newDecl = newFunctionDecl.as(DeclSyntax.self) else {
            throw MacroError(node: node, message: "error")
        }

        let handlerSignature = functionDecl.signature
            .with(\.parameterClause) {
                $0.with(\.parameters) {
                    .init(
                        $0.map {
                            $0.with(\.firstName.tokenKind, .identifier("_"))
                                .with(\.secondName, $0.secondName ?? $0.firstName)
                        }
                    )
                }
            }
            .with(\.returnClause) {
                $0?.trimmed ?? ReturnClauseSyntax(
                    arrow: .arrowToken(),
                    returnType: IdentifierTypeSyntax(name: .identifier("Void"))
                )
            }

        let handlerDecl: DeclSyntax =
            """
            private let _\(functionDecl.name): (\(handlerSignature))?
            """

        return [
            handlerDecl,
            newDecl,
        ]
    }
}

extension FooPeerMacro {
    private static func transformStatements(
        statements: CodeBlockItemListSyntax,
        functionName: TokenSyntax
    ) -> CodeBlockItemListSyntax {
        [
            """
            guard let _\(functionName) else {
            // fail
            \(statements)
            }
            """,
        ]
    }
}
