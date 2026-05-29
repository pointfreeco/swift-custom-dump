import Foundation

extension Character: CustomDumpRepresentable {
  public var customDumpValue: Any {
    String(self)
  }
}

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
  @available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
  extension Duration: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      self.formatted(
        .units(
          allowed: [.days, .hours, .minutes, .seconds, .milliseconds, .microseconds, .nanoseconds],
          width: .wide
        )
      )
    }
  }
#endif

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

extension SIMD {
  public var customDumpMirror: Mirror {
    Mirror(self, unlabeledChildren: indices.map { self[$0] })
  }
}

extension SIMD2: CustomDumpReflectable {}
extension SIMD3: CustomDumpReflectable {}
extension SIMD4: CustomDumpReflectable {}
extension SIMD8: CustomDumpReflectable {}
extension SIMD16: CustomDumpReflectable {}
extension SIMD32: CustomDumpReflectable {}
extension SIMD64: CustomDumpReflectable {}
extension SIMDMask: CustomDumpReflectable {}
