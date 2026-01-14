#if canImport(UniformTypeIdentifiers)
  import UniformTypeIdentifiers

  @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
  extension UTType: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      "UTType(\(identifier))"
    }
  }
#endif
