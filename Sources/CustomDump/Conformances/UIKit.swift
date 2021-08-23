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
  #endif
#endif
