#if canImport(SwiftUI)
  public import SwiftUI

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
  extension Color: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) {
        switch self {
        case .brown:
          return "Color.brown"
        case .cyan:
          return "Color.cyan"
        case .indigo:
          return "Color.indigo"
        case .mint:
          return "Color.mint"
        case .teal:
          return "Color.teal"
        default:
          break
        }
      }
      if #available(macOS 11, iOS 14, tvOS 14, watchOS 7, *), self == .accentColor {
        return "Color.accentColor"
      }
      switch self {
      case .black:
        return "Color.black"
      case .blue:
        return "Color.blue"
      case .clear:
        return "Color.clear"
      case .gray:
        return "Color.gray"
      case .green:
        return "Color.green"
      case .orange:
        return "Color.orange"
      case .pink:
        return "Color.pink"
      case .primary:
        return "Color.primary"
      case .purple:
        return "Color.purple"
      case .red:
        return "Color.red"
      case .secondary:
        return "Color.secondary"
      case .white:
        return "Color.white"
      case .yellow:
        return "Color.yellow"
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
          Color(
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
      let arguments: [any CVarArg] = Array(Mirror(reflecting: children[2].value).children)
        .compactMap {
          let children = Array(Mirror(reflecting: $0.value).children)
          let value: Any
          let formatter: Formatter?
          // `LocalizedStringKey.FormatArgument` differs depending on OS/platform.
          if children[0].label == "storage" {
            (value, formatter) =
              Array(Mirror(reflecting: children[0].value).children)[0].value as! (Any, Formatter?)
          } else {
            value = children[0].value
            formatter = children[1].value as? Formatter
          }
          return formatter?.string(for: value) ?? value as! any CVarArg
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
  }
#endif
