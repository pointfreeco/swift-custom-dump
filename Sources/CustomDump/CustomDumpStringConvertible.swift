/// A type with a customized textual representation for ``customDump(_:to:name:indent:maxDepth:)``
/// and ``diff(_:_:format:)``.
///
/// Types that want to customize their dump output can conform to this protocol. It is most
/// appropriate for types that have a simple, un-nested internal representation, and typically its
/// output fits on a single line, for example dates, UUIDs, URLs, etc.
///
/// For data types with more structure, for example those with nesting and multiple fields, see the
/// ``CustomDumpReflectable`` protocol.
///
/// The library conforms a bunch of Foundation types to this protocol to simplify their dump output:
///
/// ```swift
/// extension URL: CustomDumpStringConvertible {
///   public var customDumpDescription: String {
///     "URL(\(self.absoluteString))"
///   }
/// }
///
/// customDump(URL(string: "https://www.pointfree.co/")!)
/// ```
/// ```text
/// URL(https://www.pointfree.co/)
/// ```
///
/// Custom Dump also uses this protocol internally to provide more useful output for enums imported
/// from Objective-C:
///
/// ```swift
/// import UserNotifications
///
/// print("dump:")
/// dump(UNNotificationSetting.disabled)
/// print("customDump:")
/// customDump(UNNotificationSetting.disabled)
/// ```
/// ```text
/// dump:
/// - __C.UNNotificationSetting
/// customDump:
/// UNNotificationSettings.disabled
/// ```
///
/// Any time you want to override the dump representation with some other string, you can use this
/// protocol.
///
/// For example, you could introduce a wrapper type that "redacts" a portion of a dump:
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
/// customDump(Redacted(rawValue: "my super secret password"))
/// ```
/// ```text
/// <redacted>
/// ```
public protocol CustomDumpStringConvertible {
  /// The custom dump description for this instance.
  var customDumpDescription: String { get }
}
