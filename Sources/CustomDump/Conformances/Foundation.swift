import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

#if compiler(>=5.5)
  @available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
  extension AttributedString: CustomDumpRepresentable {
    public var customDumpValue: Any {
      NSAttributedString(self).string
    }
  }
#endif

extension Calendar: CustomDumpReflectable {
  public var customDumpMirror: Mirror {
    .init(
      self,
      children: [
        "identifier": self.identifier,
        "locale": self.locale as Any,
        "timeZone": self.timeZone,
        "firstWeekday": self.firstWeekday,
        "minimumDaysInFirstWeek": self.minimumDaysInFirstWeek,
      ],
      displayStyle: .struct
    )
  }
}

extension Data: CustomDumpStringConvertible {
  public var customDumpDescription: String {
    "Data(\(Self.formatter.string(fromByteCount: .init(self.count))))"
  }

  private static let formatter: ByteCountFormatter = {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = .useBytes
    return formatter
  }()
}

extension Date: CustomDumpStringConvertible {
  public var customDumpDescription: String {
    "Date(\(Self.formatter.string(from: self)))"
  }

  private static let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)!
    return formatter
  }()
}

extension Decimal: CustomDumpStringConvertible {
  public var customDumpDescription: String {
    self.description
  }
}

extension Locale: CustomDumpStringConvertible {
  public var customDumpDescription: String {
    "Locale(\(self.identifier))"
  }
}

extension NSAttributedString: CustomDumpRepresentable {
  public var customDumpValue: Any {
    self.string
  }
}

extension NSCalendar: CustomDumpRepresentable {
  public var customDumpValue: Any {
    self as Calendar
  }
}

extension NSData: CustomDumpRepresentable {
  public var customDumpValue: Any {
    self as Data
  }
}

extension NSDate: CustomDumpRepresentable {
  public var customDumpValue: Any {
    self as Date
  }
}

extension NSError: CustomDumpReflectable {
  public var customDumpMirror: Mirror {
    .init(
      self,
      children: [
        "domain": self.domain,
        "code": self.code,
        "userInfo": self.userInfo,
      ],
      displayStyle: .class
    )
  }
}

// NB: `NSException` in unavailable on Linux
#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
  extension NSException: CustomDumpReflectable {
    public var customDumpMirror: Mirror {
      .init(
        self,
        children: [
          "name": self.name,
          "reason": self.reason as Any,
          "userInfo": self.userInfo as Any,
        ],
        displayStyle: .class
      )
    }
  }
#endif

extension NSExceptionName: CustomDumpStringConvertible {
  public var customDumpDescription: String {
    self.rawValue
  }
}

// NB: `NSExpression` in unavailable on Linux
#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
  extension NSExpression: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      self.debugDescription
    }
  }
#endif

extension NSIndexPath: CustomDumpRepresentable {
  public var customDumpValue: Any {
    self as IndexPath
  }
}

extension NSIndexSet: CustomDumpRepresentable {
  public var customDumpValue: Any {
    self as IndexSet
  }
}

extension NSLocale: CustomDumpRepresentable {
  public var customDumpValue: Any {
    self as Locale
  }
}

@available(iOS 10, macOS 10.12, tvOS 10, watchOS 3, *)
extension NSMeasurement: CustomDumpRepresentable {
  public var customDumpValue: Any {
    self as Measurement
  }
}

extension NSNotification: CustomDumpRepresentable {
  public var customDumpValue: Any {
    self as Notification
  }
}

extension NSOrderedSet: CustomDumpReflectable {
  public var customDumpMirror: Mirror {
    .init(
      self,
      unlabeledChildren: self.array,
      displayStyle: .collection
    )
  }
}

extension NSPredicate: CustomDumpStringConvertible {
  public var customDumpDescription: String {
    self.debugDescription
  }
}

extension NSRange: CustomDumpRepresentable {
  public var customDumpValue: Any {
    Range(self) as Any
  }
}

extension NSString: CustomDumpRepresentable {
  public var customDumpValue: Any {
    self as String
  }
}

extension NSTimeZone: CustomDumpRepresentable {
  public var customDumpValue: Any {
    #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
      return self as TimeZone
    #else
      // NB: Cannot cast directly to `TimeZone` on Linux
      return TimeZone(identifier: self.name) as Any
    #endif
  }
}

extension NSURL: CustomDumpRepresentable {
  public var customDumpValue: Any {
    self as URL
  }
}

extension NSURLComponents: CustomDumpRepresentable {
  public var customDumpValue: Any {
    self as URLComponents
  }
}

extension NSURLQueryItem: CustomDumpRepresentable {
  public var customDumpValue: Any {
    self as URLQueryItem
  }
}

extension NSURLRequest: CustomDumpRepresentable {
  public var customDumpValue: Any {
    self as URLRequest
  }
}

extension NSUUID: CustomDumpRepresentable {
  public var customDumpValue: Any {
    self as UUID
  }
}

extension NSValue: CustomDumpStringConvertible {
  public var customDumpDescription: String {
    self.debugDescription
  }
}

extension TimeZone: CustomDumpReflectable {
  public var customDumpMirror: Mirror {
    .init(
      self,
      children: [
        "identifier": self.identifier,
        "abbreviation": self.abbreviation() as Any,
        "secondsFromGMT": self.secondsFromGMT(),
        "isDaylightSavingTime": self.isDaylightSavingTime(),
      ],
      displayStyle: .struct
    )
  }
}

extension URL: CustomDumpStringConvertible {
  public var customDumpDescription: String {
    "URL(\(self.absoluteString))"
  }
}

extension URLRequest.NetworkServiceType: CustomDumpStringConvertible {
  public var customDumpDescription: String {
    switch self {#if canImport(FoundationNetworking)
      case .background:
        return "URLRequest.NetworkServiceType.background"
      case .default:
        return "URLRequest.NetworkServiceType.default"
      case .networkServiceTypeCallSignaling:
        return "URLRequest.NetworkServiceType.networkServiceTypeCallSignaling"
      case .video:
        return "URLRequest.NetworkServiceType.video"
      case .voice:
        return "URLRequest.NetworkServiceType.voice"
      case .voip:
        return "URLRequest.NetworkServiceType.voip"
    #else
      case .avStreaming:
        return "URLRequest.NetworkServiceType.avStreaming"
      case .background:
        return "URLRequest.NetworkServiceType.background"
      case .callSignaling:
        return "URLRequest.NetworkServiceType.callSignaling"
      case .default:
        return "URLRequest.NetworkServiceType.default"
      case .responsiveAV:
        return "URLRequest.NetworkServiceType.responsiveAV"
      case .responsiveData:
        return "URLRequest.NetworkServiceType.responsiveData"
      case .video:
        return "URLRequest.NetworkServiceType.video"
      case .voice:
        return "URLRequest.NetworkServiceType.voice"
      case .voip:
        return "URLRequest.NetworkServiceType.voip"
      @unknown default:
        return "URLRequest.NetworkServiceType.(@unknown default, rawValue: \(self.rawValue))"
    #endif
    }
  }
}

extension UUID: CustomDumpStringConvertible {
  public var customDumpDescription: String {
    "UUID(\(self.uuidString))"
  }
}
