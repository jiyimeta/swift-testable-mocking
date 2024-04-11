import SwiftSyntax

extension SyntaxCollection {
    func mapLast(_ transform: (Element) throws -> Element) rethrows -> Self {
        try Self(Array(self).mapLast(transform))
    }

    func appending(_ newElement: Element) -> Self {
        Self(Array(self).appending(newElement))
    }
}
