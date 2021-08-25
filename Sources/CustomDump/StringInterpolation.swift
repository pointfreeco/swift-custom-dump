extension String.StringInterpolation {
  public mutating func appendInterpolation<T>(dump value: T) {
    var target = ""
    _ = customDump(value, to: &target, name: nil, indent: 0, maxDepth: .max)
    appendLiteral(target)
  }
}