extension Character: CustomDumpRepresentable {
  public var customDumpValue: Any {
    String(self)
  }
}

extension ObjectIdentifier: CustomDumpStringConvertible {
  public var customDumpDescription: String {
    self.debugDescription
      .replacingOccurrences(of: "0x0*", with: "0x", options: .regularExpression)
  }
}

extension StaticString: CustomDumpRepresentable {
  public var customDumpValue: Any {
    "\(self)"
  }
}

extension UnicodeScalar: CustomDumpRepresentable {
  public var customDumpValue: Any {
    String(self)
  }
}

extension AnyHashable: CustomDumpRepresentable {
  public var customDumpValue: Any {
    base
  }
}
