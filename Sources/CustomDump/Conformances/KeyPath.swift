import Foundation

extension AnyKeyPath: CustomDumpStringConvertible {
  public var customDumpDescription: String {
    // NB: We gate this to 5.9+ due to this crasher: https://github.com/apple/swift/issues/64865
    #if swift(>=5.9)
      if #available(macOS 13.3, iOS 16.4, watchOS 9.4, tvOS 16.4, *) {
        return self.debugDescription
      }
    #endif
    return """
      \(typeName(Self.self))<\
      \(typeName(Self.rootType, genericsAbbreviated: false)), \
      \(typeName(Self.valueType, genericsAbbreviated: false))>
      """
  }
}
