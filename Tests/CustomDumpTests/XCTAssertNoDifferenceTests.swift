import CustomDump
import XCTest

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
class XCTAssertNoDifferenceTests: XCTestCase {
  #if compiler(>=5.4) && (os(iOS) || os(macOS) || os(tvOS) || os(watchOS))
    func testXCTAssertNoDifference() {
      XCTExpectFailure()

      let user = User(id: 42, name: "Blob")
      var other = user
      other.name += " Sr."

      XCTAssertNoDifference(user, other)
    }
  #endif
}
