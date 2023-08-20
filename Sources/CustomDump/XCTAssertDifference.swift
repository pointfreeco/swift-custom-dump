import XCTestDynamicOverlay

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
public func XCTAssertDifference<T>(
  _ expression: @autoclosure () throws -> T,
  _ message: @autoclosure () -> String = "",
  operation: () throws -> Void = {},
  changes updateExpectingResult: (inout T) throws -> Void,
  file: StaticString = #filePath,
  line: UInt = #line
) where T: Equatable {
  do {
    var expression1 = try expression()
    try updateExpectingResult(&expression1)
    try operation()
    let expression2 = try expression()
    let message = message()
    guard expression1 != expression2 else { return }
    let format = DiffFormat.proportional
    guard let difference = diff(expression1, expression2, format: format)
    else {
      XCTFail(
        """
        XCTAssertDifference failed: ("\(expression1)" is not equal to ("\(expression2)"), but no \
        difference was detected.
        """,
        file: file,
        line: line
      )
      return
    }
    let failure = """
      XCTAssertDifference failed: …

      \(difference.indenting(by: 2))
      
      (Expected: \(format.first), Actual: \(format.second))
      """
    XCTFail(
      "\(failure)\(message.isEmpty ? "" : " - \(message)")",
      file: file,
      line: line
    )
  } catch {
    XCTFail(
      """
      XCTAssertDifference failed: threw error "\(error)"
      """,
      file: file,
      line: line
    )
  }
}

// TODO: Somehow share logic between above and below without `reasync`.
@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
public func XCTAssertDifference<T>(
  _ expression: @autoclosure () throws -> T,
  _ message: @autoclosure () -> String = "",
  operation: () async throws -> Void = {},
  changes updateExpectingResult: (inout T) throws -> Void,
  file: StaticString = #filePath,
  line: UInt = #line
) async where T: Equatable {
  do {
    var expression1 = try expression()
    try updateExpectingResult(&expression1)
    try await operation()
    let expression2 = try expression()
    let message = message()
    guard expression1 != expression2 else { return }
    let format = DiffFormat.proportional
    guard let difference = diff(expression1, expression2, format: format)
    else {
      XCTFail(
        """
        XCTAssertDifference failed: ("\(expression1)" is not equal to ("\(expression2)"), but no \
        difference was detected.
        """,
        file: file,
        line: line
      )
      return
    }
    let failure = """
      XCTAssertDifference failed: …

      \(difference.indenting(by: 2))

      (Expected: \(format.first), Actual: \(format.second))
      """
    XCTFail(
      "\(failure)\(message.isEmpty ? "" : " - \(message)")",
      file: file,
      line: line
    )
  } catch {
    XCTFail(
      """
      XCTAssertDifference failed: threw error "\(error)"
      """,
      file: file,
      line: line
    )
  }
}
