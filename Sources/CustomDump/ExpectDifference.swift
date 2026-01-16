import IssueReporting

/// Expects that a value has a set of changes.
///
/// This function evaluates a given expression before and after a given operation and then compares
/// the results. The comparison is done by invoking the `changes` closure with a mutable version of
/// the initial value, and then asserting that the modifications made match the final value using
/// ``expectNoDifference``.
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
/// expectDifference(counter) {
///   counter.increment()
/// } changes: {
///   $0.count = 1
///   $0.isOdd = true
/// }
/// ```
///
/// If the `changes` does not exhaustively describe all changed fields, the assertion will fail.
///
/// To write a "non-exhaustive" assertion against a value, perform the mutating work up front, and
/// describe just the fields you want to assert against in the `changes` closure:
///
/// ```swift
/// counter.increment()
/// expectDifference(counter) {
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
public func expectDifference<T: Equatable>(
  _ expression: @autoclosure () throws -> T,
  _ message: @autoclosure () -> String? = nil,
  operation: (() throws -> Void)? = nil,
  changes updateExpectingResult: (inout T) throws -> Void,
  fileID: StaticString = #fileID,
  filePath: StaticString = #filePath,
  line: UInt = #line,
  column: UInt = #column
) {
  withErrorReporting(fileID: fileID, filePath: filePath, line: line, column: column) {
    let original = try expression()
    try operation?()
    var expected = original
    try updateExpectingResult(&expected)
    let actual = try expression()
    expectDifferenceHelp(
      original: original,
      expected: expected,
      actual: actual,
      isExhaustive: operation != nil,
      message: expected != actual || operation != nil ? message() : nil,
      fileID: fileID,
      filePath: filePath,
      line: line,
      column: column
    )
  }
}

#if compiler(>=6.2)
  /// Expects that a value has a set of changes.
  ///
  /// An async version of
  /// ``expectDifference(_:_:operation:changes:fileID:filePath:line:column:)-5fu8q``.
  nonisolated(nonsending) public func expectDifference<T: Equatable>(
    _ expression: @autoclosure () throws -> T,
    _ message: @autoclosure () -> String? = nil,
    operation: () async throws -> Void,
    changes updateExpectingResult: (inout T) throws -> Void,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column
  ) async {
    await withErrorReporting(fileID: fileID, filePath: filePath, line: line, column: column) {
      let original = try expression()
      try await operation()
      var expected = original
      try updateExpectingResult(&expected)
      let actual = try expression()
      expectDifferenceHelp(
        original: original,
        expected: expected,
        actual: actual,
        isExhaustive: true,
        message: expected != actual ? message() : nil,
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
      )
    }
  }
#else
  public func expectDifference<T: Equatable & Sendable>(
    _ expression: @autoclosure @Sendable () throws -> T,
    _ message: @autoclosure @Sendable () -> String? = nil,
    operation: @Sendable () async throws -> Void,
    changes updateExpectingResult: @Sendable (inout T) throws -> Void,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column
  ) async {
    await withErrorReporting(fileID: fileID, filePath: filePath, line: line, column: column) {
      let original = try expression()
      try await operation()
      var expected = original
      try updateExpectingResult(&expected)
      let actual = try expression()
      expectDifferenceHelp(
        original: original,
        expected: expected,
        actual: actual,
        isExhaustive: true,
        message: expected != actual ? message() : nil,
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
      )
    }
  }
#endif

private func expectDifferenceHelp<T: Equatable>(
  original: T,
  expected: T,
  actual: T,
  isExhaustive: Bool,
  message: String?,
  fileID: StaticString = #fileID,
  filePath: StaticString = #filePath,
  line: UInt = #line,
  column: UInt = #column
) {
  guard expected != actual else {
    if isExhaustive, original == actual {
      reportIssue(
        """
        \(message?.appending(" - ") ?? "")No difference detected after applying changes.
        """,
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
      )
    }
    return
  }
  let format = DiffFormat.proportional
  guard let difference = diff(expected, actual, format: format)
  else {
    reportIssue(
      """
      \(message?.appending(" - ") ?? "")\
      ("\(expected)" is not equal to ("\(actual)"), but no difference was detected.
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

    (Expected: \(format.first), Actual: \(format.second))
    """,
    fileID: fileID,
    filePath: filePath,
    line: line,
    column: column
  )
}
