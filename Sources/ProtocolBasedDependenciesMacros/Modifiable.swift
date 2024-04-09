import SwiftSyntax

protocol Modifiable {}

extension Modifiable {
    func modifying<T>(_ keyPath: WritableKeyPath<Self, T>, to value: T) -> Self {
        var copy = self
        copy[keyPath: keyPath] = value
        return copy
    }
}

extension SyntaxProtocol {
    func with<T>(_ keyPath: WritableKeyPath<Self, T>, block: (T) -> T) -> Self {
        with(keyPath, block(self[keyPath: keyPath]))
    }
}
