import SwiftSyntax

extension ExprSyntaxProtocol {
    func with(
        try canThrowError: Bool = false,
        withQuestionMark: Bool = false,
        await isAsync: Bool = false
    ) -> ExprSyntax {
        withAwait(isAsync: isAsync).withTry(canThrowError: canThrowError, withQuestionMark: withQuestionMark)
    }

    private func withTry(canThrowError: Bool, withQuestionMark: Bool) -> ExprSyntax {
        if canThrowError {
            ExprSyntax(TryExprSyntax(expression: self))
        } else {
            ExprSyntax(self)
        }
    }

    private func withAwait(isAsync: Bool) -> ExprSyntax {
        if isAsync {
            ExprSyntax(AwaitExprSyntax(expression: self))
        } else {
            ExprSyntax(self)
        }
    }
}
