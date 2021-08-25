#if canImport(UserNotificationsUI)
  import UserNotificationsUI

  @available(iOS 10, macCatalyst 14, macOS 11, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  extension UNNotificationContentExtensionMediaPlayPauseButtonType: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .default:
        return "UNNotificationContentExtensionMediaPlayPauseButtonType.default"
      case .none:
        return "UNNotificationContentExtensionMediaPlayPauseButtonType.none"
      case .overlay:
        return "UNNotificationContentExtensionMediaPlayPauseButtonType.overlay"
      @unknown default:
        return
          "UNNotificationContentExtensionMediaPlayPauseButtonType.(@unknown default, rawValue: \(self.rawValue))"
      }
    }
  }

  @available(iOS 10, macCatalyst 14, macOS 11, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  extension UNNotificationContentExtensionResponseOption: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .dismiss:
        return "UNNotificationContentExtensionResponseOption.dismiss"
      case .dismissAndForwardAction:
        return "UNNotificationContentExtensionResponseOption.dismissAndForwardAction"
      case .doNotDismiss:
        return "UNNotificationContentExtensionResponseOption.doNotDismiss"
      @unknown default:
        return
          "UNNotificationContentExtensionResponseOption.(@unknown default, rawValue: \(self.rawValue))"
      }
    }
  }
#endif
