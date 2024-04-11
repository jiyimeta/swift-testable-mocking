@attached(memberAttribute)
@attached(member, names: arbitrary)
public macro Mock() = #externalMacro(
    module: "TestableMockingMacros",
    type: "MockMacro"
)

@attached(peer)
public macro MockHandlerName(_ name: String) = #externalMacro(
    module: "TestableMockingMacros",
    type: "MockHandlerNameMacro"
)
