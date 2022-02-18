#if canImport(CoreImage)
  import CoreImage

  @available(watchOS, unavailable)
  extension CIQRCodeDescriptor.ErrorCorrectionLevel: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .levelL:
        return "CIQRCodeDescriptor.ErrorCorrectionLevel.levelL"
      case .levelM:
        return "CIQRCodeDescriptor.ErrorCorrectionLevel.levelM"
      case .levelQ:
        return "CIQRCodeDescriptor.ErrorCorrectionLevel.levelQ"
      case .levelH:
        return "CIQRCodeDescriptor.ErrorCorrectionLevel.levelH"
      @unknown default:
        return
          "CIQRCodeDescriptor.ErrorCorrectionLevel.(@unknown default, rawValue: \(self.rawValue))"
      }
    }
  }

  extension CIDataMatrixCodeDescriptor.ECCVersion: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {

      case .v000:
        return "CIDataMatrixCodeDescriptor.ECCVersion.v000"
      case .v050:
        return "CIDataMatrixCodeDescriptor.ECCVersion.v050"
      case .v080:
        return "CIDataMatrixCodeDescriptor.ECCVersion.v080"
      case .v100:
        return "CIDataMatrixCodeDescriptor.ECCVersion.v100"
      case .v140:
        return "CIDataMatrixCodeDescriptor.ECCVersion.v140"
      case .v200:
        return "CIDataMatrixCodeDescriptor.ECCVersion.v200"
      @unknown default:
        return
          "CIDataMatrixCodeDescriptor.ECCVersion.(@unknown default, rawValue: \(self.rawValue))"
      }
    }
  }

  extension CIRenderDestinationAlphaMode: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .none:
        return "CIRenderDestinationAlphaMode.none"
      case .premultiplied:
        return "CIRenderDestinationAlphaMode.premultiplied"
      case .unpremultiplied:
        return "CIRenderDestinationAlphaMode.unpremultiplied"
      @unknown default:
        return "CIRenderDestinationAlphaMode.(@unknown default, rawValue: \(self.rawValue)"
      }
    }
  }

#endif
