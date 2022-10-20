import CustomDump
import XCTest

final class SwiftTests: XCTestCase {
  func testCharacter() {
    let character: Character = "a"
    var dump = ""
    customDump(
      character,
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      "a"
      """
    )
  }

  func testStaticString() {
    let string: StaticString = "hello world!"
    var dump = ""
    customDump(
      string,
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      "hello world!"
      """
    )
  }

  func testUnicodeScalar() throws {
    let scalar = try XCTUnwrap("a".unicodeScalars.first)
    var dump = ""
    customDump(
      scalar,
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      "a"
      """
    )
  }

  func testAnyHashable() {
    let user: AnyHashable = HashableUser(id: 1, name: "James")
    var dump = ""
    customDump(
      user,
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      HashableUser(
        id: 1,
        name: "James"
      )
      """
    )
  }
}
