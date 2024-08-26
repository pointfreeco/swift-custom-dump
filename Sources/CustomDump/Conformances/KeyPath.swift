import Foundation

extension AnyKeyPath: CustomDumpStringConvertible {
  public var customDumpDescription: String {
    if #available(macOS 13.3, iOS 16.4, watchOS 9.4, tvOS 16.4, *) {
      return self.debugDescription
    }
    return """
      \(typeName(Self.self))<\
      \(typeName(Self.rootType, genericsAbbreviated: false)), \
      \(typeName(Self.valueType, genericsAbbreviated: false))>
      """
  }
}
