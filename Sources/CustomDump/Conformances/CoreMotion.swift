#if canImport(CoreMotion)
  import CoreMotion

  @available(iOS 11, watchOS 4, *)
  extension CMAuthorizationStatus: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .authorized:
        return "CMAuthorizationStatus.authorized"
      case .denied:
        return "CMAuthorizationStatus.denied"
      case .notDetermined:
        return "CMAuthorizationStatus.notDetermined"
      case .restricted:
        return "CMAuthorizationStatus.restricted"
      @unknown default:
        return "CMAuthorizationStatus.(@unknown default, rawValue: \(self.rawValue))"
      }
    }
  }

  #if compiler(>=5.4)
    extension CMDeviceMotion.SensorLocation: CustomDumpStringConvertible {
      public var customDumpDescription: String {
        switch self {
        case .default:
          return "CMDeviceMotion.SensorLocation.default"
        case .headphoneLeft:
          return "CMDeviceMotion.SensorLocation.headphoneLeft"
        case .headphoneRight:
          return "CMDeviceMotion.SensorLocation.headphoneRight"
        @unknown default:
          return "CMDeviceMotion.SensorLocation.(@unknown default, rawValue: \(self.rawValue))"
        }
      }
    }
  #endif

  #if compiler(>=5.5)
    @available(iOS, unavailable)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS 7.2, *)
    extension CMFallDetectionEvent.UserResolution: CustomDumpStringConvertible {
      public var customDumpDescription: String {
        switch self {
        case .confirmed:
          return "CMFallDetectionEvent.UserResolution.confirmed"
        case .dismissed:
          return "CMFallDetectionEvent.UserResolution.dismissed"
        case .rejected:
          return "CMFallDetectionEvent.UserResolution.rejected"
        case .unresponsive:
          return "CMFallDetectionEvent.UserResolution.unresponsive"
        @unknown default:
          return
            "CMFallDetectionEvent.UserResolution.(@unknown default, rawValue: \(self.rawValue))"
        }
      }
    }
  #endif

  extension CMMotionActivityConfidence: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .high:
        return "CMMotionActivityConfidence.high"
      case .low:
        return "CMMotionActivityConfidence.low"
      case .medium:
        return "CMMotionActivityConfidence.medium"
      @unknown default:
        return "CMMotionActivityConfidence.(@unknown default, rawValue: \(self.rawValue))"
      }
    }
  }

  @available(iOS 10, watchOS 3, *)
  extension CMPedometerEventType: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .pause:
        return "CMPedometerEventType.pause"
      case .resume:
        return "CMPedometerEventType.resume"
      @unknown default:
        return "CMPedometerEventType.(@unknown default, rawValue: \(self.rawValue))"
      }
    }
  }
#endif
