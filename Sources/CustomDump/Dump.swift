/// Dumps the given value's contents using its mirror to standard output.
///
/// This function aims to dump the contents of a value into a nicely formatted, tree-like
/// description. It works with any value passed to it, and tries a few things to turn the value into
/// a string:
///
/// 1. If the value conforms to ``CustomDumpStringConvertible``, then the string returned from
///    `customDumpDescription` is used immediately.
/// 2. If the value conforms to ``CustomDumpRepresentable``, then the value it returns from
///    `customDumpValue` is used for the dump instead.
/// 3. If the value conforms to ``CustomDumpReflectable``, the custom mirror returned from
///    `customDumpMirror` is used for the dump instead.
/// 4. Otherwise, the default mirror returned from `Mirror.init(reflecting:)` is used, which will
///    either come from the type's `CustomReflectable` conformance, or from the default mirror
///    representation of the value.
///
/// - Parameters:
///   - value: The value to output to the `target` stream.
///   - name: A label to use when writing the contents of `value`. When `nil` is passed, the label
///     is omitted. The default is `nil`.
///   - indent: The number of spaces to use as an indent for each line of the output. The default is
///     `0`.
///   - maxDepth: The maximum depth to descend when writing the contents of a value that has nested
///     components. The default is `Int.max`.
/// - Returns: The instance passed as `value`.
@discardableResult
public func customDump<T>(
  _ value: T,
  name: String? = nil,
  indent: Int = 0,
  maxDepth: Int = .max
) -> T {
  var target = ""
  let value = customDump(value, to: &target, name: name, indent: indent, maxDepth: maxDepth)
  print(target)
  return value
}

extension String {
  /// Creates a string dumping the given value.
  public init<Subject>(customDumping subject: Subject) {
    var dump = ""
    customDump(subject, to: &dump)
    self = dump
  }
}

struct ObjectTracker {
  var idPerItem: [ObjectIdentifier: UInt] = [:]
  var occurrencePerType: [String: UInt] = [:]
  var visitedItems: Set<ObjectIdentifier> = []
}

/// Dumps the given value's contents using its mirror to the specified output stream.
///
/// - Parameters:
///   - value: The value to output to the `target` stream.
///   - target: The stream to use for writing the contents of `value`.
///   - name: A label to use when writing the contents of `value`. When `nil` is passed, the label
///     is omitted. The default is `nil`.
///   - indent: The number of spaces to use as an indent for each line of the output. The default is
///     `0`.
///   - maxDepth: The maximum depth to descend when writing the contents of a value that has nested
///     components. The default is `Int.max`.
/// - Returns: The instance passed as `value`.
@discardableResult
public func customDump<T, TargetStream>(
  _ value: T,
  to target: inout TargetStream,
  name: String? = nil,
  indent: Int = 0,
  maxDepth: Int = .max
) -> T where TargetStream: TextOutputStream {
  var tracker = ObjectTracker()
  return _customDump(
    value,
    to: &target,
    name: name,
    indent: indent,
    isRoot: true,
    maxDepth: maxDepth,
    tracker: &tracker
  )
}

@discardableResult
func _customDump<T, TargetStream>(
  _ value: T,
  to target: inout TargetStream,
  name: String?,
  nameSuffix: String = ":",
  indent: Int,
  isRoot: Bool,
  maxDepth: Int,
  tracker: inout ObjectTracker
) -> T where TargetStream: TextOutputStream {
  func customDumpHelp<InnerT, InnerTargetStream>(
    _ value: InnerT,
    to target: inout InnerTargetStream,
    name: String?,
    nameSuffix: String,
    indent: Int,
    isRoot: Bool,
    maxDepth: Int
  ) where InnerTargetStream: TextOutputStream {
    if InnerT.self is AnyObject.Type, withUnsafeBytes(of: value, { $0.allSatisfy { $0 == 0 } }) {
      target.write(
        (name.map { "\($0)\(nameSuffix) " } ?? "")
          .appending("(null pointer)")
          .indenting(by: indent)
      )
      return
    }

    let mirror = Mirror(customDumpReflecting: value)
    var out = ""

    func dumpChildren(
      of mirror: Mirror,
      prefix: String,
      suffix: String,
      shouldSort: Bool,
      filter isIncluded: (Mirror.Child) -> Bool = { _ in true },
      by areInIncreasingOrder: (Mirror.Child, Mirror.Child) -> Bool = { _, _ in false },
      map transform: (inout Mirror.Child, Int) -> Void = { _, _ in }
    ) {
      out.write(prefix)
      if !mirror.children.isEmpty {
        if mirror.isSingleValueContainer {
          var childOut = ""
          let child = mirror.children.first!
          customDumpHelp(
            child.value,
            to: &childOut,
            name: child.label,
            nameSuffix: ":",
            indent: 0,
            isRoot: false,
            maxDepth: maxDepth - 1
          )
          if childOut.contains("\n") {
            if maxDepth <= 0 {
              out.write("…")
            } else {
              out.write("\n")
              out.write(childOut.indenting(by: 2))
              out.write("\n")
            }
          } else {
            out.write(childOut)
          }
        } else if maxDepth <= 0 {
          out.write("…")
        } else {
          out.write("\n")
          var children = Array(mirror.children)
          children.removeAll(where: { !isIncluded($0) })
          if shouldSort {
            children.sort(by: areInIncreasingOrder)
          }
          for (offset, var child) in children.enumerated() {
            transform(&child, offset)
            customDumpHelp(
              child.value,
              to: &out,
              name: child.label,
              nameSuffix: ":",
              indent: 2,
              isRoot: false,
              maxDepth: maxDepth - 1
            )
            if offset != children.count - 1 {
              out.write(",")
            }
            out.write("\n")
          }
        }
      }
      out.write(suffix)
    }

    switch (value, mirror.displayStyle) {
    case let (value as Any.Type, _):
      out.write("\(typeName(value)).self")

    case let (value as CustomDumpStringConvertible, _):
      out.write(value.customDumpDescription)

    case let (value as _CustomDiffObject, _):
      let item = value._objectIdentifier
      let (_, value) = value._customDiffValues
      let subjectType = typeName(type(of: value))
      var occurrence = tracker.occurrencePerType[subjectType, default: 1] {
        didSet { tracker.occurrencePerType[subjectType] = occurrence }
      }

      var id: String {
        let id = tracker.idPerItem[item, default: occurrence]
        tracker.idPerItem[item] = id

        return id > 0 ? "#\(id)" : ""
      }
      if !id.isEmpty {
        out.write("\(id) ")
      }
      if tracker.visitedItems.contains(item) {
        out.write("\(subjectType)(↩︎)")
      } else {
        tracker.visitedItems.insert(item)
        occurrence += 1
        customDumpHelp(
          value,
          to: &out,
          name: nil,
          nameSuffix: "",
          indent: 0,
          isRoot: false,
          maxDepth: maxDepth
        )
      }

    case let (value as CustomDumpRepresentable, _):
      customDumpHelp(
        value.customDumpValue,
        to: &out,
        name: nil,
        nameSuffix: "",
        indent: 0,
        isRoot: false,
        maxDepth: maxDepth
      )

    case let (value as AnyObject, .class?):
      let item = ObjectIdentifier(value)
      var occurrence = tracker.occurrencePerType[typeName(mirror.subjectType), default: 0] {
        didSet { tracker.occurrencePerType[typeName(mirror.subjectType)] = occurrence }
      }

      var id: String {
        let id = tracker.idPerItem[item, default: occurrence]
        tracker.idPerItem[item] = id

        return id > 0 ? "#\(id)" : ""
      }
      if !id.isEmpty {
        out.write("\(id) ")
      }
      if tracker.visitedItems.contains(item) {
        out.write("\(typeName(mirror.subjectType))(↩︎)")
      } else {
        tracker.visitedItems.insert(item)
        occurrence += 1
        var children = Array(mirror.children)

        var superclassMirror = mirror.superclassMirror
        while let mirror = superclassMirror {
          children.insert(contentsOf: mirror.children, at: 0)
          superclassMirror = mirror.superclassMirror
        }
        dumpChildren(
          of: Mirror(value, children: children),
          prefix: "\(typeName(mirror.subjectType))(",
          suffix: ")",
          shouldSort: false,
          filter: macroPropertyFilter(for: value)
        )
      }

    case (_, .collection?):
      dumpChildren(
        of: mirror,
        prefix: "[",
        suffix: "]",
        shouldSort: false,
        map: {
          $0.label = "[\($1)]"
        }
      )

    case (_, .dictionary?):
      if mirror.children.isEmpty {
        out.write("[:]")
      } else {
        dumpChildren(
          of: mirror,
          prefix: "[", suffix: "]",
          shouldSort: mirror.subjectType is _UnorderedCollection.Type,
          by: {
            guard
              let (lhsKey, _) = $0.value as? (key: AnyHashable, value: Any),
              let (rhsKey, _) = $1.value as? (key: AnyHashable, value: Any)
            else { return false }

            let lhsDump = _customDump(
              lhsKey.base,
              name: nil,
              indent: 0,
              isRoot: false,
              maxDepth: 1,
              tracker: &tracker
            )
            let rhsDump = _customDump(
              rhsKey.base,
              name: nil,
              indent: 0,
              isRoot: false,
              maxDepth: 1,
              tracker: &tracker
            )
            return lhsDump < rhsDump
          },
          map: { child, _ in
            guard let pair = child.value as? (key: AnyHashable, value: Any) else { return }
            let key = _customDump(
              pair.key.base,
              name: nil,
              indent: 0,
              isRoot: false,
              maxDepth: maxDepth - 1,
              tracker: &tracker
            )
            child = (key, pair.value)
          }
        )
      }

    case (_, .enum?):
      out.write(isRoot ? "\(typeName(mirror.subjectType))." : ".")
      if let child = mirror.children.first {
        let childMirror = Mirror(customDumpReflecting: child.value)
        let associatedValuesMirror =
          childMirror.displayStyle == .tuple
          ? childMirror
          : Mirror(value, unlabeledChildren: [child.value], displayStyle: .tuple)
        dumpChildren(
          of: associatedValuesMirror,
          prefix: "\(child.label ?? "@unknown")(",
          suffix: ")",
          shouldSort: false,
          map: { child, _ in
            if child.label?.first == "." {
              child.label = nil
            }
          }
        )
      } else {
        out.write("\(value)")
      }

    case (_, .optional?):
      if let value = mirror.children.first?.value {
        customDumpHelp(
          value,
          to: &out,
          name: nil,
          nameSuffix: "",
          indent: 0,
          isRoot: false,
          maxDepth: maxDepth
        )
      } else {
        out.write("nil")
      }

    case (_, .set?):
      dumpChildren(
        of: mirror,
        prefix: "Set([", suffix: "])",
        shouldSort: mirror.subjectType is _UnorderedCollection.Type,
        by: {
          let lhs = _customDump(
            $0.value,
            name: nil,
            indent: 0,
            isRoot: false,
            maxDepth: 1,
            tracker: &tracker
          )
          let rhs = _customDump(
            $1.value,
            name: nil,
            indent: 0,
            isRoot: false,
            maxDepth: 1,
            tracker: &tracker
          )
          return lhs < rhs
        }
      )

    case (_, .struct?):
      dumpChildren(
        of: mirror,
        prefix: "\(typeName(mirror.subjectType))(",
        suffix: ")",
        shouldSort: false,
        filter: macroPropertyFilter(for: value)
      )

    case (_, .tuple?):
      dumpChildren(
        of: mirror,
        prefix: "(",
        suffix: ")",
        shouldSort: false,
        map: { child, _ in
          if child.label?.first == "." {
            child.label = nil
          }
        }
      )

    default:
      if let value = String(stringProtocol: value) {
        if value.contains(where: \.isNewline) {
          if maxDepth <= 0 {
            out.write("\"…\"")
          } else {
            let hashes = String(repeating: "#", count: value.hashCount(isMultiline: true))
            out.write("\(hashes)\"\"\"")
            out.write("\n")
            print(value.indenting(by: name != nil ? 2 : 0), to: &out)
            out.write(name != nil ? "  \"\"\"\(hashes)" : "\"\"\"\(hashes)")
          }
        } else if value.contains("\"") || value.contains("\\") {
          let hashes = String(repeating: "#", count: max(value.hashCount(isMultiline: false), 1))
          out.write("\(hashes)\"\(value)\"\(hashes)")
        } else {
          out.write(value.debugDescription)
        }
      } else {
        out.write("\(value)")
      }
    }

    target.write((name.map { "\($0)\(nameSuffix) " } ?? "").appending(out).indenting(by: indent))
  }

  customDumpHelp(
    value,
    to: &target,
    name: name,
    nameSuffix: nameSuffix,
    indent: indent,
    isRoot: isRoot,
    maxDepth: maxDepth
  )
  return value
}

func _customDump(
  _ value: Any,
  name: String?,
  nameSuffix: String = ":",
  indent: Int,
  isRoot: Bool,
  maxDepth: Int,
  tracker: inout ObjectTracker
) -> String {
  var out = ""
  var t = tracker
  defer { tracker = t }
  _customDump(
    value,
    to: &out,
    name: name,
    nameSuffix: nameSuffix,
    indent: indent,
    isRoot: isRoot,
    maxDepth: maxDepth,
    tracker: &t
  )
  return out
}

func macroPropertyFilter(for value: Any) -> (Mirror.Child) -> Bool {
  value is CustomDumpReflectable
    ? { _ in true }
    : { $0.label.map { !$0.hasPrefix("_$") } ?? true }
}
