import SwiftSyntax

extension SyntaxProtocol {
    func with<T>(
        _ keyPath: WritableKeyPath<Self, T>,
        block: (T) throws -> T
    ) rethrows -> Self {
        with(keyPath, try block(self[keyPath: keyPath]))
    }
}
