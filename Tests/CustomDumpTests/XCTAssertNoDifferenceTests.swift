import CustomDump
import XCTest

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
