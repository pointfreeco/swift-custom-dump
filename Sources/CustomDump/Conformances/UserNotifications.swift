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
      struct Option: CustomDumpStringConvertible {
        var rawValue: UNAuthorizationOptions

        var customDumpDescription: String {
          switch self.rawValue {
          case .alert:
            return "UNAuthorizationOptions.alert"
          #if os(iOS) || os(watchOS)
            case .announcement:
              return "UNAuthorizationOptions.announcement"
          #endif
          case .badge:
            return "UNAuthorizationOptions.badge"
          case .carPlay:
            return "UNAuthorizationOptions.carPlay"
          case .criticalAlert:
            return "UNAuthorizationOptions.criticalAlert"
          case .providesAppNotificationSettings:
            return "UNAuthorizationOptions.providesAppNotificationSettings"
          case .provisional:
            return "UNAuthorizationOptions.provisional"
          case .sound:
            return "UNAuthorizationOptions.sound"
          default:
            return "UNAuthorizationOptions(rawValue: \(self.rawValue))"
          }
        }
      }

      var options = self
      var children: [Option] = []
      var allCases: [UNAuthorizationOptions] = [
        .alert
      ]
      #if os(iOS) || os(watchOS)
        allCases.append(.announcement)
      #endif
      allCases.append(contentsOf: [
        .badge,
        .carPlay,
        .criticalAlert,
        .providesAppNotificationSettings,
        .provisional,
        .sound,
      ])
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

  // NB: Xcode 13 does not include macOS 12 SDK
  #if compiler(>=5.5) && !os(macOS) && !targetEnvironment(macCatalyst)
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
      struct Option: CustomDumpStringConvertible {
        var rawValue: UNNotificationPresentationOptions
        var customDumpDescription: String {
          if self.rawValue == .alert {
            return "UNNotificationPresentationOptions.alert"
          }
          if self.rawValue == .badge {
            return "UNNotificationPresentationOptions.badge"
          }
          if #available(iOS 14, macOS 11, tvOS 14, watchOS 7, *), self.rawValue == .banner {
            return "UNNotificationPresentationOptions.banner"
          }
          if #available(iOS 14, macOS 11, tvOS 14, watchOS 7, *), self.rawValue == .list {
            return "UNNotificationPresentationOptions.list"
          }
          if self.rawValue == .sound {
            return "UNNotificationPresentationOptions.sound"
          }
          return "UNNotificationPresentationOptions(rawValue: \(self.rawValue))"
        }
      }

      var options = self
      var children: [Option] = []
      var allCases: [UNNotificationPresentationOptions] = [.alert, .badge]
      if #available(iOS 14, macOS 11, tvOS 14, watchOS 7, *) {
        allCases.append(contentsOf: [.banner, .list])
      }
      allCases.append(.sound)
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
