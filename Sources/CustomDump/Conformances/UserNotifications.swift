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
        return "UNAlertStyle.(@unknown default, rawValue: \(self.rawValue))"
      }
    }
  }

  @available(iOS 10, macOS 10.14, tvOS 10, watchOS 3, *)
  extension UNAuthorizationOptions: CustomDumpReflectable {
    public var customDumpMirror: Mirror {
      struct Option: CaseIterable, CustomDumpStringConvertible {
        static var allCases: [Option] = [
          .init(rawValue: 1 << 2), // .alert
          .init(rawValue: 1 << 7), // .announcement
          .init(rawValue: 1 << 0), // .badge
          .init(rawValue: 1 << 3), // .carPlay
          .init(rawValue: 1 << 4), // .criticalAlert
          .init(rawValue: 1 << 5), // .providesAppNotificationSettings
          .init(rawValue: 1 << 6), // .provisional
          .init(rawValue: 1 << 1), // .sound
          .init(rawValue: 1 << 8), // .timeSensitive
        ]

        var rawValue: UInt

        var customDumpDescription: String {
          switch self.rawValue {
          case 1 << 2:
            return "UNAuthorizationOptions.alert"
          case 1 << 7:
            return "UNAuthorizationOptions.announcement"
          case 1 << 0:
            return "UNAuthorizationOptions.badge"
          case 1 << 3:
            return "UNAuthorizationOptions.carPlay"
          case 1 << 4:
            return "UNAuthorizationOptions.criticalAlert"
          case 1 << 5:
            return "UNAuthorizationOptions.providesAppNotificationSettings"
          case 1 << 6:
            return "UNAuthorizationOptions.provisional"
          case 1 << 1:
            return "UNAuthorizationOptions.sound"
          case 1 << 8:
            return "UNAuthorizationOptions.timeSensitive"
          default:
            return "UNAuthorizationOptions(rawValue: \(self.rawValue))"
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
        return "UNAuthorizationStatus.(@unknown default, rawValue: \(self.rawValue))"
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
          return "UNNotificationInterruptionLevel.(@unknown default, rawValue: \(self.rawValue))"
        }
      }
    }
  #endif

  @available(iOS 10, macOS 10.14, tvOS 10, watchOS 3, *)
  extension UNNotificationPresentationOptions: CustomDumpReflectable {
    public var customDumpMirror: Mirror {
      struct Option: CaseIterable, CustomDumpStringConvertible {
        static var allCases: [Option] = [
          .init(rawValue: 1 << 2), // .alert
          .init(rawValue: 1 << 0), // .badge
          .init(rawValue: 1 << 4), // .banner
          .init(rawValue: 1 << 3), // .list
          .init(rawValue: 1 << 1), // .sound
        ]

        var rawValue: UInt

        var customDumpDescription: String {
          switch self.rawValue {
          case 1 << 2:
            return "UNNotificationPresentationOptions.alert"
          case 1 << 0:
            return "UNNotificationPresentationOptions.badge"
          case 1 << 4:
            return "UNNotificationPresentationOptions.banner"
          case 1 << 3:
            return "UNNotificationPresentationOptions.list"
          case 1 << 1:
            return "UNNotificationPresentationOptions.sound"
          default:
            return "UNNotificationPresentationOptions(rawValue: \(self.rawValue))"
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
        return "UNNotificationSetting.(@unknown default, rawValue: \(self.rawValue))"
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
        return "UNShowPreviewsSetting.(@unknown default, rawValue: \(self.rawValue))"
      }
    }
  }
#endif
