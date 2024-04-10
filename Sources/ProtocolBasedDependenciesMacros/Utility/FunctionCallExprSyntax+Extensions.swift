import SwiftSyntax
import SwiftSyntaxBuilder

extension FunctionCallExprSyntax {
    init(
        _ calledName: String,
        @LabeledExprListBuilder arguments: () throws -> LabeledExprListSyntax
    ) rethrows {
        self.init(
            calledExpression: DeclReferenceExprSyntax(
                baseName: .identifier(calledName)
            ),
            arguments: try LabeledExprListSyntax(itemsBuilder: arguments)
        )
    }
}
