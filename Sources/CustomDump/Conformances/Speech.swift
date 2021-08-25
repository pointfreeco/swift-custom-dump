#if canImport(Speech)
  import Speech

  @available(iOS 10, macOS 10.15, *)
  extension SFSpeechRecognizerAuthorizationStatus: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .authorized:
        return "SFSpeechRecognizerAuthorizationStatus.authorized"
      case .denied:
        return "SFSpeechRecognizerAuthorizationStatus.denied"
      case .notDetermined:
        return "SFSpeechRecognizerAuthorizationStatus.notDetermined"
      case .restricted:
        return "SFSpeechRecognizerAuthorizationStatus.restricted"
      @unknown default:
        return
          "SFSpeechRecognizerAuthorizationStatus.(@unknown default, rawValue: \(self.rawValue))"
      }
    }
  }

  @available(iOS 10, macOS 10.15, *)
  extension SFSpeechRecognitionTaskHint: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .confirmation:
        return "SFSpeechRecognitionTaskHint.confirmation"
      case .dictation:
        return "SFSpeechRecognitionTaskHint.dictation"
      case .search:
        return "SFSpeechRecognitionTaskHint.search"
      case .unspecified:
        return "SFSpeechRecognitionTaskHint.unspecified"
      @unknown default:
        return "SFSpeechRecognitionTaskHint.(@unknown default, rawValue: \(self.rawValue))"
      }
    }
  }

  @available(iOS 10, macOS 10.15, *)
  extension SFSpeechRecognitionTaskState: CustomDumpStringConvertible {
    public var customDumpDescription: String {
      switch self {
      case .canceling:
        return "SFSpeechRecognitionTaskState.canceling"
      case .completed:
        return "SFSpeechRecognitionTaskState.completed"
      case .finishing:
        return "SFSpeechRecognitionTaskState.finishing"
      case .running:
        return "SFSpeechRecognitionTaskState.running"
      case .starting:
        return "SFSpeechRecognitionTaskState.starting"
      @unknown default:
        return "SFSpeechRecognitionTaskState.(@unknown default, rawValue: \(self.rawValue))"
      }
    }
  }
#endif
