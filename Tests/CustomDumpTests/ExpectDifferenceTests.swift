import CustomDump
import XCTest

@available(*, deprecated)
class ExpectDifferencesTests: XCTestCase {
  func testExpectDifference() {
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

  func testExpectDifference_NonExhaustive() {
    let user = User(id: 42, name: "Blob")

    expectDifference(user) {
      $0.id = 42
      $0.name = "Blob"
    }
  }

  #if DEBUG && compiler(>=5.4) && (os(iOS) || os(macOS) || os(tvOS) || os(watchOS))
    func testExpectDifference_Failure() {
      var user = User(id: 42, name: "Blob")
      func increment<Value>(_ root: inout Value, at keyPath: WritableKeyPath<Value, Int>) {
        root[keyPath: keyPath] += 1
      }

      XCTExpectFailure()

      expectDifference(user) {
        increment(&user, at: \.id)
      } changes: {
        $0.id = 44
      }
    }
  #endif
}
