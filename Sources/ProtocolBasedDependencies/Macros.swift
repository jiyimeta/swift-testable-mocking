@attached(memberAttribute)
@attached(member, names: arbitrary)
public macro Mock() = #externalMacro(
    module: "ProtocolBasedDependenciesMacros",
    type: "MockMacro"
)

@attached(peer, names: named(Mock), arbitrary)
public macro MockHandlerName(_ name: String) = #externalMacro(
    module: "ProtocolBasedDependenciesMacros",
    type: "MockHandlerNameMacro"
)
