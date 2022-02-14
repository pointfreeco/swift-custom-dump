#if canImport(UserNotifications)
  import CustomDump
  import XCTest
  import UserNotifications

  class UserNotificationsTests: XCTestCase {
    func testUNAuthorizationOptions() {
      guard #available(iOS 10, tvOS 10, *) else { return }
      var dump: String = ""
      customDump([.badge, .alert] as UNAuthorizationOptions, to: &dump)
      XCTAssertEqual(
        dump,
        """
        Set([
          UNAuthorizationOptions.alert,
          UNAuthorizationOptions.badge
        ])
        """
      )
    }
  }
#endif
