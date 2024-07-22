import IssueReporting

/// Asserts that two values have no difference.
///
/// Similar to `XCTAssertEqual`, but that function uses either `TextOutputStreamable`,
/// `CustomStringConvertible` or `CustomDebugStringConvertible` in order to display a failure
/// message:
///
/// ```swift
/// XCTAssertEqual(user1, user2)
/// ```
/// ```text
/// XCTAssertEqual failed: ("User(id: 42, name: "Blob")") is not equal to ("User(id: 42, name: "Blob, Esq.")")
/// ```
///
/// `XCTAssertNoDifference` uses the output of ``diff(_:_:format:)`` to display a failure message,
/// which helps highlight the differences between the given values:
///
/// ```swift
/// XCTAssertNoDifference(user1, user2)
/// ```
/// ```text
/// XCTAssertNoDifference failed: …
///
///     User(
///       id: 42,
///   -   name: "Blob"
///   +   name: "Blob, Esq."
///     )
///
/// (First: -, Second: +)
/// ```
///
/// - Parameters:
///   - expression1: An expression of type `T`, where `T` is `Equatable`.
///   - expression2: A second expression of type `T`, where `T` is `Equatable`.
///   - message: An optional description of a failure.
///   - fileID: The file where the failure occurs. The default is the file ID of the test case where
///     you call this function.
///   - filePath: The file where the failure occurs. The default is the file path of the test case
///     where you call this function.
///   - line: The line number where the failure occurs. The default is the line number where you
///     call this function.
///   - line: The column where the failure occurs. The default is the column where you call this
///     function.
public func expectNoDifference<T: Equatable>(
  _ expression1: @autoclosure () throws -> T,
  _ expression2: @autoclosure () throws -> T,
  _ message: @autoclosure () -> String? = nil,
  fileID: StaticString = #fileID,
  filePath: StaticString = #filePath,
  line: UInt = #line,
  column: UInt = #column
) {
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
        ("\(expression1)" is not equal to ("\(expression2)"), but no difference was detected.
        """,
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
      )
      return
    }
    reportIssue(
      """
      \(message?.appending(" - ") ?? "")Difference: …

      \(difference.indenting(by: 2))

      (First: \(format.first), Second: \(format.second))
      """,
      fileID: fileID,
      filePath: filePath,
      line: line,
      column: column
    )
  } catch {
    reportIssue(
      error,
      fileID: fileID,
      filePath: filePath,
      line: line,
      column: column
    )
  }
}
