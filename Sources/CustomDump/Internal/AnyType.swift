func typeName(_ type: Any.Type) -> String {
  var name = String(reflecting: type)
  if let index = name.firstIndex(of: ".") {
    name.removeSubrange(...index)
  }
  return
    name
    .replacingOccurrences(
      of: #"<.+>|\(unknown context at \$[[:xdigit:]]+\)\."#,
      with: "",
      options: .regularExpression
    )
}
