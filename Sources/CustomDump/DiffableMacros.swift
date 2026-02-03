@attached(member, names: named(Representation), named(customDumpValue))
@attached(extension, conformances: CustomDumpRepresentable)
public macro CustomDump() = #externalMacro(module: "CustomDumpMacros", type: "CustomDumpMacro")

@attached(peer)
public macro CustomDumpIgnored() =
  #externalMacro(module: "CustomDumpMacros", type: "CustomDumpIgnoredMacro")
