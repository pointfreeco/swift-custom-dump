#if canImport(SwiftUI)
  import SwiftUI

  @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
  extension Animation: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .easeIn:
        return "Animation.easeIn"
      case .easeInOut:
        return "Animation.easeInOut"
      case .easeOut:
        return "Animation.easeOut"
      case .interactiveSpring():
        return "Animation.interactiveSpring()"
      case .linear:
        return "Animation.linear"
      case .spring():
        return "Animation.spring()"
      default:
        var tracker = ObjectTracker()
        let base = _customDump(
          Mirror(reflecting: self).children.first?.value as Any,
          name: nil,
          indent: 2,
          isRoot: false,
          maxDepth: .max,
          tracker: &tracker
        )
        return """
          Animation(
          \(base)
          )
          """
      }
    }
  }

  @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
  extension LocalizedStringKey: CustomDumpRepresentable {
    public var customDumpValue: Any {
      self.formatted()
    }

    private func formatted(
      locale: Locale? = nil,
      tableName: String? = nil,
      bundle: Bundle? = nil,
      comment: StaticString? = nil
    ) -> String {
      let children = Array(Mirror(reflecting: self).children)
      let key = children[0].value as! String
      let arguments: [CVarArg] = Array(Mirror(reflecting: children[2].value).children)
        .compactMap {
          let children = Array(Mirror(reflecting: $0.value).children)
          // `LocalizedStringKey.FormatArgument` differs depending on OS/platform.
          if children[0].label == "storage" {
            return formattedArgumentFromStorage(children[0])
          } else {
            let value = children[0].value
            let formatter = children[1].value as? Formatter
            return formatter?.string(for: value) ?? value as! CVarArg
          }
        }

      let format = NSLocalizedString(
        key,
        tableName: tableName,
        bundle: bundle ?? .main,
        value: "",
        comment: comment.map(String.init) ?? ""
      )
      return String(format: format, locale: locale, arguments: arguments)
    }

    private func formattedArgumentFromStorage(_ storage: Mirror.Child) -> CVarArg {
      let storage = Array(Mirror(reflecting: storage.value).children)[0].value

      // Check if storage is a FormatStyle
      if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
        let formatStyleBoxChildren = Array(Mirror(reflecting: storage).children)
        if formatStyleBoxChildren.count == 2, let formatStyle = formatStyleBoxChildren[1].value as? (any FormatStyle) {
          func formatValue<S: FormatStyle>(style: S, input: Any) -> String {
            let input = input as! S.FormatInput
            return style.format(input) as! String
          }
          return formatValue(style: formatStyle, input: formatStyleBoxChildren[0].value)
        }
      }

      // Fallback to Formatter
      let (value, formatter) = storage as! (Any, Formatter?)
      return formatter?.string(for: value) ?? value as! CVarArg
    }
  }
#endif
