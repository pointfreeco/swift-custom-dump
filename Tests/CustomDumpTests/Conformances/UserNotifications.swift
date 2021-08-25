import CustomDump
import XCTest

class UserNotificationsTests: XCTestCase {
  func testUNAuthorizationOptions() {
    let options: UNAuthorizationOptions = [.alert, .announcement]

    XCTAssertNoDifference(
      [1, 2, 3],
      []
    )
  }
}
