func typeName(
  _ type: Any.Type,
  qualified: Bool = true,
  genericsAbbreviated: Bool = true
) -> String {
  var name = _typeName(type, qualified: qualified)
    .replacingOccurrences(
      of: #"\w+\.(\w+)"#,
      with: "$1",
      options: .regularExpression
    )
    .replacingOccurrences(
      of: #"\(unknown context at \$[[:xdigit:]]+\)\."#,
      with: "",
      options: .regularExpression
    )
  if genericsAbbreviated {
    name = name.replacingOccurrences(
      of: #"<.+>"#,
      with: "",
      options: .regularExpression
    )
  }
  return name
}
