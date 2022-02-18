#if canImport(CoreImage)
  import CoreImage
  import CustomDump
  import XCTest

  final class CoreImageTests: XCTestCase {
    func testCIQRCodeDescriptor() {
      var dump = ""
      customDump(
        [.levelH, .levelL, .levelM, .levelQ] as [CIQRCodeDescriptor.ErrorCorrectionLevel],
        to: &dump
      )

      XCTAssertEqual(
        dump,
        """
        [
          [0]: CIQRCodeDescriptor.ErrorCorrectionLevel.levelH,
          [1]: CIQRCodeDescriptor.ErrorCorrectionLevel.levelL,
          [2]: CIQRCodeDescriptor.ErrorCorrectionLevel.levelM,
          [3]: CIQRCodeDescriptor.ErrorCorrectionLevel.levelQ
        ]
        """
      )

      dump = ""
      customDump(
        CIQRCodeDescriptor.ErrorCorrectionLevel.levelH,
        to: &dump
      )
      XCTAssertEqual(
        dump,
        """
        CIQRCodeDescriptor.ErrorCorrectionLevel.levelH
        """
      )
    }
  }
#endif
