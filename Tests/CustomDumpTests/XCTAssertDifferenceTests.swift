import CustomDump
import XCTest

@available(*, deprecated)
class XCTAssertDifferencesTests: XCTestCase {
  func testXCTAssertDifference() {
    var user = User(id: 42, name: "Blob")
    func increment<Value>(_ root: inout Value, at keyPath: WritableKeyPath<Value, Int>) {
      root[keyPath: keyPath] += 1
    }

    XCTAssertDifference(user) {
      increment(&user, at: \.id)
    } changes: {
      $0.id = 43
    }
  }

  func testXCTAssertDifference_NonExhaustive() {
    let user = User(id: 42, name: "Blob")

    XCTAssertDifference(user) {
      $0.id = 42
      $0.name = "Blob"
    }
  }

  #if DEBUG && compiler(>=5.4) && (os(iOS) || os(macOS) || os(tvOS) || os(watchOS))
    func testXCTAssertDifference_Failure() {
      var user = User(id: 42, name: "Blob")
      func increment<Value>(_ root: inout Value, at keyPath: WritableKeyPath<Value, Int>) {
        root[keyPath: keyPath] += 1
      }

      XCTExpectFailure()

      XCTAssertDifference(user) {
        increment(&user, at: \.id)
      } changes: {
        $0.id = 44
      }
    }
  #endif
}
