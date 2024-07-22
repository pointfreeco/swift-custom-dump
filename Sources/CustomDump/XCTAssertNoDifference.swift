import XCTestDynamicOverlay

@available(*, deprecated, renamed: "expectNoDifference")
public func XCTAssertNoDifference<T>(
  _ expression1: @autoclosure () throws -> T,
  _ expression2: @autoclosure () throws -> T,
  _ message: @autoclosure () -> String = "",
  file: StaticString = #filePath,
  line: UInt = #line
) where T: Equatable {
  do {
    let expression1 = try expression1()
    let expression2 = try expression2()
    let message = message()
    guard expression1 != expression2 else { return }
    let format = DiffFormat.proportional
    guard let difference = diff(expression1, expression2, format: format)
    else {
      XCTFail(
        """
        XCTAssertNoDifference failed: An unexpected failure occurred. Please report the issue to https://github.com/pointfreeco/swift-custom-dump …

        ("\(expression1)" is not equal to ("\(expression2)")

        But no difference was detected.
        """,
        file: file,
        line: line
      )
      return
    }
    let failure = """
      XCTAssertNoDifference failed: …

      \(difference.indenting(by: 2))

      (First: \(format.first), Second: \(format.second))
      """
    XCTFail(
      "\(failure)\(message.isEmpty ? "" : " - \(message)")",
      file: file,
      line: line
    )
  } catch {
    XCTFail(
      """
      XCTAssertNoDifference failed: threw error "\(error)"
      """,
      file: file,
      line: line
    )
  }
}
