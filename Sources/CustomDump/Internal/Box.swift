func isMirrorEqual(_ lhs: Any, _ rhs: Any) -> Bool {
  guard let lhs = lhs as? any Equatable else {
    let lhsMirror = Mirror(customDumpReflecting: lhs)
    let rhsMirror = Mirror(customDumpReflecting: rhs)
    guard
      lhsMirror.subjectType == rhsMirror.subjectType,
      lhsMirror.children.count == rhsMirror.children.count
    else { return false }
    guard !lhsMirror.children.isEmpty, !rhsMirror.children.isEmpty
    else {
      return String(describing: lhs) == String(describing: rhs)
    }
    for (lhsChild, rhsChild) in zip(lhsMirror.children, rhsMirror.children) {
      guard
        lhsChild.label == rhsChild.label,
        isMirrorEqual(lhsChild.value, rhsChild.value)
      else { return false }
    }
    return true
  }
  func open<T: Equatable>(_ lhs: T) -> Bool {
    guard let rhs = rhs as? T else { return false }
    return lhs == rhs
  }
  return open(lhs)
}

func isIdentityEqual(_ lhs: Any, _ rhs: Any) -> Bool {
  guard let lhs = lhs as? any Identifiable else { return false }
  func open<LHS: Identifiable>(_ lhs: LHS) -> Bool {
    guard let rhs = rhs as? LHS else { return false }
    return lhs.id == rhs.id
  }
  return open(lhs)
}

func stringFromStringProtocol(_ value: Any) -> String? {
  guard let value = value as? any StringProtocol else { return nil }
  return String(value)
}
