import SwiftSyntax

extension PatternSyntax {
    var identifier: TokenSyntax? {
        self.as(IdentifierPatternSyntax.self)?.identifier
    }
}
