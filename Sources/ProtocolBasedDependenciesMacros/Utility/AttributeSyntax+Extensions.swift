import SwiftSyntax

extension AttributeSyntax {
    init(identifierName: String) {
        self.init(attributeName: IdentifierTypeSyntax(name: .identifier(identifierName)))
    }

    func hasIdentifierName(_ name: String) -> Bool {
        attributeName.as(IdentifierTypeSyntax.self)?.name.identifierName == name
    }
}

extension AttributeSyntax.Arguments {
    var argumentList: LabeledExprListSyntax? {
        guard case let .argumentList(labeledExprList) = self else {
            return nil
        }

        return labeledExprList
    }
}
