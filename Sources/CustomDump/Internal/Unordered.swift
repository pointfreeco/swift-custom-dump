import Foundation

public protocol _UnorderedCollection {}
extension Dictionary: _UnorderedCollection {}
extension NSDictionary: _UnorderedCollection {}
extension NSSet: _UnorderedCollection {}
extension Set: _UnorderedCollection {}
