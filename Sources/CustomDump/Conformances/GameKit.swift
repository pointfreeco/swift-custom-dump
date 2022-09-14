#if canImport(GameKit) && compiler(<5.7.1)  // NB: Xcode 14.1 beta can't import GameKit
  import GameKit

  #if !os(watchOS)
    #if compiler(>=5.5)
      @available(iOS 14, macOS 11, macCatalyst 14, tvOS 14, *)
      extension GKAccessPoint.Location: CustomDumpStringConvertible {
        public var customDumpDescription: String {
          switch self {
          case .bottomLeading:
            return "GKAccessPoint.Location.bottomLeading"
          case .bottomTrailing:
            return "GKAccessPoint.Location.bottomTrailing"
          case .topLeading:
            return "GKAccessPoint.Location.topLeading"
          case .topTrailing:
            return "GKAccessPoint.Location.topTrailing"
          @unknown default:
            return "GKAccessPoint.Location.(@unknown default, rawValue: \(self.rawValue))"
          }
        }
      }
    #endif

    @available(iOS 5, macCatalyst 13, macOS 10.8, tvOS 9, *)
    extension GKPlayer.PhotoSize: CustomDumpStringConvertible {
      public var customDumpDescription: String {
        switch self {
        case .normal:
          return "GKPlayer.PhotoSize.normal"
        case .small:
          return "GKPlayer.PhotoSize.small"
        @unknown default:
          return "GKPlayer.PhotoSize.(@unknown default, rawValue: \(self.rawValue))"
        }
      }
    }
  #endif

  @available(iOS 5, macCatalyst 13, macOS 10.8, tvOS 9, watchOS 3, *)
  @available(watchOS, unavailable)
  extension GKTurnBasedMatch.Outcome: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .customRange:
        return "GKTurnBasedMatch.Outcome.customRange"
      case .first:
        return "GKTurnBasedMatch.Outcome.first"
      case .fourth:
        return "GKTurnBasedMatch.Outcome.fourth"
      case .lost:
        return "GKTurnBasedMatch.Outcome.lost"
      case .none:
        return "GKTurnBasedMatch.Outcome.none"
      case .quit:
        return "GKTurnBasedMatch.Outcome.quit"
      case .second:
        return "GKTurnBasedMatch.Outcome.second"
      case .tied:
        return "GKTurnBasedMatch.Outcome.tied"
      case .timeExpired:
        return "GKTurnBasedMatch.Outcome.timeExpired"
      case .third:
        return "GKTurnBasedMatch.Outcome.third"
      case .won:
        return "GKTurnBasedMatch.Outcome.won"
      @unknown default:
        return "GKTurnBasedMatch.Outcome.(@unknown default, rawValue: \(self.rawValue))"
      }
    }
  }

  @available(iOS 5, macCatalyst 13, macOS 10.8, tvOS 9, watchOS 3, *)
  @available(watchOS, unavailable)
  extension GKTurnBasedMatch.Status: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .ended:
        return "GKTurnBasedMatch.Status.ended"
      case .matching:
        return "GKTurnBasedMatch.Status.matching"
      case .open:
        return "GKTurnBasedMatch.Status.open"
      case .unknown:
        return "GKTurnBasedMatch.Status.unknown"
      @unknown default:
        return "GKTurnBasedMatch.Status.(@unknown default, rawValue: \(self.rawValue))"
      }
    }
  }

  @available(iOS 5, macCatalyst 13, macOS 10.8, tvOS 9, watchOS 3, *)
  @available(watchOS, unavailable)
  extension GKTurnBasedParticipant.Status: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .active:
        return "GKTurnBasedParticipant.Status.active"
      case .declined:
        return "GKTurnBasedParticipant.Status.declined"
      case .done:
        return "GKTurnBasedParticipant.Status.done"
      case .invited:
        return "GKTurnBasedParticipant.Status.invited"
      case .matching:
        return "GKTurnBasedParticipant.Status.matching"
      case .unknown:
        return "GKTurnBasedParticipant.Status.unknown"
      @unknown default:
        return "GKTurnBasedParticipant.Status.(@unknown default, rawValue: \(self.rawValue))"
      }
    }
  }
#endif
