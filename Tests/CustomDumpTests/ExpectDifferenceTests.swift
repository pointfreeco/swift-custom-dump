import CustomDump
import Observation
import Testing

@MainActor
@Suite
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

  @Test func customDumpRepresentable() async throws {
    let model = FeatureModel()

    await expectDifference(model) {
      try await model.factButtonTapped()
    } changes: {
      $0.fact = "0 is a good number."
    }
  }

  @MainActor
  @CustomDump
  @Observable
  fileprivate class FeatureModel {
    var count: Int = 0
    var fact: String?
    var isEven: Bool { count.isMultiple(of: 2) }
    @CustomDumpIgnored
    var task: Task<Void, Never>?
    func increment() { count += 1 }
    func factButtonTapped() async throws {
      fact = nil
      try await Task.sleep(for: .seconds(0))
      fact = "\(count) is a good number."
    }
  }
}
