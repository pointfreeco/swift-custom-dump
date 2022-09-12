#if canImport(UIKit) && !os(watchOS)
  import CustomDump
  import XCTest
  import UIKit

  final class UIKitTests: XCTestCase {
    func testUIControlState() {
      var dump = ""
      customDump([.selected, .highlighted] as UIControl.State, to: &dump)
      XCTAssertEqual(
        dump,
        """
        Set([
          UIControl.State.highlighted,
          UIControl.State.normal,
          UIControl.State.selected
        ])
        """
      )

      dump = ""
      customDump(UIControl.State.normal, to: &dump)
      XCTAssertEqual(
        dump,
        """
        Set([
          UIControl.State.normal
        ])
        """
      )
    }
  }
#endif
