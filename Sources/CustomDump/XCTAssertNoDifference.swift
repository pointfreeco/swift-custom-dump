import XCTestDynamicOverlay

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
///   - file: The file where the failure occurs. The default is the filename of the test case where
///     you call this function.
///   - line: The line number where the failure occurs. The default is the line number where you
///     call this function.
@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
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
