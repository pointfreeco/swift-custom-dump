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
      while let representable = value as? CustomDumpRepresentable {
        value = representable.customDumpValue
      }
      if let convertible = child.value as? CustomDumpStringConvertible {
        return !convertible.customDumpDescription.contains("\n")
      }
      return Mirror(customDumpReflecting: value).children.isEmpty
    }
  }
}
