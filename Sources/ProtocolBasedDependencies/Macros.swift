/// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.
@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(
    module: "ProtocolBasedDependenciesMacros",
    type: "StringifyMacro"
)

@attached(accessor)
public macro Accessor(name: String? = nil) = #externalMacro(
    module: "ProtocolBasedDependenciesMacros",
    type: "FooAccessorMacro"
)

@attached(memberAttribute)
public macro MemberAttribute() = #externalMacro(
    module: "ProtocolBasedDependenciesMacros",
    type: "FooMemberAttributeMacro"
)

@attached(peer, names: prefixed(_), overloaded)
public macro Peer(name: String? = nil) = #externalMacro(
    module: "ProtocolBasedDependenciesMacros",
    type: "FooPeerMacro"
)
