import CustomDump
import Testing

struct ExpectDifferenceTests {
  @Test func basics() {
    var user = User(id: 42, name: "Blob")
    func increment<Value>(_ root: inout Value, at keyPath: WritableKeyPath<Value, Int>) {
      root[keyPath: keyPath] += 1
    }

    expectDifference(user) {
      increment(&user, at: \.id)
    } changes: {
      $0.id = 43
    }
  }

  @Test func nonExhaustive() {
    var user = User(id: 42, name: "Blob")
    user.id += 1
    user.name += " Jr"
    expectDifference(user) {
      $0.name = "Blob Jr"
    }
  }

  @Test func failure() {
    var user = User(id: 42, name: "Blob")
    func increment<Value>(_ root: inout Value, at keyPath: WritableKeyPath<Value, Int>) {
      root[keyPath: keyPath] += 1
    }

    withKnownIssue {
      expectDifference(user) {
        increment(&user, at: \.id)
      } changes: {
        $0.id = 44
      }
    } matching: {
      $0.description.hasSuffix(
        """
        Difference: …

            User(
          −   id: 44,
          +   id: 43,
              name: "Blob"
            )

        (Expected: −, Actual: +)
        """
      )
    }
  }
}
