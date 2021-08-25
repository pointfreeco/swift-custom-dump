#if canImport(UserNotifications)
  import UserNotifications

  @available(iOS 10, macOS 10.14, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  extension UNAlertStyle: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .alert:
        return "UNAlertStyle.alert"
      case .banner:
        return "UNAlertStyle.banner"
      case .none:
        return "UNAlertStyle.none"
      @unknown default:
        return "UNAlertStyle.(@unknown default)"
      }
    }
  }

  @available(iOS 10, macOS 10.14, tvOS 10, watchOS 3, *)
  extension UNAuthorizationStatus: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .authorized:
        return "UNAuthorizationStatus.authorized"
      case .denied:
        return "UNAuthorizationStatus.denied"
      case .ephemeral:
        return "UNAuthorizationStatus.ephemeral"
      case .notDetermined:
        return "UNAuthorizationStatus.notDetermined"
      case .provisional:
        return "UNAuthorizationStatus.provisional"
      @unknown default:
        return "UNAuthorizationStatus.(@unknown default)"
      }
    }
  }

  #if compiler(>=5.5)
    @available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
    extension UNNotificationInterruptionLevel: CustomDumpStringConvertible {
      public var customDumpDescription: String {
        switch self {
        case .active:
          return "UNNotificationInterruptionLevel.active"
        case .critical:
          return "UNNotificationInterruptionLevel.critical"
        case .passive:
          return "UNNotificationInterruptionLevel.passive"
        case .timeSensitive:
          return "UNNotificationInterruptionLevel.timeSensitive"
        @unknown default:
          return "UNNotificationInterruptionLevel.(@unknown default)"
        }
      }
    }
  #endif

  @available(iOS 10, macOS 10.14, tvOS 10, watchOS 3, *)
  extension UNNotificationSetting: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .disabled:
        return "UNNotificationSetting.disabled"
      case .enabled:
        return "UNNotificationSetting.enabled"
      case .notSupported:
        return "UNNotificationSetting.notSupported"
      @unknown default:
        return "UNNotificationSetting.(@unknown default)"
      }
    }
  }

  @available(iOS 11, macOS 10.14, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  extension UNShowPreviewsSetting: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .always:
        return "UNShowPreviewsSetting.always"
      case .never:
        return "UNShowPreviewsSetting.never"
      case .whenAuthenticated:
        return "UNShowPreviewsSetting.whenAuthenticated"
      @unknown default:
        return "UNShowPreviewsSetting.(@unknown default)"
      }
    }
  }

@available(iOS 10, macOS 10.14, tvOS 10, watchOS 3, *)
extension UNAuthorizationOptions: CustomDumpStringConvertible {
  private static let allStatics: [String: Self] = [
    "alert": .alert,
    "announcement": .announcement,
    "badge": .badge,
    "carPlay": .carPlay,
    "criticalAlert": .criticalAlert,
    "providesAppNotificationSettings": .providesAppNotificationSettings,
    "provisional": .provisional,
    "sound": .sound
  ]

  public var customDumpDescription: String {

    enum Options: CaseIterable {
      case alert
      case announcement
      case badge
      case carPlay
      case criticalAlert
      case providesAppNotificationSettings
      case provisional
      case sound

      init(option: UNAuthorizationOptions) {
        
      }
    }

    var options = self
    var components: [String] = []

    for (key, `static`) in Self.allStatics {
      if self.contains(`static`) {
        components.append("UNAuthorizationOptions." + key)
        options.subtract(`static`)
      } else {
      }
    }

    if !options.isEmpty {
      components.append("UNAuthorizationOptions(rawValue: \(options.rawValue))")
    }

    return "[\n" + components
      .map { "  " + $0 }
      .joined(separator: ",\n")
    + "]"

//    var children: [Any] = []
//    for (key, `static`) in Self.allStatics where self.contains(`static`) {
//      children.append("." + key)
//    }
//
//    return .init(
//      self,
//      unlabeledChildren: children,
//      displayStyle: .set
//    )
  }
}
#endif
