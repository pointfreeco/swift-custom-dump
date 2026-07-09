import IssueReporting

@available(*, deprecated, renamed: "expectNoDifference")
public func XCTAssertNoDifference<T>(
  _ expression1: @autoclosure () throws -> T,
  _ expression2: @autoclosure () throws -> T,
  _ message: @autoclosure () -> String = "",
  fileID: StaticString = #fileID,
  file filePath: StaticString = #filePath,
  line: UInt = #line,
  column: UInt = #column
) where T: Equatable {
  do {
    let expression1 = try expression1()
    let expression2 = try expression2()
    let message = message()
    guard expression1 != expression2 else { return }
    let format = DiffFormat.proportional
    guard let difference = diff(expression1, expression2, format: format)
    else {
      reportIssue(
        """
        XCTAssertNoDifference failed: An unexpected failure occurred. Please report the issue to https://github.com/pointfreeco/swift-custom-dump …

        ("\(expression1)" is not equal to ("\(expression2)")

        But no difference was detected.
        """,
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
      )
      return
    }
    let failure = """
      XCTAssertNoDifference failed: …

      \(difference.indenting(by: 2))

      (First: \(format.first), Second: \(format.second))
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
      XCTAssertNoDifference failed: threw error "\(error)"
      """,
      fileID: fileID,
      filePath: filePath,
      line: line,
      column: column
    )
  }
}
