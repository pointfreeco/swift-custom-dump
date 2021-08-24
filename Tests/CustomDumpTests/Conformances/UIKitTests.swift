#if canImport(UIKit)
  import CustomDump
  import XCTest
  import UIKit

  final class UIKitTests: XCTestCase {
    func testUIControlState() {
      var output: String = ""
      customDump(UIControl.State.selected, to: &output)
      XCTAssertEqual(
        output,
        "UIControl.State.selected"
      )
    }
  }
#endif
