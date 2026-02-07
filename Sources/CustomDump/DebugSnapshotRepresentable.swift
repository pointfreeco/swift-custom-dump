public protocol DebugSnapshotRepresentable<DebugSnapshot> {
  associatedtype DebugSnapshot
  var _debugSnapshot: DebugSnapshot { get }
}

extension Optional: DebugSnapshotRepresentable where Wrapped: DebugSnapshotRepresentable {
  public var _debugSnapshot: Wrapped.DebugSnapshot? {
    self?._debugSnapshot
  }
}

extension Array: DebugSnapshotRepresentable where Element: DebugSnapshotRepresentable {
  public var _debugSnapshot: [Element.DebugSnapshot] {
    map(\._debugSnapshot)
  }
}
