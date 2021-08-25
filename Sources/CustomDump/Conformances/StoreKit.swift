#if canImport(StoreKit)
  import StoreKit

  @available(iOS 3, macCatalyst 13, macOS 10.7, tvOS 9, watchOS 6.2, *)
  extension SKPaymentTransactionState: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .purchasing:
        return "SKPaymentTransactionState.purchasing"
      case .purchased:
        return "SKPaymentTransactionState.purchased"
      case .failed:
        return "SKPaymentTransactionState.failed"
      case .restored:
        return "SKPaymentTransactionState.restored"
      case .deferred:
        return "SKPaymentTransactionState.deferred"
      @unknown default:
        return "SKPaymentTransactionState.(@unknown default, rawValue: \(self.rawValue))"
      }
    }
  }

  @available(iOS 11.2, macCatalyst 13, macOS 10.13.2, tvOS 11.2, watchOS 6.2, *)
  extension SKProduct.PeriodUnit: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .day:
        return "SKProduct.PeriodUnit.day"
      case .week:
        return "SKProduct.PeriodUnit.week"
      case .month:
        return "SKProduct.PeriodUnit.month"
      case .year:
        return "SKProduct.PeriodUnit.year"
      @unknown default:
        return "SKProduct.PeriodUnit.(@unknown default, rawValue: \(self.rawValue))"
      }
    }
  }
#endif
