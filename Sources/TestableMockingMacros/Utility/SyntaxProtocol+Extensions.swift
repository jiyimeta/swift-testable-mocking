import SwiftSyntax

extension SyntaxProtocol {
    func with<T>(
        _ keyPath: WritableKeyPath<Self, T>,
        block: (T) throws -> T
    ) rethrows -> Self {
        try with(keyPath, block(self[keyPath: keyPath]))
    }
}
