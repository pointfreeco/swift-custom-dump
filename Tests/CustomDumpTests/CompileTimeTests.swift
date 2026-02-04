import CustomDump

@CustomDump
fileprivate class FilePrivate {
  var count: Int = 0
}

@CustomDump
private class Private {
  var count: Int = 0
}
