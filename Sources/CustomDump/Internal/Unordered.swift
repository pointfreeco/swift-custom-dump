#if canImport(Foundation)
import Foundation
#endif

public protocol _UnorderedCollection {}
#if canImport(Foundation)
extension Dictionary: _UnorderedCollection {}
extension NSDictionary: _UnorderedCollection {}
extension NSSet: _UnorderedCollection {}
#endif
extension Set: _UnorderedCollection {}
