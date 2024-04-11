import SwiftSyntax

extension TypeSyntax {
    func recursivelyConvertingSomeToAny() -> TypeSyntax {
        recursivelyMapChild(of: SomeOrAnyTypeSyntax.self) {
            $0.with(\.someOrAnySpecifier, .keyword(.any).with(\.trailingTrivia, .space))
        }
    }

    func recursivelyMapChild<MatchedType: TypeSyntaxProtocol>(
        of matchedType: MatchedType.Type,
        _ transform: (MatchedType) -> MatchedType
    ) -> TypeSyntax {
        if let match = self.as(matchedType.self) {
            return TypeSyntax(transform(match))
        }

        if let array = self.as(ArrayTypeSyntax.self) {
            return TypeSyntax(
                array.with(\.element) {
                    $0.recursivelyMapChild(of: matchedType, transform)
                }
            )
        }

        if let tuple = self.as(TupleTypeSyntax.self) {
            return TypeSyntax(
                tuple.with(\.elements) {
                    TupleTypeElementListSyntax(
                        $0.map {
                            TupleTypeElementSyntax(type: $0.type.recursivelyMapChild(of: matchedType, transform))
                        }
                    )
                }
            )
        }

        if let function = self.as(FunctionTypeSyntax.self) {
            return TypeSyntax(
                function
                    .with(\.returnClause.type) {
                        $0.recursivelyMapChild(of: matchedType, transform)
                    }
                    .with(\.parameters) {
                        TupleTypeElementListSyntax(
                            $0.map {
                                TupleTypeElementSyntax(type: $0.type.recursivelyMapChild(of: matchedType, transform))
                            }
                        )
                    }
            )
        }

        if let optional = self.as(OptionalTypeSyntax.self) {
            return TypeSyntax(
                optional.with(\.wrappedType) {
                    $0.recursivelyMapChild(of: matchedType, transform)
                }
            )
        }

        if let dictionary = self.as(DictionaryTypeSyntax.self) {
            return TypeSyntax(
                dictionary
                    .with(\.key) {
                        $0.recursivelyMapChild(of: matchedType, transform)
                    }
                    .with(\.value) {
                        $0.recursivelyMapChild(of: matchedType, transform)
                    }
            )
        }

        if let someOrAny = self.as(SomeOrAnyTypeSyntax.self) {
            return TypeSyntax(
                someOrAny.with(\.constraint) {
                    $0.recursivelyMapChild(of: matchedType, transform)
                }
            )
        }

        // TODO: Check other types
        return self
    }
}
