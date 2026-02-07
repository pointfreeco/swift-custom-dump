import CustomDump

#if canImport(Observation)
  import Observation
#endif

@DebugSnapshot
private class FilePrivate {
  var count: Int = 0
}

@DebugSnapshot
private class Private {
  var count: Int = 0
}

#if canImport(Observation)
  @DebugSnapshot
  @Observable
  @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
  private class ObservableModel {
    var count: Int = 0
  }
#endif
