import SwiftSyntax
import SwiftSyntaxBuilder

extension FunctionCallExprSyntax {
    init(
        _ calledName: String,
        @LabeledExprListBuilder arguments: () throws -> LabeledExprListSyntax
    ) rethrows {
        try self.init(
            calledExpression: DeclReferenceExprSyntax(
                baseName: .identifier(calledName)
            ),
            arguments: LabeledExprListSyntax(itemsBuilder: arguments)
        )
    }
}
