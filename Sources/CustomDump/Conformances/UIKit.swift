#if canImport(UIKit)
  import UIKit

  #if !os(watchOS)
    @available(iOS 3.2, macCatalyst 13, tvOS 9, *)
    @available(watchOS, unavailable)
    extension UIGestureRecognizer.State: CustomDumpStringConvertible {
      public var customDumpDescription: String {
        switch self {
        case .began:
          return "UIGestureRecognizer.State.began"
        case .cancelled:
          return "UIGestureRecognizer.State.cancelled"
        case .changed:
          return "UIGestureRecognizer.State.changed"
        case .ended:
          return "UIGestureRecognizer.State.ended"
        case .failed:
          return "UIGestureRecognizer.State.failed"
        case .possible:
          return "UIGestureRecognizer.State.possible"
        @unknown default:
          return "UIGestureRecognizer.State.(@unknown default, rawValue: \(self.rawValue))"
        }
      }
    }

    @available(iOS 11, macCatalyst 13, tvOS 11, *)
    @available(watchOS, unavailable)
    extension UIScrollView.ContentInsetAdjustmentBehavior: CustomDumpStringConvertible {
      public var customDumpDescription: String {
        switch self {
        case .always:
          return "UIScrollView.ContentInsetAdjustmentBehavior.always"
        case .automatic:
          return "UIScrollView.ContentInsetAdjustmentBehavior.automatic"
        case .never:
          return "UIScrollView.ContentInsetAdjustmentBehavior.never"
        case .scrollableAxes:
          return "UIScrollView.ContentInsetAdjustmentBehavior.scrollableAxes"
        @unknown default:
          return
            "UIScrollView.ContentInsetAdjustmentBehavior.(@unknown default, rawValue: \(self.rawValue))"
        }
      }
    }

    @available(iOS 12, macCatalyst 13, tvOS 10, *)
    @available(watchOS, unavailable)
    extension UIUserInterfaceStyle: CustomDumpStringConvertible {
      public var customDumpDescription: String {
        switch self {
        case .dark:
          return "UIUserInterfaceStyle.dark"
        case .light:
          return "UIUserInterfaceStyle.light"
        case .unspecified:
          return "UIUserInterfaceStyle.unspecified"
        @unknown default:
          return "UIUserInterfaceStyle.(@unknown default, rawValue: \(self.rawValue))"
        }
      }
    }

    @available(iOS 2, macCatalyst 13, tvOS 9, *)
    @available(watchOS, unavailable)
    extension UIControl.State: CustomDumpReflectable {
      public var customDumpMirror: Mirror {
        struct Option: CustomDumpStringConvertible {
          var rawValue: UIControl.State

          var customDumpDescription: String {
            switch self.rawValue {
            case .application:
              return "UIControl.State.application"
            case .disabled:
              return "UIControl.State.disabled"
            case .focused:
              return "UIControl.State.focused"
            case .highlighted:
              return "UIControl.State.highlighted"
            case .normal:
              return "UIControl.State.normal"
            case .reserved:
              return "UIControl.State.reserved"
            case .selected:
              return "UIControl.State.selected"
            default:
              return "UIControl.State(rawValue: \(self.rawValue))"
            }
          }
        }

        var options = self
        var children: [Option] = []
        let allCases: [UIControl.State] = [
          .application,
          .disabled,
          .focused,
          .highlighted,
          .normal,
          .reserved,
          .selected,
        ]
        for option in allCases {
          if options.contains(option) {
            children.append(.init(rawValue: option))
            options.subtract(option)
          }
        }
        if !options.isEmpty {
          children.append(.init(rawValue: options))
        }

        return .init(
          self,
          unlabeledChildren: children,
          displayStyle: .set
        )
      }
    }
  #endif
#endif
