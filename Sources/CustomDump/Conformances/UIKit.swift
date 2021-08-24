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
  #endif
#endif
