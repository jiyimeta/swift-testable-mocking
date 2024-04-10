import SwiftSyntax

extension CodeBlockItemSyntax.Item {
    var expr: ExprSyntax? {
        guard case let .expr(expr) = self else {
            return nil
        }

        return expr
    }
}
