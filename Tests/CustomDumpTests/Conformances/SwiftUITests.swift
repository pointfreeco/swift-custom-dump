#if canImport(SwiftUI) && DEBUG
  import CustomDump
  import Foundation
  import SwiftUI
  import XCTest

  @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
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
