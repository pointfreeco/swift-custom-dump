extension Character: CustomDumpRepresentable {
  public var customDumpValue: Any {
    String(self)
  }
}

extension ObjectIdentifier: CustomDumpStringConvertible {
  public var customDumpDescription: String {
    self.debugDescription
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
