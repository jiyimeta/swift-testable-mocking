import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

public struct MockMacro {}

// MARK: - Member attribute macro

extension MockMacro: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard
            let typeDeclInfo = makeTypeDeclInfo(from: member),
            typeDeclInfo.name.identifierName == "Conformance"
        else {
            return []
        }

        return [
            AttributeSyntax(identifierName: "available(*, unavailable)")
        ]
    }
}


// MARK: - Member macro

extension MockMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let conformanceDeclInfo = declaration.memberBlock.members
            .compactMap({ makeTypeDeclInfo(from: $0.decl) })
            .first(where: { $0.name.identifierName == "Conformance" })
        else {
            // TODO: Add fixit
            throw DiagnosticsError("An inner type `Conformance` must be declared.", at: node)
        }

        let propertyInfos = try conformanceDeclInfo.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self)?.bindings }
            .flatMap {
                try $0.map {
                    try makePropertyInfo(from: $0, node: node)
                }
            }

        let handlerInfos = try conformanceDeclInfo.members
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
            .map { try makeHandlerInfo(from: $0) }

        // TODO: Also check property names
        let duplicateHandlerNames = handlerInfos.compactMap(\.name.identifierName).duplicateElements()
        guard duplicateHandlerNames.isEmpty else {
            let joinedHandlerNames = duplicateHandlerNames
                .map { "`\($0)`" }
                .joined(separator: ",")

            // TODO: Add fixit
            throw DiagnosticsError(
                """
                There are functions with same name \(joinedHandlerNames).
                Please rename the functions or attach `@MockHandlerName(_:)` to them.`
                """,
                at: node
            )
        }

        let failureHandlerDecl: DeclSyntax = "private let failureHandler: (_ message: String) -> Void"
        let newPropertyDecls = propertyInfos.map { makePropertyDecl(from: $0) }
        let newMethodDecls = try handlerInfos.map { try makeMethodDecl(from: $0, node: node) }
        let newHandlerDecls = handlerInfos.map { makeHandlerDecl(from: $0) }

        let newInitializerDecl = InitializerDeclSyntax(
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    parameters: FunctionParameterListSyntax(
                        propertyInfos.map { propertyInfo in
                            FunctionParameterSyntax(
                                firstName: propertyInfo.name,
                                type: TypeSyntax(stringLiteral: "(() -> \(propertyInfo.type.trimmed))?"),
                                defaultValue: InitializerClauseSyntax(value: ExprSyntax(stringLiteral: "nil")),
                                trailingComma: .commaToken()
                            )
                        } + handlerInfos.map { handlerInfo in
                            FunctionParameterSyntax(
                                firstName: handlerInfo.name,
                                type: handlerInfo.type,
                                defaultValue: InitializerClauseSyntax(value: ExprSyntax(stringLiteral: "nil")),
                                trailingComma: .commaToken()
                            )
                        } + [
                            "file: StaticString = #file,",
                            "line: UInt = #line",
                        ]
                    )
                )
            ),
            body: CodeBlockSyntax(
                statements: CodeBlockItemListSyntax(
                    [
                        """
                        let failureHandler: (String) -> Void = {
                            #if canImport(XCTest)
                            XCTFail($0, file: file, line: line)
                            #else
                            assertionFailure($0, file: file, line: line)
                            #endif
                        }
                        """
                    ] + propertyInfos.map { propertyInfo in
                        """
                        \(propertyInfo.nameWithUnderscore) = PresenceAssertedWhenAccessedProperty(
                            name: "\(propertyInfo.name)",
                            value: \(propertyInfo.name),
                            default: \(propertyInfo.defaultValue),
                            failureHandler: failureHandler
                        )
                        """
                    } + handlerInfos.map { handlerInfo in
                        """
                        \(handlerInfo.nameWithUnderscore) = \(handlerInfo.name)
                        """
                    } + [
                        """
                        self.failureHandler = failureHandler
                        """
                    ]
                )
            )
        )

        return [failureHandlerDecl]
            + newPropertyDecls.map(DeclSyntax.init)
            + newHandlerDecls.map(DeclSyntax.init)
            + [DeclSyntax(newInitializerDecl)]
            + newMethodDecls.map(DeclSyntax.init)
    }
}

// MARK: - Private methods

extension MockMacro {
    private static func makeMethodDecl(
        from handlerInfo: HandlerInfo,
        node: AttributeSyntax
    ) throws -> FunctionDeclSyntax {
        guard let body = handlerInfo.originalMethodDecl.body else {
            // TODO: Add fixit
            throw DiagnosticsError("Function body is required.", at: node)
        }

        let methodDecl = handlerInfo.originalMethodDecl
            .with(
                \.body,
                body.with(\.statements) {
                    transformStatements(
                        statements: $0,
                        handlerInfo: handlerInfo
                    )
                }
            )

        return methodDecl
    }

    private static func makePropertyDecl(from propertyInfo: PropertyInfo) -> VariableDeclSyntax {
        let propertyDecl = VariableDeclSyntax(
            attributes: AttributeListSyntax {
                AttributeSyntax(identifierName: "PresenceAssertedWhenAccessedProperty")
            },
            .var,
            name: PatternSyntax(IdentifierPatternSyntax(identifier: propertyInfo.name)),
            type: TypeAnnotationSyntax(type: propertyInfo.type)
        )

        return propertyDecl
    }

    private static func makeHandlerDecl(from handlerInfo: HandlerInfo) -> VariableDeclSyntax {
        let handlerDecl = VariableDeclSyntax(
            modifiers: DeclModifierListSyntax {
                DeclModifierSyntax(name: .identifier("private"))
            },
            .let,
            name: PatternSyntax(IdentifierPatternSyntax(identifier: handlerInfo.nameWithUnderscore)),
            type: TypeAnnotationSyntax(type: handlerInfo.type)
        )

        return handlerDecl
    }

    private static func transformStatements(
        statements: CodeBlockItemListSyntax,
        handlerInfo: HandlerInfo
    ) -> CodeBlockItemListSyntax {
        CodeBlockItemListSyntax {
            CodeBlockItemSyntax(
                item: .stmt(
                    StmtSyntax(
                        GuardStmtSyntax(
                            conditions: ConditionElementListSyntax {
                                ConditionElementSyntax(
                                    condition: .optionalBinding(
                                        OptionalBindingConditionSyntax(
                                            bindingSpecifier: "let",
                                            pattern: IdentifierPatternSyntax(
                                                identifier: handlerInfo.nameWithUnderscore
                                            )
                                        )
                                    )
                                )
                            },
                            body: CodeBlockSyntax(
                                statements: CodeBlockItemListSyntax {
                                    "failureHandler(\"\\(#function) has not been implemented.\")"

                                    if statements.count == 1,
                                       let statement = statements.first,
                                       let expr = statement.item.expr {
                                        ReturnStmtSyntax(expression: expr)
                                    } else if statements.isEmpty {
                                        ReturnStmtSyntax()
                                    } else {
                                        statements
                                    }
                                }
                            )
                        )
                    )
                )
            )
            CodeBlockItemSyntax(
                item: .stmt(
                    StmtSyntax(
                        ReturnStmtSyntax(
                            expression: FunctionCallExprSyntax(
                                calledExpression: DeclReferenceExprSyntax(baseName: handlerInfo.nameWithUnderscore),
                                leftParen: .leftParenToken(),
                                arguments: LabeledExprListSyntax(
                                    handlerInfo.originalMethodDecl
                                        .signature
                                        .parameterClause
                                        .parameters
                                        .map {
                                            LabeledExprSyntax(
                                                expression: DeclReferenceExprSyntax(
                                                    baseName: $0.secondName ?? $0.firstName
                                                ),
                                                trailingComma: .commaToken()
                                            )
                                        }
                                        .mapLast { $0.with(\.trailingComma, nil) }
                                ),
                                rightParen: .rightParenToken()
                            )
                            .with(try: handlerInfo.canThrowError, await: handlerInfo.isAsync)
                        )
                    )
                )
            )
        }
    }

    private static func makePropertyInfo(
        from binding: PatternBindingSyntax,
        node: some SyntaxProtocol
    ) throws -> PropertyInfo {
        guard let name = binding.pattern.identifier else {
            throw DiagnosticsError("Property name is required.", at: node)
        }
        guard let type = binding.typeAnnotation?.type else {
            // TODO: Enable declarations without type annotations for primitive types.
            throw DiagnosticsError("Type annotation of property `\(name)` is required.", at: node)
        }
        guard let defaultValue = binding.initializer?.value else {
            // TODO: Enable declarations without default values for primitive types.
            throw DiagnosticsError("Default value must be provided.", at: node)
        }

        return PropertyInfo(
            name: name,
            type: type,
            defaultValue: defaultValue
        )
    }

    private static func makeHandlerInfo(from methodDecl: FunctionDeclSyntax) throws -> HandlerInfo {
        let specifiedHandlerName = methodDecl.attributes
            .compactMap { $0.as(AttributeSyntax.self) }
            .first { $0.hasIdentifierName("MockHandlerName") }?
            .arguments?
            .argumentList?
            .first?
            .expression
            .as(StringLiteralExprSyntax.self)?
            .segments
            .first?
            .as(StringSegmentSyntax.self)?
            .content
            .stringSegmentContent
            .map(TokenSyntax.init(stringLiteral:))

        let handlerSignature = methodDecl.signature
            .with(\.parameterClause) {
                $0.with(\.parameters) {
                    FunctionParameterListSyntax(
                        $0.map {
                            $0.with(\.firstName, .identifier("_").with(\.trailingTrivia, .space))
                                .with(\.secondName, $0.secondName ?? $0.firstName)
                                .with(\.type) {
                                    $0.recursivelyConvertingSomeToAny()
                                }
                        }
                    )
                }
            }
            .with(\.returnClause) {
                $0?.trimmed ?? ReturnClauseSyntax(
                    arrow: .arrowToken(),
                    type: IdentifierTypeSyntax(name: .identifier("Void"))
                )
            }

        return HandlerInfo(
            name: specifiedHandlerName ?? methodDecl.name,
            type: TypeSyntax(stringLiteral: "(\(handlerSignature))?"),
            canThrowError: handlerSignature.effectSpecifiers?.throwsSpecifier != nil,
            isAsync: handlerSignature.effectSpecifiers?.asyncSpecifier != nil,
            originalMethodDecl: methodDecl
        )
    }

    private static func makeTypeDeclInfo(from decl: some DeclSyntaxProtocol) -> TypeDeclInfo? {
        if let structDecl = decl.as(StructDeclSyntax.self) {
            return TypeDeclInfo(
                name: structDecl.name,
                members: structDecl.memberBlock.members,
                inheritedTypes: structDecl.inheritanceClause?.inheritedTypes ?? []
            )
        }

        if let classDecl = decl.as(ClassDeclSyntax.self) {
            return TypeDeclInfo(
                name: classDecl.name,
                members: classDecl.memberBlock.members,
                inheritedTypes: classDecl.inheritanceClause?.inheritedTypes ?? []
            )
        }

        if let enumDecl = decl.as(EnumDeclSyntax.self) {
            return TypeDeclInfo(
                name: enumDecl.name,
                members: enumDecl.memberBlock.members,
                inheritedTypes: enumDecl.inheritanceClause?.inheritedTypes ?? []
            )
        }

        return nil
    }
}

// MARK: - Subtypes

extension MockMacro {
    private struct PropertyInfo {
        var name: TokenSyntax
        var type: TypeSyntax
        var defaultValue: ExprSyntax

        var nameWithUnderscore: TokenSyntax {
            "_\(name)"
        }
    }

    private struct HandlerInfo {
        var name: TokenSyntax
        var type: TypeSyntax
        var canThrowError: Bool
        var isAsync: Bool
        var originalMethodDecl: FunctionDeclSyntax

        var nameWithUnderscore: TokenSyntax {
            "_\(name)"
        }
    }

    private struct TypeDeclInfo {
        var name: TokenSyntax
        var members: MemberBlockItemListSyntax
        var inheritedTypes: InheritedTypeListSyntax

        var inheritedTypeNames: Set<String> {
            Set(
                inheritedTypes.compactMap { $0.as(IdentifierTypeSyntax.self)?.name.identifierName }
            )
        }
    }
}
