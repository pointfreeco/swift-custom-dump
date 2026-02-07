public protocol DebugSnapshotRepresentable<DebugSnapshot> {
  associatedtype DebugSnapshot
  var _debugSnapshot: DebugSnapshot { get }
}
