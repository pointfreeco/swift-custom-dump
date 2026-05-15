func isIdentityEqual(_ lhs: Any, _ rhs: Any) -> Bool {
  if let lhs = lhs as? any _CustomDiffObject,
    let rhs = rhs as? any _CustomDiffObject
  {
    return lhs._objectIdentifier == rhs._objectIdentifier
  }
  guard let lhs = lhs as? any Identifiable else { return false }
  func open<LHS: Identifiable>(_ lhs: LHS) -> Bool {
    guard let rhs = rhs as? LHS else { return false }
    return lhs.id == rhs.id
  }
  return open(lhs)
}
