@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension CollectionDifference.Change {
  var offset: Int {
    switch self {
    case let .insert(offset, _, _), let .remove(offset, _, _):
      return offset
    }
  }
}
