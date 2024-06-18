/// Detects differences between two given values by comparing their mirrors and optionally returns
/// a formatted string describing it.
///
/// This can be a great tool to use for building debug tools for applications and libraries. For
/// example, this library uses ``diff(_:_:format:)`` to implement
/// ``XCTAssertNoDifference(_:_:_:file:line:)``, which asserts that two values are equal, and
/// if they are not the failure message is a nicely formatted diff showing exactly what part of the
/// values are not equal.
///
/// Further, the
/// [Composable Architecture](https://www.github.com/pointfreeco/swift-composable-architecture) uses
/// ``diff(_:_:format:)`` in a couple different ways:
///
/// * It is used to implement a tool that prints changes to application state over time as diffs
///   between the previous state and the current state whenever an action is sent to the store.
/// * It is also used in a testing tool so that when one fails to assert for how state may have
///   changed after sending an action, it can display a concise message showing the exact difference
///   in state.
///
/// - Parameters:
///   - lhs: An expression of type `T`.
///   - rhs: A second expression of type `T`.
///   - format: A format to use for the diff. By default it uses ASCII characters typically
///     associated with the "diff" format: "-" for removals, "+" for additions, and " " for
///     unchanged lines.
/// - Returns: A string describing any difference detected between values, or `nil` if no difference
///   is detected.
public func diff<T>(_ lhs: T, _ rhs: T, format: DiffFormat = .default) -> String? {
  var tracker = ObjectTracker()

  func diffHelp(
    _ lhs: Any,
    _ rhs: Any,
    lhsName: String?,
    rhsName: String?,
    separator: String,
    indent: Int,
    isRoot: Bool
  ) -> String {
    let rhsName = rhsName ?? lhsName
    guard lhsName != rhsName || !isMirrorEqual(lhs, rhs) else {
      return _customDump(
        lhs,
        name: rhsName,
        indent: indent,
        isRoot: isRoot,
        maxDepth: 0,
        tracker: &tracker
      )
      .appending(separator)
      .indenting(with: format.both + " ")
    }

    let lhsMirror = Mirror(customDumpReflecting: lhs)
    let rhsMirror = Mirror(customDumpReflecting: rhs)
    var out = ""

    func diffEverything() {
      var lhs = _customDump(
        lhs,
        name: lhsName,
        indent: indent,
        isRoot: isRoot,
        maxDepth: .max,
        tracker: &tracker
      )
      var rhs = _customDump(
        rhs,
        name: rhsName,
        indent: indent,
        isRoot: isRoot,
        maxDepth: .max,
        tracker: &tracker
      )
      if lhs == rhs {
        if lhsMirror.subjectType != rhsMirror.subjectType {
          lhs.append(" as \(typeName(lhsMirror.subjectType))")
          rhs.append(" as \(typeName(rhsMirror.subjectType))")
        }
      }
      lhs.append(separator)
      rhs.append(separator)

      print(
        lhs.indenting(with: format.first + " "),
        to: &out
      )
      print(
        rhs.indenting(with: format.second + " "),
        terminator: "",
        to: &out
      )
    }

    guard lhsMirror.subjectType == rhsMirror.subjectType
    else {
      diffEverything()
      return out
    }

    func diffChildren(
      lhs: Any = lhs,
      rhs: Any = rhs,
      _ lhsMirror: Mirror,
      _ rhsMirror: Mirror,
      lhsName: String? = lhsName,
      rhsName: String? = rhsName,
      nameSuffix: String = ":",
      prefix: String,
      suffix: String,
      elementIndent: Int,
      elementSeparator: String,
      collapseUnchanged: Bool,
      filter isIncluded: (Mirror.Child) -> Bool = { _ in true },
      areEquivalent: (Mirror.Child, Mirror.Child) -> Bool = { $0.label == $1.label },
      areInIncreasingOrder: ((Mirror.Child, Mirror.Child) -> Bool)? = nil,
      map transform: (inout Mirror.Child, Int) -> Void = { _, _ in }
    ) {
      var lhsChildren = Array(lhsMirror.children)
      var rhsChildren = Array(rhsMirror.children)

      if isMirrorEqual(lhsChildren, rhsChildren),
        !(lhs is _CustomDiffObject),
        !(rhs is _CustomDiffObject)
      {
        let lhsDump =
          _customDump(
            lhs,
            name: lhsName,
            nameSuffix: nameSuffix,
            indent: indent,
            isRoot: false,
            maxDepth: 0,
            tracker: &tracker
          ) + separator
        let rhsDump =
          _customDump(
            rhs,
            name: rhsName,
            nameSuffix: nameSuffix,
            indent: indent,
            isRoot: false,
            maxDepth: 0,
            tracker: &tracker
          ) + separator
        if lhsDump == rhsDump {
          print(
            "// Not equal but no difference detected:"
              .indenting(by: indent)
              .indenting(with: format.both + " "),
            to: &out
          )
        }
        print(
          lhsDump.indenting(with: format.first + " "),
          to: &out
        )
        print(
          rhsDump.indenting(with: format.second + " "),
          terminator: "",
          to: &out
        )
        return
      }

      guard !lhsMirror.isSingleValueContainer && !rhsMirror.isSingleValueContainer
      else {
        print(
          _customDump(
            lhs,
            name: lhsName,
            nameSuffix: nameSuffix,
            indent: indent,
            isRoot: isRoot,
            maxDepth: .max,
            tracker: &tracker
          )
          .indenting(with: format.first + " "),
          to: &out
        )
        print(
          _customDump(
            rhs,
            name: rhsName,
            nameSuffix: nameSuffix,
            indent: indent,
            isRoot: isRoot,
            maxDepth: .max,
            tracker: &tracker
          )
          .indenting(with: format.second + " "),
          terminator: "",
          to: &out
        )
        return
      }

      lhsChildren.removeAll(where: { !isIncluded($0) })
      rhsChildren.removeAll(where: { !isIncluded($0) })

      let name = rhsName.map { "\($0)\(nameSuffix) " } ?? ""
      print(
        name
          .appending(prefix)
          .indenting(by: indent)
          .indenting(with: format.both + " "),
        to: &out
      )

      if let areInIncreasingOrder {
        lhsChildren.sort(by: areInIncreasingOrder)
        rhsChildren.sort(by: areInIncreasingOrder)
      }

      let difference = rhsChildren.difference(from: lhsChildren, by: areEquivalent)

      var lhsOffset = 0
      var rhsOffset = 0
      var unchangedBuffer: [Mirror.Child] = []

      func flushUnchanged() {
        guard collapseUnchanged else { return }
        if areInIncreasingOrder == nil && unchangedBuffer.count == 1 {
          let child = unchangedBuffer[0]
          print(
            _customDump(
              child.value,
              name: child.label,
              indent: indent + elementIndent,
              isRoot: false,
              maxDepth: 0,
              tracker: &tracker
            )
            .indenting(with: format.both + " "),
            terminator: rhsOffset - 1 == rhsChildren.count - 1 ? "\n" : "\(elementSeparator)\n",
            to: &out
          )
        } else if areInIncreasingOrder != nil && unchangedBuffer.count == 1
          || unchangedBuffer.count > 1
        {
          print(
            "… (\(unchangedBuffer.count) unchanged)"
              .indenting(by: indent + elementIndent)
              .indenting(with: format.both + " "),
            terminator: rhsOffset - 1 == rhsChildren.count - 1 ? "\n" : "\(elementSeparator)\n",
            to: &out
          )
        }
        unchangedBuffer.removeAll()
      }

      while lhsOffset < lhsChildren.count || rhsOffset < rhsChildren.count {
        let isRemoval = difference.removals.contains(where: { $0.offset == lhsOffset })
        let isInsertion = difference.insertions.contains(where: { $0.offset == rhsOffset })

        if collapseUnchanged,
          !isRemoval,
          !isInsertion,
          isMirrorEqual(lhsChildren[lhsOffset], rhsChildren[rhsOffset])
        {
          var child = rhsChildren[rhsOffset]
          transform(&child, rhsOffset)
          unchangedBuffer.append(child)
          lhsOffset += 1
          rhsOffset += 1
          continue
        }

        if areInIncreasingOrder == nil {
          flushUnchanged()
        }

        switch (isRemoval, isInsertion) {
        case (true, true), (false, false):
          var lhsChild = lhsChildren[lhsOffset]
          var rhsChild = rhsChildren[rhsOffset]
          transform(&lhsChild, isRemoval ? lhsOffset : rhsOffset)
          transform(&rhsChild, rhsOffset)
          print(
            diffHelp(
              lhsChild.value,
              rhsChild.value,
              lhsName: lhsChild.label,
              rhsName: rhsChild.label,
              separator: lhsOffset == lhsChildren.count - 1 && rhsOffset == rhsChildren.count - 1
                ? ""
                : elementSeparator,
              indent: indent + elementIndent,
              isRoot: false
            ),
            to: &out
          )
          lhsOffset += 1
          rhsOffset += 1
          continue

        case (true, false):
          var lhsChild = lhsChildren[lhsOffset]
          transform(&lhsChild, lhsOffset)
          print(
            _customDump(
              lhsChild.value,
              name: lhsChild.label,
              indent: indent + elementIndent,
              isRoot: false,
              maxDepth: .max,
              tracker: &tracker
            )
            .indenting(with: format.first + " "),
            terminator: lhsOffset == lhsChildren.count - 1 ? "\n" : "\(elementSeparator)\n",
            to: &out
          )
          lhsOffset += 1

        case (false, true):
          var rhsChild = rhsChildren[rhsOffset]
          transform(&rhsChild, rhsOffset)
          print(
            _customDump(
              rhsChild.value,
              name: rhsChild.label,
              indent: indent + elementIndent,
              isRoot: false,
              maxDepth: .max,
              tracker: &tracker
            )
            .indenting(with: format.second + " "),
            terminator: rhsOffset == rhsChildren.count - 1 && unchangedBuffer.isEmpty
              ? "\n"
              : "\(elementSeparator)\n",
            to: &out
          )
          rhsOffset += 1
        }
      }

      flushUnchanged()

      print(
        suffix
          .indenting(by: indent)
          .indenting(with: format.both + " "),
        terminator: separator,
        to: &out
      )
    }

    switch (lhs, lhsMirror.displayStyle, rhs, rhsMirror.displayStyle) {
    case (is CustomDumpStringConvertible, _, is CustomDumpStringConvertible, _):
      diffEverything()

    case let (lhs as _CustomDiffObject, _, rhs as _CustomDiffObject, _):
      let lhsItem = lhs._objectIdentifier
      let rhsItem = rhs._objectIdentifier
      if lhsItem == rhsItem {
        let (lhs, rhs) = lhs._customDiffValues
        let subjectType = typeName(type(of: lhs))
        var occurrence = tracker.occurrencePerType[subjectType, default: 1] {
          didSet { tracker.occurrencePerType[subjectType] = occurrence }
        }
        var id: UInt {
          let id = tracker.idPerItem[lhsItem, default: occurrence]
          tracker.idPerItem[lhsItem] = id
          return id
        }
        if tracker.visitedItems.contains(lhsItem) {
          print(
            "\(lhsName.map { "\($0): " } ?? "")#\(id) \(subjectType)(↩︎)\(separator)"
              .indenting(by: indent)
              .indenting(with: format.first + " "),
            to: &out
          )
          print(
            "\(rhsName.map { "\($0): " } ?? "")#\(id) \(subjectType)(↩︎)\(separator)"
              .indenting(by: indent)
              .indenting(with: format.second + " "),
            terminator: "",
            to: &out
          )
        } else {
          diffChildren(
            lhs: lhs,
            rhs: rhs,
            Mirror(customDumpReflecting: lhs),
            Mirror(customDumpReflecting: rhs),
            lhsName: "\(lhsName.map { "\($0): " } ?? "")#\(id)",
            rhsName: "\(rhsName.map { "\($0): " } ?? "")#\(id)",
            nameSuffix: "",
            prefix: "\(subjectType)(",
            suffix: ")",
            elementIndent: 2,
            elementSeparator: ",",
            collapseUnchanged: false,
            filter: macroPropertyFilter(for: lhs)
          )
          tracker.visitedItems.insert(lhsItem)
          occurrence += 1
        }
      } else {
        diffEverything()
      }

    case let (lhs as CustomDumpRepresentable, _, rhs as CustomDumpRepresentable, _):
      out.write(
        diffHelp(
          lhs.customDumpValue,
          rhs.customDumpValue,
          lhsName: lhsName,
          rhsName: rhsName,
          separator: separator,
          indent: indent,
          isRoot: isRoot
        )
      )

    case let (lhs as AnyObject, .class?, rhs as AnyObject, .class?):
      let lhsItem = ObjectIdentifier(lhs)
      let rhsItem = ObjectIdentifier(rhs)
      let subjectType = typeName(lhsMirror.subjectType)
      if !tracker.visitedItems.contains(lhsItem) && !tracker.visitedItems.contains(rhsItem) {
        if lhsItem == rhsItem {
          diffChildren(
            lhsMirror,
            rhsMirror,
            prefix: "\(subjectType)(",
            suffix: ")",
            elementIndent: 2,
            elementSeparator: ",",
            collapseUnchanged: false,
            filter: macroPropertyFilter(for: lhs)
          )
        } else {
          diffEverything()
        }
      } else {
        var occurrence: UInt { tracker.occurrencePerType[subjectType, default: 0] }
        if tracker.visitedItems.contains(lhsItem) {
          var lhsID: String {
            let id = tracker.idPerItem[lhsItem, default: occurrence]
            tracker.idPerItem[lhsItem] = id
            return id > 0 ? "#\(id) " : ""
          }
          print(
            "\(lhsName.map { "\($0): " } ?? "")\(lhsID)\(subjectType)(↩︎)"
              .indenting(by: indent)
              .indenting(with: format.first + " "),
            to: &out
          )
        } else {
          print(
            _customDump(
              lhs,
              name: lhsName,
              indent: indent,
              isRoot: isRoot,
              maxDepth: .max,
              tracker: &tracker
            )
            .indenting(with: format.first + " "),
            terminator: "",
            to: &out
          )
        }
        if tracker.visitedItems.contains(rhsItem) {
          var rhsID: String {
            let id = tracker.idPerItem[rhsItem, default: occurrence]
            tracker.idPerItem[rhsItem] = id
            return id > 0 ? "#\(id) " : ""
          }
          print(
            "\(rhsName.map { "\($0): " } ?? "")\(rhsID)\(subjectType)(↩︎)"
              .indenting(by: indent)
              .indenting(with: format.second + " "),
            terminator: "",
            to: &out
          )
        } else {
          print(
            _customDump(
              rhs,
              name: rhsName,
              indent: indent,
              isRoot: isRoot,
              maxDepth: .max,
              tracker: &tracker
            )
            .indenting(with: format.second + " "),
            terminator: "",
            to: &out
          )
        }
      }

    case (_, .collection?, _, .collection?):
      diffChildren(
        lhsMirror,
        rhsMirror,
        prefix: "[",
        suffix: "]",
        elementIndent: 2,
        elementSeparator: ",",
        collapseUnchanged: true,
        areEquivalent: {
          isIdentityEqual($0.value, $1.value) || isMirrorEqual($0.value, $1.value)
        },
        map: { $0.label = "[\($1)]" }
      )

    case (_, .dictionary?, _, .dictionary?):
      diffChildren(
        lhsMirror,
        rhsMirror,
        prefix: "[",
        suffix: "]",
        elementIndent: 2,
        elementSeparator: ",",
        collapseUnchanged: true,
        areEquivalent: {
          guard
            let lhs = $0.value as? (key: AnyHashable, value: Any),
            let rhs = $1.value as? (key: AnyHashable, value: Any)
          else {
            return isMirrorEqual($0.value, $1.value)
          }
          return lhs.key == rhs.key
        },
        areInIncreasingOrder: lhsMirror.subjectType is _UnorderedCollection.Type
          ? {
            let (lhsValue, rhsValue): (Any, Any)
            if let lhs = $0.value as? (key: AnyHashable, value: Any),
              let rhs = $1.value as? (key: AnyHashable, value: Any)
            {
              lhsValue = lhs.key.base
              rhsValue = rhs.key.base
            } else {
              lhsValue = $0.value
              rhsValue = $1.value
            }
            let lhsDump = _customDump(
              lhsValue,
              name: nil,
              indent: 0,
              isRoot: false,
              maxDepth: 1,
              tracker: &tracker
            )
            let rhsDump = _customDump(
              rhsValue,
              name: nil,
              indent: 0,
              isRoot: false,
              maxDepth: 1,
              tracker: &tracker
            )
            return lhsDump < rhsDump
          }
          : nil
      ) { child, _ in
        guard let pair = child.value as? (key: AnyHashable, value: Any) else { return }
        child = (
          _customDump(
            pair.key.base,
            name: nil,
            indent: 0,
            isRoot: false,
            maxDepth: 1,
            tracker: &tracker
          ),
          pair.value
        )
      }

    case (_, .enum?, _, .enum?):
      guard
        let lhsChild = lhsMirror.children.first,
        let rhsChild = rhsMirror.children.first,
        let caseName = lhsChild.label,
        caseName == rhsChild.label
      else {
        diffEverything()
        break
      }
      let lhsChildMirror = Mirror(customDumpReflecting: lhsChild.value)
      let rhsChildMirror = Mirror(customDumpReflecting: rhsChild.value)
      let lhsAssociatedValuesMirror =
        lhsChildMirror.displayStyle == .tuple
        ? lhsChildMirror
        : Mirror(lhs, unlabeledChildren: [lhsChild.value], displayStyle: .tuple)
      let rhsAssociatedValuesMirror =
        rhsChildMirror.displayStyle == .tuple
        ? rhsChildMirror
        : Mirror(rhs, unlabeledChildren: [rhsChild.value], displayStyle: .tuple)

      let subjectType = isRoot ? typeName(lhsMirror.subjectType) : ""
      diffChildren(
        lhsAssociatedValuesMirror,
        rhsAssociatedValuesMirror,
        prefix: "\(subjectType).\(caseName)(",
        suffix: ")",
        elementIndent: 2,
        elementSeparator: ",",
        collapseUnchanged: false,
        map: { child, _ in
          if child.label?.first == "." {
            child.label = nil
          }
        }
      )

    case (_, .optional?, _, .optional?):
      guard
        let lhsValue = lhsMirror.children.first?.value,
        let rhsValue = rhsMirror.children.first?.value
      else {
        diffEverything()
        break
      }

      out.write(
        diffHelp(
          lhsValue,
          rhsValue,
          lhsName: lhsName,
          rhsName: rhsName,
          separator: separator,
          indent: indent,
          isRoot: isRoot
        )
      )

    case (_, .set?, _, .set?):
      diffChildren(
        lhsMirror,
        rhsMirror,
        prefix: "Set([",
        suffix: "])",
        elementIndent: 2,
        elementSeparator: ",",
        collapseUnchanged: true,
        areEquivalent: {
          isIdentityEqual($0.value, $1.value) || isMirrorEqual($0.value, $1.value)
        },
        areInIncreasingOrder: lhsMirror.subjectType is _UnorderedCollection.Type
          ? {
            let lhsDump = _customDump(
              $0.value,
              name: nil,
              indent: 0,
              isRoot: false,
              maxDepth: 1,
              tracker: &tracker
            )
            let rhsDump = _customDump(
              $1.value,
              name: nil,
              indent: 0,
              isRoot: false,
              maxDepth: 1,
              tracker: &tracker
            )
            return lhsDump < rhsDump
          }
          : nil
      )

    case (_, .struct?, _, .struct?):
      diffChildren(
        lhsMirror,
        rhsMirror,
        prefix: "\(typeName(lhsMirror.subjectType))(",
        suffix: ")",
        elementIndent: 2,
        elementSeparator: ",",
        collapseUnchanged: false,
        filter: macroPropertyFilter(for: lhs)
      )

    case (_, .tuple?, _, .tuple?):
      diffChildren(
        lhsMirror,
        rhsMirror,
        prefix: "(",
        suffix: ")",
        elementIndent: 2,
        elementSeparator: ",",
        collapseUnchanged: false,
        map: { child, _ in
          if child.label?.first == "." {
            child.label = nil
          }
        }
      )

    default:
      if let lhs = String(stringProtocol: lhs),
        let rhs = String(stringProtocol: rhs),
        lhs.contains(where: \.isNewline) || rhs.contains(where: \.isNewline)
      {
        let lhsMirror = Mirror(
          customDumpReflecting:
            lhs.isEmpty
            ? []
            : lhs
              .split(separator: "\n", omittingEmptySubsequences: false)
              .map(Line.init(rawValue:))
        )
        let rhsMirror = Mirror(
          customDumpReflecting:
            rhs.isEmpty
            ? []
            : rhs
              .split(separator: "\n", omittingEmptySubsequences: false)
              .map(Line.init(rawValue:))
        )
        let hashes = String(
          repeating: "#",
          count: max(lhs.hashCount(isMultiline: true), rhs.hashCount(isMultiline: true))
        )
        diffChildren(
          lhsMirror,
          rhsMirror,
          prefix: "\(hashes)\"\"\"",
          suffix: rhsName != nil ? "  \"\"\"\(hashes)" : "\"\"\"\(hashes)",
          elementIndent: rhsName != nil ? 2 : 0,
          elementSeparator: "",
          collapseUnchanged: false,
          areEquivalent: {
            isIdentityEqual($0.value, $1.value) || isMirrorEqual($0.value, $1.value)
          }
        )
      } else {
        diffEverything()
      }
    }

    return out
  }

  guard !isMirrorEqual(lhs, rhs) else { return nil }

  var diff = diffHelp(lhs, rhs, lhsName: nil, rhsName: nil, separator: "", indent: 0, isRoot: true)
  if diff.last == "\n" { diff.removeLast() }
  return diff
}

/// Describes how to format a difference between two values when using ``diff(_:_:format:)``.
///
/// Typically one simply wants to use "-" to denote removals, "+" to denote additions, and " " for
/// spacing. However, in some contexts, such as in `XCTest` failures, messages are displayed in a
/// non-monospaced font. In those times the simple "-" and " " characters do not properly line up
/// visually, and so you need to use different characters that visually look similar to "-" and " "
/// but have the proper widths.
///
/// This type comes with two pre-configured formats that you will probably want to use for most
/// situations: ``DiffFormat/default`` and ``DiffFormat/proportional``.
public struct DiffFormat: Sendable {
  /// A string prepended to lines that only appear in the string representation of the first value,
  /// e.g. a "removal."
  public var first: String

  /// A string prepended to lines that only appear in the string representation of the second value,
  /// e.g. an "insertion."
  public var second: String

  /// A string prepended to lines that appear in the string representation of both values, e.g.
  /// something "unchanged."
  public var both: String

  public init(
    first: String,
    second: String,
    both: String
  ) {
    self.first = first
    self.second = second
    self.both = both
  }

  /// The default format for ``diff(_:_:format:)`` output, appropriate for where monospaced fonts
  /// are used, e.g. console output.
  ///
  /// Uses ascii characters for removals (hyphen "-"), insertions (plus "+"), and unchanged (space
  /// " ").
  public static let `default` = Self(first: "-", second: "+", both: " ")

  /// A diff format appropriate for where proportional (non-monospaced) fonts are used, e.g. Xcode's
  /// failure overlays.
  ///
  /// Uses ascii plus ("+") for insertions, unicode minus sign ("−") for removals, and unicode
  /// figure space (" ") for unchanged. These three characters are more likely to render with equal
  /// widths in proportional fonts.
  public static let proportional = Self(first: "\u{2212}", second: "+", both: "\u{2007}")
}

private struct Line: CustomDumpStringConvertible, Identifiable {
  var rawValue: Substring

  var id: Substring {
    self.rawValue
  }

  var customDumpDescription: String {
    .init(self.rawValue)
  }
}

public protocol _CustomDiffObject {
  var _customDiffValues: (Any, Any) { get }
  var _objectIdentifier: ObjectIdentifier { get }
}

extension _CustomDiffObject where Self: AnyObject {
  public var _objectIdentifier: ObjectIdentifier {
    ObjectIdentifier(self)
  }
}
