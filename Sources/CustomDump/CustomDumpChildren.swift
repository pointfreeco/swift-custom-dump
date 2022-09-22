/// Implement this protocol to exclude superclass nodes
public protocol CustomDumpExcludeSuperclass {}

/// Implement this protocol to ignore dumping child nodes
///
/// Using this protocol will make the type ignore the children completly and only print out the type name.
/// This can be useful when something is irrelevant
public protocol CustomDumpIgnoreChildNodes {}

/// Properties to include child nodes. By default all child nodes are included but when this is implemented, only the values passed will be included in the dump
///
/// ```
/// struct Human {
/// let name = "Jimmy"
/// }
///
/// struct User: CustomDumpIncludedChildNodesProvider {
///   static var includedNodes: [String]? {
///     [
///       "name",
///       "email",
///       "friends",
///     ]
///   }
///   let name = "John"
///   let email = "john@me.com"
///   let age = 97
///   let friends = [
///     "James",
///     "Lilly",
///     "Peter",
///     "Remus",
///   ]
///   let human = Human()
/// }
/// ```
/// The dump for this will produce
/// ```
/// User(
///   name: "John",
///   email: "john@me.com",
///   friends: [
///     [0]: "James",
///     [1]: "Lilly",
///     [2]: "Peter",
///     [3]: "Remus"
///   ]
/// )
/// ```
public protocol CustomDumpIncludedChildNodesProvider {
  /// Which nodes to include in the dump
  static var includedNodes: [String]? { get }
}

/// Properties to exclude child nodes. This can be helpful when one or more fields are not relevant
///
/// ```
/// struct Human {
/// let name = "Jimmy"
/// }
///
/// struct User: CustomDumpExcludedChildNodesProvider {
///   static var excludedNodes: [String] {
///     [
///       "age",
///       "friends"
///     ]
///   }
///   let name = "John"
///   let email = "john@me.com"
///   let age = 97
///   let friends = [
///     "James",
///     "Lilly",
///     "Peter",
///     "Remus",
///   ]
///   let human = Human()
/// }
/// ```
/// The dump for this will produce
/// ```
/// User(
///   name: "John",
///   email: "john@me.com",
///   friends: [
///     [0]: "James",
///     [1]: "Lilly",
///     [2]: "Peter",
///     [3]: "Remus"
///   ]
/// )
/// ```
public protocol CustomDumpExcludedChildNodesProvider {
  /// Which nodes to exclude from the dump
  static var excludedNodes: [String] { get }
}
