enum Box<T> {}

// MARK: - Equatable

protocol AnyEquatable {
  static func isEqual(_ lhs: Any, _ rhs: Any) -> Bool
}

extension Box: AnyEquatable where T: Equatable {
  static func isEqual(_ lhs: Any, _ rhs: Any) -> Bool {
    lhs as? T == rhs as? T
  }
}

func isMirrorEqual(_ lhs: Any, _ rhs: Any) -> Bool {
  func open<LHS>(_: LHS.Type) -> Bool? {
    (Box<LHS>.self as? AnyEquatable.Type)?.isEqual(lhs, rhs)
  }
  if let isEqual = _openExistential(type(of: lhs), do: open) { return isEqual }
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

// MARK: - Identifiable

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
protocol AnyIdentifiable {
  static func isIdentityEqual(_ lhs: Any, _ rhs: Any) -> Bool
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Box: AnyIdentifiable where T: Identifiable {
  static func isIdentityEqual(_ lhs: Any, _ rhs: Any) -> Bool {
    guard let lhs = lhs as? T, let rhs = rhs as? T else { return false }
    return lhs.id == rhs.id
  }
}

func isIdentityEqual(_ lhs: Any, _ rhs: Any) -> Bool {
  guard #available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *) else { return false }
  func open<LHS>(_: LHS.Type) -> Bool? {
    (Box<LHS>.self as? AnyIdentifiable.Type)?.isIdentityEqual(lhs, rhs)
  }
  return _openExistential(type(of: lhs), do: open) ?? false
}

// MARK: - StringProtocol

protocol AnyStringProtocol {
  static func string(from value: Any) -> String?
}

extension Box: AnyStringProtocol where T: StringProtocol {
  static func string(from value: Any) -> String? {
    (value as? T).map { String($0) }
  }
}

func stringFromStringProtocol(_ value: Any) -> String? {
  func open<STR>(_: STR.Type) -> String? {
    (Box<STR>.self as? AnyStringProtocol.Type)?.string(from: value)
  }
  return _openExistential(type(of: value), do: open)
}
