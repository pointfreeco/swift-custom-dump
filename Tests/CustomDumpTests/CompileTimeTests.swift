import CustomDump

#if canImport(Observation)
  import Observation
#endif

@CustomDump
private class FilePrivate {
  var count: Int = 0
}

@CustomDump
private class Private {
  var count: Int = 0
}

#if canImport(Observation)
  @CustomDump
  @Observable
  @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
  private class ObservableModel {
    var count: Int = 0
  }
#endif
