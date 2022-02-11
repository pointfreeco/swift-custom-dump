#if canImport(SwiftUI) && DEBUG
  import CustomDump
  import Foundation
  import XCTest

  final class SwiftUITests: XCTestCase {
    func testSwiftUI() {
      var dump = ""
      customDump(
        Animation.easeInOut,
        to: &dump
      )
      XCTAssertNoDifference(
        dump,
        """
        Animation.easeInOut
        """
      )
    }
  }
#endif
