#if canImport(Photos)
  import Photos

  @available(iOS 14, macCatalyst 14, macOS 11, tvOS 14, *)
  extension PHAccessLevel: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .addOnly:
        return "PHAccessLevel.addOnly"
      case .readWrite:
        return "PHAccessLevel.readWrite"
      @unknown default:
        return "PHAccessLevel.(@unknown default, rawValue: \(self.rawValue))"
      }
    }
  }

  @available(iOS 8, macCatalyst 13, macOS 10.13, tvOS 10, *)
  extension PHAuthorizationStatus: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .authorized:
        return "PHAuthorizationStatus.authorized"
      case .denied:
        return "PHAuthorizationStatus.denied"
      case .notDetermined:
        return "PHAuthorizationStatus.notDetermined"
      case .restricted:
        return "PHAuthorizationStatus.restricted"
      case .limited:
        return "PHAuthorizationStatus.limited"
      @unknown default:
        return "PHAuthorizationStatus.(@unknown default, rawValue: \(self.rawValue))"
      }
    }
  }

#endif
