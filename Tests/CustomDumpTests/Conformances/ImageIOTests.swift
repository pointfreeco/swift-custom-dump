#if canImport(ImageIO)
  import CustomDump
  import ImageIO
  import XCTest

  final class ImageIOTests: XCTestCase {
    func testCGImagePropertyOrientation() {
      var dump = ""
      customDump(
        [.up, .leftMirrored] as [CGImagePropertyOrientation],
        to: &dump
      )
      XCTAssertEqual(
        dump,
        """
        [
          [0]: CGImagePropertyOrientation.up,
          [1]: CGImagePropertyOrientation.leftMirrored
        ]
        """
      )

      dump = ""
      customDump(
        CGImagePropertyOrientation.right,
        to: &dump
      )
      XCTAssertEqual(
        dump,
        """
        CGImagePropertyOrientation.right
        """
      )
    }
  }
#endif
