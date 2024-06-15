extension Mirror {
  var isSingleValueContainer: Bool {
    switch self.displayStyle {
    case .collection?, .dictionary?, .set?:
      return false
    default:
      guard
        self.children.count == 1,
        let child = self.children.first
      else { return false }
      var value = child.value
      if value is _CustomDiffObject {
        return false
      }
      while let representable = value as? CustomDumpRepresentable {
        value = representable.customDumpValue
        if value is _CustomDiffObject {
          return false
        }
      }
      if let convertible = child.value as? CustomDumpStringConvertible {
        return !convertible.customDumpDescription.contains("\n")
      }
      return Mirror(customDumpReflecting: value).children.isEmpty
    }
  }
}

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
