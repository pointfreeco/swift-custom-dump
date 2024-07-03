import IssueReporting

// Check that two values are equal.
///
/// TODO
///
/// - Parameters:
///   - expression1: An expression of type `T`, where `T` is `Equatable`.
///   - expression2: A second expression of type `T`, where `T` is `Equatable`.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default is the filename of the test case where
///     you call this function.
///   - line: The line number where the failure occurs. The default is the line number where you
///     call this function.
@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
public func expectNoDifference<T>(
  _ expression1: @autoclosure () throws -> T,
  _ expression2: @autoclosure () throws -> T,
  _ message: @autoclosure () -> String = "",
  fileID: StaticString = #fileID,
  filePath: StaticString = #filePath,
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
        expectNoDifference failed: An unexpected failure occurred. Please report the issue to https://github.com/pointfreeco/swift-custom-dump …
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
      expectNoDifference failed: …
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
      expectNoDifference failed: threw error "\(error)"
      """,
      fileID: fileID,
      filePath: filePath,
      line: line,
      column: column
    )
  }
}
