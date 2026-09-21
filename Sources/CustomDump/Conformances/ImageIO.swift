#if canImport(ImageIO)
  public import ImageIO

  extension CGImagePropertyOrientation: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .up:
        return "CGImagePropertyOrientation.up"
      case .upMirrored:
        return "CGImagePropertyOrientation.upMirrored"
      case .down:
        return "CGImagePropertyOrientation.down"
      case .downMirrored:
        return "CGImagePropertyOrientation.downMirrored"
      case .leftMirrored:
        return "CGImagePropertyOrientation.leftMirrored"
      case .right:
        return "CGImagePropertyOrientation.right"
      case .rightMirrored:
        return "CGImagePropertyOrientation.rightMirrored"
      case .left:
        return "CGImagePropertyOrientation.left"
      }
    }
  }
#endif
