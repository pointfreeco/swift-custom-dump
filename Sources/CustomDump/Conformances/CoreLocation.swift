#if canImport(CoreLocation)
  import CoreLocation

  @available(iOS 13.4, macOS 10.15.4, tvOS 13.4, watchOS 6.2, *)
  extension CLLocation: CustomDumpReflectable {
    public var customDumpMirror: Mirror {
      var ellipsoidalAltitude: Any? = nil
      var sourceInformation: Any? = nil

      if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
        ellipsoidalAltitude = self.ellipsoidalAltitude
        sourceInformation = self.sourceInformation
      }

      let children: KeyValuePairs<String, Any?> = [
        "coordinate": coordinate,
        "altitude": altitude,
        "horizontalAccuracy": horizontalAccuracy,
        "verticalAccuracy": verticalAccuracy,
        "course": course,
        "courseAccuracy": courseAccuracy,
        "speed": speed,
        "speedAccuracy": speedAccuracy,
        "timestamp": timestamp,
        "sourceInformation": sourceInformation,
        "ellipsoidalAltitude": ellipsoidalAltitude,
        "floor": floor as Any,
      ]

      return Mirror(
        self,
        children: children.compactMap {
          guard let value = $1 else { return nil }
          return ($0, value)
        },
        displayStyle: .class
      )
    }
  }

  @available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
  extension CLLocationSourceInformation: CustomDumpReflectable {
    public var customDumpMirror: Mirror {
      Mirror(
        self,
        children: [
          "isProducedByAccessory": isProducedByAccessory,
          "isSimulatedBySoftware": isSimulatedBySoftware,
        ],
        displayStyle: .class
      )
    }
  }

  extension CLFloor: CustomDumpReflectable {
    public var customDumpMirror: Mirror {
      Mirror(self, children: ["level": level], displayStyle: .class)
    }
  }

  #if compiler(>=5.4)
    extension CLAccuracyAuthorization: CustomDumpStringConvertible {
      public var customDumpDescription: String {
        switch self {
        case .fullAccuracy:
          return "CLAccuracyAuthorization.fullAccuracy"
        case .reducedAccuracy:
          return "CLAccuracyAuthorization.reducedAccuracy"
        @unknown default:
          return "CLAccuracyAuthorization.(@unknown default, rawValue: \(self.rawValue))"
        }
      }
    }
  #endif

  extension CLActivityType: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .airborne:
        return "CLActivityType.airborne"
      case .automotiveNavigation:
        return "CLActivityType.automotiveNavigation"
      case .other:
        return "CLActivityType.other"
      case .fitness:
        return "CLActivityType.fitness"
      case .otherNavigation:
        return "CLActivityType.otherNavigation"
      @unknown default:
        return "CLActivityType.(@unknown default, rawValue: \(self.rawValue))"
      }
    }
  }

  extension CLAuthorizationStatus: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .authorizedAlways:
        return "CLAuthorizationStatus.authorizedAlways"
      case .authorizedWhenInUse:
        return "CLAuthorizationStatus.authorizedWhenInUse"
      case .denied:
        return "CLAuthorizationStatus.denied"
      case .notDetermined:
        return "CLAuthorizationStatus.notDetermined"
      case .restricted:
        return "CLAuthorizationStatus.restricted"
      @unknown default:
        return "CLAuthorizationStatus.(@unknown default, rawValue: \(self.rawValue))"
      }
    }
  }

  extension CLDeviceOrientation: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .faceUp:
        return "CLDeviceOrientation.faceUp"
      case .faceDown:
        return "CLDeviceOrientation.faceDown"
      case .landscapeLeft:
        return "CLDeviceOrientation.landscapeLeft"
      case .landscapeRight:
        return "CLDeviceOrientation.landscapeRight"
      case .portrait:
        return "CLDeviceOrientation.portrait"
      case .portraitUpsideDown:
        return "CLDeviceOrientation.portraitUpsideDown"
      case .unknown:
        return "CLDeviceOrientation.unknown"
      @unknown default:
        return "CLDeviceOrientation.(@unknown default, rawValue: \(self.rawValue))"
      }
    }
  }

  #if compiler(>=5.9)
    @available(iOS 7, macOS 10.15, *)
    @available(tvOS, unavailable)
    @available(visionOS, unavailable)
    @available(watchOS, unavailable)
    extension CLProximity: CustomDumpStringConvertible {
      public var customDumpDescription: String {
        switch self {
        case .far:
          return "CLProximity.far"
        case .immediate:
          return "CLProximity.immediate"
        case .near:
          return "CLProximity.near"
        case .unknown:
          return "CLProximity.unknown"
        @unknown default:
          return "CLProximity.(@unknown default, rawValue: \(self.rawValue))"
        }
      }
    }
  #elseif compiler(>=5.3)
    @available(iOS 7, macOS 10.15, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    extension CLProximity: CustomDumpStringConvertible {
      public var customDumpDescription: String {
        switch self {
        case .far:
          return "CLProximity.far"
        case .immediate:
          return "CLProximity.immediate"
        case .near:
          return "CLProximity.near"
        case .unknown:
          return "CLProximity.unknown"
        @unknown default:
          return "CLProximity.(@unknown default, rawValue: \(self.rawValue))"
        }
      }
    }
  #endif

  #if compiler(>=5.9)
    @available(iOS 7, macOS 10, *)
    @available(tvOS, unavailable)
    @available(visionOS, unavailable)
    @available(watchOS, unavailable)
    extension CLRegionState: CustomDumpStringConvertible {
      public var customDumpDescription: String {
        switch self {
        case .inside:
          return "CLRegionState.inside"
        case .outside:
          return "CLRegionState.outside"
        case .unknown:
          return "CLRegionState.unknown"
        }
      }
    }
  #else
    @available(iOS 7, macOS 10, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    extension CLRegionState: CustomDumpStringConvertible {
      public var customDumpDescription: String {
        switch self {
        case .inside:
          return "CLRegionState.inside"
        case .outside:
          return "CLRegionState.outside"
        case .unknown:
          return "CLRegionState.unknown"
        }
      }
    }
  #endif
#endif
