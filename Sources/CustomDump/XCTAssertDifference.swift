import IssueReporting

@available(*, deprecated, renamed: "expectDifference")
public func XCTAssertDifference<T>(
  _ expression: @autoclosure () throws -> T,
  _ message: @autoclosure () -> String = "",
  operation: () throws -> Void = {},
  changes updateExpectingResult: (inout T) throws -> Void,
  fileID: StaticString = #fileID,
  file filePath: StaticString = #filePath,
  line: UInt = #line,
  column: UInt = #column
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
      reportIssue(
        """
        XCTAssertDifference failed: ("\(expression1)" is not equal to ("\(expression2)"), but no \
        difference was detected.
        """,
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
      )
      return
    }
    let failure = """
      XCTAssertDifference failed: …

      \(difference.indenting(by: 2))

      (Expected: \(format.first), Actual: \(format.second))
      """
    reportIssue(
      "\(failure)\(message.isEmpty ? "" : " - \(message)")",
      fileID: fileID,
      filePath: filePath,
      line: line,
      column: column
    )
  } catch {
    reportIssue(
      """
      XCTAssertDifference failed: threw error "\(error)"
      """,
      fileID: fileID,
      filePath: filePath,
      line: line,
      column: column
    )
  }
}

@available(*, deprecated, renamed: "expectDifference")
public func XCTAssertDifference<T: Sendable>(
  _ expression: @autoclosure @Sendable () throws -> T,
  _ message: @autoclosure @Sendable () -> String = "",
  operation: @Sendable () async throws -> Void = {},
  changes updateExpectingResult: @Sendable (inout T) throws -> Void,
  fileID: StaticString = #fileID,
  file filePath: StaticString = #filePath,
  line: UInt = #line,
  column: UInt = #column
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
      reportIssue(
        """
        XCTAssertDifference failed: ("\(expression1)" is not equal to ("\(expression2)"), but no \
        difference was detected.
        """,
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
      )
      return
    }
    let failure = """
      XCTAssertDifference failed: …

      \(difference.indenting(by: 2))

      (Expected: \(format.first), Actual: \(format.second))
      """
    reportIssue(
      "\(failure)\(message.isEmpty ? "" : " - \(message)")",
      fileID: fileID,
      filePath: filePath,
      line: line,
      column: column
    )
  } catch {
    reportIssue(
      """
      XCTAssertDifference failed: threw error "\(error)"
      """,
      fileID: fileID,
      filePath: filePath,
      line: line,
      column: column
    )
  }
}
