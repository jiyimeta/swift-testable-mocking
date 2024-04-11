import SwiftSyntax

extension LabeledExprSyntax {
    init(_ label: String?, identifierName: String) {
        self.init(
            label: label,
            expression: DeclReferenceExprSyntax(
                baseName: .identifier(identifierName)
            )
        )
    }
}
