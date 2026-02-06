/// A type that can be converted to a value for the purpose of dumping.
///
/// The `CustomDumpRepresentable` protocol allows you to return _any_ value for the purpose of
/// dumping. This can be used to flatten the dump representation of wrapper types. For example, a
/// type-safe identifier may want to dump its raw value directly:
///
/// ```swift
/// struct ID: RawRepresentable {
///   var rawValue: String
/// }
///
/// extension ID: CustomDumpRepresentable {
///   var customDumpValue: Any {
///     rawValue
///   }
/// }
///
/// customDump(ID(rawValue: "deadbeef")
/// ```
/// ```text
/// "deadbeef"
/// ```
public protocol CustomDumpRepresentable<CustomDumpValue> {
  /// A type representing the contents of the custom dump.
  associatedtype CustomDumpValue = Any

  /// The custom dump value for this instance.
  var customDumpValue: CustomDumpValue { get }

  /// A type representing the custom dump.
  var customDumpSubjectType: Any.Type { get }
}

extension CustomDumpRepresentable {
  public var customDumpSubjectType: Any.Type { type(of: customDumpValue as Any) }
}
