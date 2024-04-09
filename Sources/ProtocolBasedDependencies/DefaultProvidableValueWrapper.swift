public struct DefaultProvidableValueWrapper<Value> {
    public var defaultValue: Value
    public var valueProvider: (() -> Value)?

    public init(
        _ valueProvider: (() -> Value)?,
        default defaultValue: Value
    ) {
        self.valueProvider = valueProvider
        self.defaultValue = defaultValue
    }
}

public protocol DefaultValueProvidable {
    static var defaultValue: Self { get }
}

extension Int: DefaultValueProvidable {
    public static var defaultValue: Int { 0 }
}
