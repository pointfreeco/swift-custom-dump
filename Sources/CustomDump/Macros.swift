/// Adds a debug snapshot representation to a class.
///
/// This macro defines an inner, equatable struct representation of a reference type. This can
/// enhance the exhaustive testability of an object through
/// ``expectDifference(_:_:operation:changes:fileID:filePath:line:column:)``.
@attached(
  member,
  names: named(DebugSnapshot), named(_debugSnapshot)
)
@attached(
  extension,
  conformances: DebugSnapshotRepresentable
)
public macro DebugSnapshot() = #externalMacro(module: "CustomDumpMacros", type: "DebugSnapshotMacro")

@attached(peer)
public macro DebugSnapshotValue() =
  #externalMacro(module: "CustomDumpMacros", type: "DebugSnapshotValueMacro")

/// Flags a property to be ignored by `@DebugSnapshot`.
///
/// Ignored properties will not be included in the generated
/// ``DebugSnapshotRepresentable/DebugSnapshot`` type.
@attached(peer)
public macro DebugSnapshotIgnored() =
  #externalMacro(module: "CustomDumpMacros", type: "DebugSnapshotIgnoredMacro")
