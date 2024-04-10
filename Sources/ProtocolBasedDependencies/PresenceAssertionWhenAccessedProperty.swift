/// A property wrapper type that asserts that the property value is provided.
@propertyWrapper
public struct PresenceAssertedWhenAccessedProperty<Value> {
    private var valueWrapper: ValueWrapper?
    private var defaultValue: Value

    private let name: String
    private let failureHandler: ((_ message: String) -> Void)?

    public var wrappedValue: Value {
        get {
            guard let valueWrapper else {
                failureHandler?("\(name) has not been provided.")
                return defaultValue
            }

            return valueWrapper.value
        }
        set {
            valueWrapper = ValueWrapper(newValue)
        }
    }

    /// - Parameters:
    ///   - name: Property name displayed when assertion fails
    ///   - value: Closure that returns the value provided by the property
    ///   - default: Default value provided by the property when assertion fails
    ///   - failureHandler: Handler called when accessed to the property and its value has not been provided. It should be XCTFailure if test environment, otherwise assertionFailure.
    public init(
        name: String,
        value: (() -> Value)?,
        default defaultValue: Value,
        failureHandler: ((_ message: String) -> Void)? = nil
    ) {
        self.name = name
        valueWrapper = value.map { ValueWrapper($0()) }
        self.defaultValue = defaultValue
        self.failureHandler = failureHandler
    }
}

// MARK: - Subtype

extension PresenceAssertedWhenAccessedProperty {
    private struct ValueWrapper {
        var value: Value

        init(_ value: Value) {
            self.value = value
        }
    }
}
