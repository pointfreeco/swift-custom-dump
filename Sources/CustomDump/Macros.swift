/// Adds a custom dump representation to a class.
///
/// This macro defines an inner, equatable struct representation of a reference type. This can
/// enhance the exhaustive testability of an object through
/// ``expectDifference(_:_:operation:changes:fileID:filePath:line:column:)``.
@attached(
  extension,
  conformances: CustomDumpRepresentable,
  names: named(CustomDumpValue), named(customDumpValue), named(customDumpSubjectType)
)
public macro CustomDump() = #externalMacro(module: "CustomDumpMacros", type: "CustomDumpMacro")

@attached(peer)
public macro CustomDumpValue() = #externalMacro(module: "CustomDumpMacros", type: "CustomDumpValueMacro")

/// Flags a property to be ignored by `@CustomDump`.
///
/// Ignored properties will not be included in the generated
/// ``CustomDumpRepresentable/CustomDumpValue`` type.
@attached(peer)
public macro CustomDumpIgnored() =
  #externalMacro(module: "CustomDumpMacros", type: "CustomDumpIgnoredMacro")
