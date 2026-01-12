#if canImport(UniformTypeIdentifiers)
  import UniformTypeIdentifiers
  import CustomDump
  import XCTest

  class UniformTypeIdentifiersTests: XCTestCase {
    func testUniformTypeIdentifiers() {
      if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
        var dump: String = ""
        customDump([UTType.data, .jpeg, .pdf], to: &dump)
        XCTAssertEqual(
          dump,
          """
          [
            [0]: public.data,
            [1]: public.jpeg,
            [2]: com.adobe.pdf
          ]
          """
        )
      }
    }
  }
#endif
