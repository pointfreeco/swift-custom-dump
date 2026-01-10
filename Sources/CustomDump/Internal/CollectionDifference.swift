extension CollectionDifference.Change {
  var offset: Int {
    switch self {
    case .insert(let offset, _, _), .remove(let offset, _, _):
      return offset
    }
  }
}
