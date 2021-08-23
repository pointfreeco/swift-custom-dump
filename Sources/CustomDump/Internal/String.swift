import Foundation

extension String {
  func indenting(by count: Int) -> String {
    self.indenting(with: String(repeating: " ", count: count))
  }

  func indenting(with prefix: String) -> String {
    guard !prefix.isEmpty else { return self }
    return "\(prefix)\(self.replacingOccurrences(of: "\n", with: "\n\(prefix)"))"
  }

  var hashCount: Int {
    var substring = self[...]
    var hashCount = 0
    while let range = substring.range(of: "([#]*\"\"\"|\"\"\"[#]*)", options: .regularExpression) {
      let count = substring.distance(from: range.lowerBound, to: range.upperBound) - 2
      hashCount = max(count, hashCount)
      substring.removeSubrange(..<range.upperBound)
    }
    return hashCount
  }
}
