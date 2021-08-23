/// A type that explicitly supplies its own mirror for ``customDump(_:to:name:indent:maxDepth:)``
/// and ``diff(_:_:format:)``.
///
/// Types that want to customize their dump output can conform to this protocol, especially those
/// with a complex or nested internal structure. Providing a custom mirror allows you to reorder,
/// transform, or omit fields on a base structure, or even change the representation of the base
/// structure itself.
///
/// For unstructured data types, or data types that are represented by single values, see the
/// ``CustomDumpStringConvertible`` protocol.
///
/// ## Customizing the dump of a structure's fields
///
/// For example, let's say you have a struct representing login state, which holds a secure token in
/// memory that should never be written to your logs. You can omit the token from `customDump` by
/// providing a mirror that omits this field:
///
/// ```swift
/// struct LoginState: CustomDumpReflectable {
///   var email = ""
///   var password = ""
///   var token: String
///
///   var customDumpMirror: Mirror {
///     .init(
///       self,
///       children: [
///         "email": self.email,
///         "password": self.password
///         // omit token from logs
///       ],
///       displayStyle: .struct
///     )
///   }
/// }
///
/// customDump(
///   LoginState(
///     email: "blob@pointfree.co",
///     password: "bl0bisawesome!",
///     token: "secret"
///   )
/// )
/// ```
/// ```text
/// LoginState(
///   email: "blob@pointfree.co",
///   password: "bl0bisawesome!"
/// )
/// ```
///
/// There! No token data is being written to the dump. However, the dump still contains the user's
/// password, which is sensitive. Rather than omit it entirely, we could redact this information
/// using a `Redacted` wrapper type that redacts its contents from custom dumps via the
/// ``CustomDumpStringConvertible`` protocol:
///
/// ```swift
/// struct Redacted<RawValue>: CustomDumpStringConvertible {
///   let rawValue: RawValue
///
///   var customDumpDescription: String {
///     "<redacted>"
///   }
/// }
///
/// struct LoginState: CustomDumpReflectable {
///   ...
///   var customDumpMirror: Mirror {
///     .init(
///       self,
///       children: [
///         "email": self.email,
///         // redact password!
///         "password": Redacted(rawValue: self.password)
///         // omit token from logs
///       ],
///       displayStyle: .struct
///     )
///   }
/// }
///
/// customDump(
///   LoginState(
///     email: "blob@pointfree.co",
///     password: "bl0bisawesome!",
///     token: "secret"
///   )
/// )
/// ```
/// ```text
/// LoginState(
///   email: "blob@pointfree.co",
///   password: <redacted>
/// )
/// ```
///
/// Now the dump retains the fact that a password field exists, but it prevents the underlying value
/// from being logged.
///
/// ## Overriding a structure's dump representation
///
/// Massaging the data inside a structure is just one way to use a custom mirror. A mirror can also
/// let you completely transform the _way_ a structure is dumped.
///
/// For example, a wrapper type can be flattened to dump the wrapped value by providing the wrapped
/// value's mirror:
///
/// ```swift
/// struct Todos: CustomDumpReflectable {
///   var rawValue: [Todo] = []
///
///   var customDumpMirror: Mirror {
///     .init(reflecting: self.rawValue)
///   }
/// }
///
/// customDump(Todos())
/// ```
/// ```text
/// []
/// ```
public protocol CustomDumpReflectable {
  /// The custom dump mirror for this instance.
  var customDumpMirror: Mirror { get }
}

extension Mirror {
  init(customDumpReflecting subject: Any) {
    self = (subject as? CustomDumpReflectable)?.customDumpMirror ?? Mirror(reflecting: subject)
  }
}
