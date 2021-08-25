#if canImport(UserNotifications)
  import CustomDump
  import XCTest
  import UserNotifications

  class UserNotificationsTests: XCTestCase {
    func testUNAuthorizationOptions() {
      var dump: String = ""
      customDump([.alert, .announcement] as UNAuthorizationOptions, to: &dump)
      XCTAssertEqual(
        dump,
        """
        Set([
          UNAuthorizationOptions.alert,
          UNAuthorizationOptions.announcement
        ])
        """
      )
    }
  }
#endif
