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

    @available(iOS 8.0, macCatalyst 13.1, *)
    @available(watchOS, unavailable)
    extension UISplitViewController.DisplayMode: CustomDumpStringConvertible {
      public var customDumpDescription: String {
        switch self {
        case .automatic:
          return "UISplitViewController.DisplayMode.automatic"
        case .secondaryOnly:
          return "UISplitViewController.DisplayMode.secondaryOnly"
        case .oneBesideSecondary:
          return "UISplitViewController.DisplayMode.oneBesideSecondary"
        case .oneOverSecondary:
          return "UISplitViewController.DisplayMode.oneOverSecondary"
        case .twoBesideSecondary:
          return "UISplitViewController.DisplayMode.twoBesideSecondary"
        case .twoOverSecondary:
          return "UISplitViewController.DisplayMode.twoOverSecondary"
        case .twoDisplaceSecondary:
          return "UISplitViewController.DisplayMode.twoDisplaceSecondary"
        @unknown default:
          return "UISplitViewController.DisplayMode.(@unknown default, rawValue: \(self.rawValue))"
        }
      }
    }

    @available(iOS 14.5, macCatalyst 14.5, tvOS 14.5, *)
    @available(watchOS, unavailable)
    extension UISplitViewController.DisplayModeButtonVisibility: CustomDumpStringConvertible {
      public var customDumpDescription: String {
        switch self {
        case .automatic:
          return "UISplitViewController.DisplayModeButtonVisibility.automatic"
        case .never:
          return "UISplitViewController.DisplayModeButtonVisibility.never"
        case .always:
          return "UISplitViewController.DisplayModeButtonVisibility.always"
        @unknown default:
          return
            "UISplitViewController.DisplayModeButtonVisibility.(@unknown default, rawValue: \(self.rawValue))"
        }
      }

    }

    @available(iOS 14.0, macCatalyst 14.0, tvOS 14.0, *)
    @available(watchOS, unavailable)
    extension UISplitViewController.SplitBehavior: CustomDumpStringConvertible {
      public var customDumpDescription: String {
        switch self {
        case .automatic:
          return "UISplitViewController.SplitBehavior.automatic"
        case .tile:
          return "UISplitViewController.SplitBehavior.tile"
        case .overlay:
          return "UISplitViewController.SplitBehavior.overlay"
        case .displace:
          return "UISplitViewController.SplitBehavior.displace"
        @unknown default:
          return
            "UISplitViewController.SplitBehavior.(@unknown default, rawValue: \(self.rawValue))"
        }
      }

    }

    @available(iOS 14.0, macCatalyst 14.0, tvOS 14.0, *)
    @available(watchOS, unavailable)
    extension UISplitViewController.Column: CustomDumpStringConvertible {
      public var customDumpDescription: String {
        switch self {
        case .primary:
          return "UISplitViewController.Column.primary"
        case .supplementary:
          return "UISplitViewController.Column.supplementary"
        case .secondary:
          return "UISplitViewController.Column.secondary"
        case .compact:
          return "UISplitViewController.Column.compact"
        case .inspector:
          return "UISplitViewController.Column.inspector"
        @unknown default:
          return "UISplitViewController.Column.(@unknown default, rawValue: \(self.rawValue))"
        }
      }
    }

    @available(iOS 14.0, macCatalyst 14.0, tvOS 14.0, *)
    @available(watchOS, unavailable)
    extension UISplitViewController.Style: CustomDumpStringConvertible {
      public var customDumpDescription: String {
        switch self {
        case .unspecified:
          return "UISplitViewController.Style.unspecified"
        case .doubleColumn:
          return "UISplitViewController.Style.doubleColumn"
        case .tripleColumn:
          return "UISplitViewController.Style.tripleColumn"
        @unknown default:
          return "UISplitViewController.Style.(@unknown default, rawValue: \(self.rawValue))"
        }
      }
    }

    @available(iOS 11.0, macCatalyst 13.1, tvOS 11.0, *)
    @available(watchOS, unavailable)
    extension UISplitViewController.PrimaryEdge: CustomDumpStringConvertible {
      public var customDumpDescription: String {
        switch self {
        case .leading:
          return "UISplitViewController.PrimaryEdge.leading"
        case .trailing:
          return "UISplitViewController.PrimaryEdge.trailing"
        @unknown default:
          return "UISplitViewController.PrimaryEdge.(@unknown default, rawValue: \(self.rawValue))"
        }
      }
    }

    @available(iOS 13.0, macCatalyst 13.1, tvOS 13.0, *)
    @available(watchOS, unavailable)
    extension UISplitViewController.BackgroundStyle: CustomDumpStringConvertible {
      public var customDumpDescription: String {
        switch self {
        case .none:
          return "UISplitViewController.BackgroundStyle.none"
        case .sidebar:
          return "UISplitViewController.BackgroundStyle.sidebar"
        @unknown default:
          return
            "UISplitViewController.BackgroundStyle.(@unknown default, rawValue: \(self.rawValue))"
        }
      }
    }

    #if compiler(>=6.2)  // Check for Xcode 26
      @available(iOS 26.0, macCatalyst 26.0, tvOS 26.0, visionOS 26.0, *)
      @available(watchOS, unavailable)
      extension UISplitViewController.LayoutEnvironment: CustomDumpStringConvertible {
        public var customDumpDescription: String {
          switch self {
          case .none:
            return "UISplitViewController.LayoutEnvironment.none"
          case .expanded:
            return "UISplitViewController.LayoutEnvironment.expanded"
          case .collapsed:
            return "UISplitViewController.LayoutEnvironment.collapsed"
          @unknown default:
            return
              "UISplitViewController.LayoutEnvironment.(@unknown default, rawValue: \(self.rawValue))"
          }
        }
      }
    #endif

  #endif
#endif
