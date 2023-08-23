import XCTestDynamicOverlay

/// Asserts that a value has a set of changes.
///
/// This function evaluates a given expression before and after a given operation and then compares
/// the results. The comparison is done by invoking the `changes` closure with a mutable version of
/// the initial value, and then asserting that the modifications made match the final value using
/// ``XCTAssertNoDifference``.
///
/// For example, given a very simple counter structure, we can write a test against its incrementing
/// functionality:
/// `
/// ```swift
/// struct Counter {
///   var count = 0
///   var isOdd = false
///   mutating func increment() {
///     self.count += 1
///     self.isOdd.toggle()
///   }
/// }
///
/// var counter = Counter()
/// XCTAssertDifference(counter) {
///   counter.increment()
/// } changes: {
///   $0.count = 1
///   $0.isOdd = true
/// }
/// ```
///
/// If the `changes` does not exhaustively describe all changed fields, the assertion will fail.
///
/// By omitting the operation you can write a "non-exhaustive" assertion against a value by
/// describing just the fields you want to assert against in the `changes` closure:
///
/// ```swift
/// counter.increment()
/// XCTAssertDifference(counter) {
///   $0.count = 1
///   // Don't need to further describe how `isOdd` has changed
/// }
/// ```
///
/// - Parameters:
///   - expression: An expression that is evaluated before and after `operation`, and then compared.
///   - message: An optional description of a failure.
///   - operation: An optional operation that is performed in between an initial and final
///     evaluation of `operation`. By omitting this operation, you can write a "non-exhaustive"
///     assertion against an already-changed value by describing just the fields you want to assert
///     against in the `changes` closure.
///   - updateExpectingResult: A closure that asserts how the expression changed by supplying a
///     mutable version of the initial value. This value must be modified to match the final value.
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

/// Asserts that a value has a set of changes.
///
/// An async version of ``XCTAssertDifference(_:_:operation:changes:)``.
@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
public func XCTAssertDifference<T: Sendable>(
  _ expression: @autoclosure @Sendable () throws -> T,
  _ message: @autoclosure @Sendable () -> String = "",
  operation: @Sendable () async throws -> Void = {},
  changes updateExpectingResult: @Sendable (inout T) throws -> Void,
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
