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

    expectNoDifference(
      String(customDumping: model),
      """
      FeatureModel(
        count: 0,
        fact: "0 is a good number."
      )
      """
    )
  }

  @Test func `struct`() async {
    var state = FeatureState()

    await expectDifference(state) {
      try await state.factButtonTapped()
    } changes: {
      $0.fact = "0 is a good number."
    }

    expectNoDifference(
      String(customDumping: state),
      """
      FeatureState(
        count: 0,
        fact: "0 is a good number."
      )
      """
    )
    expectNoDifference(
      diff(FeatureState(), state),
      """
        FeatureState(
          count: 0,
      -   fact: nil
      +   fact: "0 is a good number."
        )
      """
    )
  }
}

@CustomDump
fileprivate struct FeatureState {
  var count = 0
  @PW var fact: String?
  var isEven: Bool { count.isMultiple(of: 2) }
  @CustomDumpIgnored
  var task: Task<Void, Never>?
  mutating func factButtonTapped() async throws {
    await Task.yield()
    fact = "\(count) is a good number."
  }
}

@MainActor
@CustomDump
fileprivate class FeatureModel {
  var count = 0
  var fact: String?
  var isEven: Bool { count.isMultiple(of: 2) }
  @CustomDumpIgnored
  var task: Task<Void, Never>?
  func increment() { count += 1 }
  func factButtonTapped() async throws {
    fact = nil
    await Task.yield()
    fact = "\(count) is a good number."
  }
}

@propertyWrapper
struct PW<WrappedValue> {
  var wrappedValue: WrappedValue
}
extension PW: Sendable where WrappedValue: Sendable {}
