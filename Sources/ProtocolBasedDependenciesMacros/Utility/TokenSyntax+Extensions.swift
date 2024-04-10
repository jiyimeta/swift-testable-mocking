import SwiftSyntax

extension TokenSyntax {
    var identifierName: String? {
        guard case let .identifier(name) = tokenKind else {
            return nil
        }

        return name
    }

    var stringSegmentContent: String? {
        guard case let .stringSegment(content) = tokenKind else {
            return nil
        }

        return content
    }
}
