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
          return "UIScrollView.ContentInsetAdjustmentBehavior.(@unknown default, rawValue: \(self.rawValue))"
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
        struct Option: CaseIterable, CustomDumpStringConvertible {
          static var allCases: [Option] = [
            .init(rawValue: 0x00FF0000), // .application
            .init(rawValue: 1 << 1), // .disabled
            .init(rawValue: 1 << 3), // .focused
            .init(rawValue: 1 << 0), // .highlighted
            .init(rawValue: 0), // .normal
            .init(rawValue: 0xFF000000), // .reserved
            .init(rawValue: 1 << 2), // .selected
          ]

          var rawValue: UInt

          var customDumpDescription: String {
            switch self.rawValue {
            case 0x00FF0000:
              return "UIControl.State.application"
            case 1 << 1:
              return "UIControl.State.disabled"
            case 1 << 3:
              return "UIControl.State.focused"
            case 1 << 0:
              return "UIControl.State.highlighted"
            case 0:
              return "UIControl.State.normal"
            case 0xFF000000:
              return "UIControl.State.reserved"
            case 1 << 2:
              return "UIControl.State.selected"
            default:
              return "UIControl.State(rawValue: \(self.rawValue))"
            }
          }
        }

        var options = self
        var children: [Option] = []
        for option in Option.allCases {
          if options.contains(.init(rawValue: option.rawValue)) {
            children.append(option)
            options.subtract(.init(rawValue: option.rawValue))
          }
        }
        if !options.isEmpty {
          children.append(Option(rawValue: options.rawValue))
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
