@attached(member, names: named(DiffableState), named(diffableState))
@attached(extension, conformances: DiffableState)
public macro DiffableState() = #externalMacro(module: "CustomDumpMacros", type: "DiffableStateMacro")

@attached(peer)
public macro DiffableStateIgnored() =
  #externalMacro(module: "CustomDumpMacros", type: "DiffableStateIgnoredMacro")
