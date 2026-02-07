import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public enum CustomDumpMacro: ExtensionMacro, MemberMacro {
  public static func expansion(
    of node: SwiftSyntax.AttributeSyntax,
    providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
    in context: some SwiftSyntaxMacros.MacroExpansionContext
  ) throws -> [SwiftSyntax.DeclSyntax] {
    guard let modelDecl = ModelDecl(declaration: declaration, context: context) else {
      return []
    }

    return memberDeclarations(for: modelDecl, declaration: declaration)
  }

  public static func expansion(
    of node: SwiftSyntax.AttributeSyntax,
    attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
    providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
    conformingTo protocols: [SwiftSyntax.TypeSyntax],
    in context: some SwiftSyntaxMacros.MacroExpansionContext
  ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
    let conformanceIsolation: String
    #if compiler(>=6.2)
      conformanceIsolation = hasMainActorAnnotation(declaration) ? "@MainActor " : ""
    #else
      conformanceIsolation = ""
    #endif
    let conformance =
      hasCustomDumpRepresentableConformance(declaration)
      ? ""
      : ": \(conformanceIsolation)CustomDump.CustomDumpRepresentable"
    return [
      DeclSyntax(
        """
        extension \(type.trimmed)\(raw: conformance) {}
        """
      )
      .cast(ExtensionDeclSyntax.self)
    ]
  }
}

private func memberDeclarations(
  for modelDecl: ModelDecl,
  declaration: some DeclGroupSyntax
) -> [DeclSyntax] {
  let properties = modelDecl.properties
  let declarationAccessModifier = modelDecl.access.extensionMemberModifier
  let customDumpValueConformances = customDumpValueConformances(
    for: declaration,
    properties: properties
  )

  let propertyLines = properties.map { property in
    let customDumpValueSuffix = property.isCustomDumpRepresentable ? ".CustomDumpValue" : ""
    let propertyAccessModifier = property.access.modifier
    switch property.kind {
    case .type(let type):
      return "\(propertyAccessModifier)var \(property.name): \(type)\(customDumpValueSuffix)"
    case .initializer(let defaultValue):
      let defaultValue = rewriteDefaultValue(
        defaultValue,
        modelTypeName: modelDecl.name,
        propertyTypeName: nil
      )
      .trimmedDescription
      if property.isCustomDumpRepresentable {
        return "\(propertyAccessModifier)var \(property.name) = (\(defaultValue)).customDumpValue"
      } else {
        return "\(propertyAccessModifier)var \(property.name) = \(defaultValue)"
      }
    case .pair(let type, initializer: let defaultValue):
      let defaultValue = rewriteDefaultValue(
        defaultValue,
        modelTypeName: modelDecl.name,
        propertyTypeName: type
      )
      .trimmedDescription
      if property.isCustomDumpRepresentable {
        return """
          \(propertyAccessModifier)var \(property.name): \(type)\(customDumpValueSuffix) = \
          (\(defaultValue)).customDumpValue
          """
      } else {
        return "\(propertyAccessModifier)var \(property.name): \(type) = \(defaultValue)"
      }
    }
  }

  let initArguments =
    properties
    .map {
      "\($0.name): self.\($0.name)\($0.isCustomDumpRepresentable ? ".customDumpValue" : "")"
    }
    .joined(separator: ", ")

  let conformancesDescription = customDumpValueConformances.isEmpty
    ? ""
    : ": \(customDumpValueConformances.joined(separator: ", "))"
  let representation =
    DeclSyntax(
      """
      \(raw: declarationAccessModifier)struct CustomDumpValue\(raw: conformancesDescription) {
      \(raw: propertyLines.joined(separator: "\n"))
      }
      """
    )

  let customDumpValue =
    DeclSyntax(
      """
      \(raw: declarationAccessModifier)var customDumpValue: CustomDumpValue {
      CustomDumpValue(\(raw: initArguments))
      }
      """
    )
  let customDumpSubjectType =
    DeclSyntax(
      """
      \(raw: declarationAccessModifier)var customDumpSubjectType: Any.Type {
      Self.self
      }
      """
    )

  return [representation, customDumpValue, customDumpSubjectType]
}

enum CustomDumpValueMacro: PeerMacro {
  public static func expansion(
    of node: SwiftSyntax.AttributeSyntax,
    providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
    in context: some SwiftSyntaxMacros.MacroExpansionContext
  ) throws -> [SwiftSyntax.DeclSyntax] {
    []
  }
}

enum CustomDumpIgnoredMacro: PeerMacro {
  public static func expansion(
    of node: SwiftSyntax.AttributeSyntax,
    providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
    in context: some SwiftSyntaxMacros.MacroExpansionContext
  ) throws -> [SwiftSyntax.DeclSyntax] {
    []
  }
}

private struct ModelDecl {
  struct Property {
    var name: String
    var kind: Kind
    var access: AccessLevel?
    var isCustomDumpRepresentable: Bool

    enum Kind {
      case type(String)
      case initializer(ExprSyntax)
      case pair(type: String, initializer: ExprSyntax)
    }
  }

  var access: AccessLevel?
  var requiredAccess: AccessLevel
  var name: String
  var properties: [Property]

  init?(
    declaration: some DeclGroupSyntax,
    context: some MacroExpansionContext
  ) {
    guard
      let name = declaration.as(ClassDeclSyntax.self)?.name
        ?? declaration.as(StructDeclSyntax.self)?.name
    else {
      context.diagnose(
        Diagnostic(
          node: Syntax(declaration),
          message: MacroExpansionErrorMessage(
            "'@CustomDump' can only be applied to classes and structs."
          )
        )
      )
      return nil
    }

    let effectiveAccess = effectiveAccessLevel(for: declaration, in: context)
    self.access = generatedAccessLevel(for: declaration, effectiveAccess: effectiveAccess)
    self.requiredAccess = effectiveAccess
    self.name = name.text
    self.properties = Self.storedProperties(
      from: declaration,
      context: context,
      requiredAccess: self.requiredAccess
    )
  }

  static func storedProperties(
    from declaration: some DeclGroupSyntax,
    context: some MacroExpansionContext,
    requiredAccess: AccessLevel
  ) -> [ModelDecl.Property] {
    declaration.memberBlock.members.compactMap { member -> [ModelDecl.Property]? in
      guard let varDecl = member.decl.as(VariableDeclSyntax.self)
      else { return nil }
      guard
        modifiers(of: varDecl).contains(where: {
          $0.name.tokenKind == .keyword(.static) || $0.name.tokenKind == .keyword(.class)
        }) != true
      else { return nil }
      let varDeclAccess = accessControl(for: varDecl)
      guard varDeclAccess.effectiveAccessLevel >= requiredAccess
      else { return nil }
      guard !hasCustomDumpIgnored(varDecl)
      else { return nil }
      let isCustomDumpRepresentable = hasCustomDump(varDecl)
      let effectivePropertyAccess =
        varDeclAccess.map { _ in min(varDeclAccess.effectiveAccessLevel, requiredAccess) }

      return varDecl.bindings.compactMap { binding in
        guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
        else { return nil }

        guard isStoredProperty(binding)
        else { return nil }

        let typeAnnotation = binding.typeAnnotation?.type
        let defaultValue = binding.initializer?.value

        switch (typeAnnotation, defaultValue) {
        case (nil, nil):
          let typeAnnotation = TypeAnnotationSyntax(
            colon: .colonToken(trailingTrivia: .space),
            type: TypeSyntax(IdentifierTypeSyntax(name: .identifier("<#Type#>")))
          )
          context.diagnose(
            Diagnostic(
              node: Syntax(binding),
              message: MacroExpansionErrorMessage(
                "'@CustomDump' requires explicit type annotations for stored properties."
              ),
              fixIt: .replaceChild(
                message: MacroExpansionFixItMessage("Insert ': <#Type#>'"),
                parent: binding,
                replacingChildAt: \.typeAnnotation,
                with: typeAnnotation
              )
            )
          )
          return nil
        case (nil, let defaultValue?):
          guard !isClosureInitializer(defaultValue)
          else { return nil }

          return ModelDecl.Property(
            name: identifier,
            kind: .initializer(defaultValue),
            access: effectivePropertyAccess,
            isCustomDumpRepresentable: isCustomDumpRepresentable
          )
        case (let typeAnnotation?, nil):
          guard !isClosureType(typeAnnotation)
          else { return nil }

          return ModelDecl.Property(
            name: identifier,
            kind: .type(typeAnnotation.trimmedDescription),
            access: effectivePropertyAccess,
            isCustomDumpRepresentable: isCustomDumpRepresentable
          )
        case (let typeAnnotation?, let defaultValue?):
          guard !isClosureType(typeAnnotation)
          else { return nil }
          guard !isClosureInitializer(defaultValue) || isCustomDumpRepresentable
          else { return nil }

          return ModelDecl.Property(
            name: identifier,
            kind: .pair(
              type: typeAnnotation.trimmedDescription,
              initializer: defaultValue
            ),
            access: effectivePropertyAccess,
            isCustomDumpRepresentable: isCustomDumpRepresentable
          )
        }
      }
    }
    .flatMap(\.self)
  }
}

private func hasCustomDumpIgnored(_ varDecl: VariableDeclSyntax) -> Bool {
  return attributes(of: varDecl).contains { attribute in
    guard let attribute = attribute.as(AttributeSyntax.self) else { return false }
    let name = attribute.attributeName.trimmedDescription
    return name.split(separator: ".").last == "CustomDumpIgnored"
  }
}

private func hasCustomDump(_ varDecl: VariableDeclSyntax) -> Bool {
  return attributes(of: varDecl).contains { attribute in
    guard let attribute = attribute.as(AttributeSyntax.self) else { return false }
    let name = attribute.attributeName.trimmedDescription
    return name.split(separator: ".").last == "CustomDumpValue"
  }
}

private func isStoredProperty(_ binding: PatternBindingSyntax) -> Bool {
  guard let accessorBlock = binding.accessorBlock else { return true }
  switch accessorBlock.accessors {
  case .accessors(let accessors):
    return !accessors.contains { accessor in
      switch accessor.accessorSpecifier.tokenKind {
      case .keyword(.get), .keyword(.set), .keyword(._modify), .keyword(._read):
        return true
      default:
        return false
      }
    }
  case .getter:
    return false
  }
}

private func isClosureType(_ type: TypeSyntax) -> Bool {
  if type.as(FunctionTypeSyntax.self) != nil {
    return true
  }
  if let type = type.as(OptionalTypeSyntax.self) {
    return isClosureType(type.wrappedType)
  }
  if let type = type.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
    return isClosureType(type.wrappedType)
  }
  if let type = type.as(AttributedTypeSyntax.self) {
    return isClosureType(type.baseType)
  }
  return false
}

private func isClosureInitializer(_ initializer: ExprSyntax) -> Bool {
  initializer.as(ClosureExprSyntax.self) != nil
}

private enum AccessLevel: Int, Comparable {
  case `private`
  case `fileprivate`
  case `internal`
  case `package`
  case `public`

  static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}

private extension AccessLevel {
  var keyword: String {
    switch self {
    case .private:
      return "private"
    case .fileprivate:
      return "fileprivate"
    case .internal:
      return "internal"
    case .package:
      return "package"
    case .public:
      return "public"
    }
  }
}

private extension AccessLevel? {
  var effectiveAccessLevel: AccessLevel {
    self ?? .internal
  }

  var modifier: String {
    self.map { "\($0.keyword) " } ?? ""
  }

  var extensionMemberModifier: String {
    switch self {
    case .private:
      return "fileprivate "
    default:
      return self.modifier
    }
  }
}

private func accessControl(for declaration: some DeclGroupSyntax) -> AccessLevel? {
  accessControl(from: modifiers(of: declaration))
}

private func accessControl(for varDecl: VariableDeclSyntax) -> AccessLevel? {
  accessControl(from: modifiers(of: varDecl))
}

private func accessControl(from modifiers: DeclModifierListSyntax) -> AccessLevel? {
  let accessLevels: [TokenKind] = [
    .keyword(.public),
    .keyword(.open),
    .keyword(.package),
    .keyword(.internal),
    .keyword(.fileprivate),
    .keyword(.private),
  ]
  for modifier in modifiers {
    if accessLevels.contains(modifier.name.tokenKind) {
      switch modifier.name.tokenKind {
      case .keyword(.open), .keyword(.public):
        return .public
      case .keyword(.package):
        return .package
      case .keyword(.internal):
        return .internal
      case .keyword(.fileprivate):
        return .fileprivate
      case .keyword(.private):
        return .private
      default:
        break
      }
    }
  }
  return nil
}

private func effectiveAccessLevel(
  for declaration: some DeclGroupSyntax,
  in context: some MacroExpansionContext
) -> AccessLevel {
  let declarationAccess = accessControl(for: declaration).effectiveAccessLevel
  let enclosingAccess = enclosingAccessLevel(in: context)
  return min(declarationAccess, enclosingAccess)
}

private func generatedAccessLevel(
  for declaration: some DeclGroupSyntax,
  effectiveAccess: AccessLevel
) -> AccessLevel? {
  let declarationAccess = accessControl(for: declaration)
  if declarationAccess != nil {
    return effectiveAccess
  }
  return effectiveAccess < .internal ? effectiveAccess : nil
}

private func enclosingAccessLevel(in context: some MacroExpansionContext) -> AccessLevel {
  var access: AccessLevel = .internal

  for node in context.lexicalContext {
    if let decl = node.as(ClassDeclSyntax.self) {
      access = min(access, accessControl(for: decl).effectiveAccessLevel)
    } else if let decl = node.as(StructDeclSyntax.self) {
      access = min(access, accessControl(for: decl).effectiveAccessLevel)
    } else if let decl = node.as(EnumDeclSyntax.self) {
      access = min(access, accessControl(for: decl).effectiveAccessLevel)
    } else if let decl = node.as(ActorDeclSyntax.self) {
      access = min(access, accessControl(for: decl).effectiveAccessLevel)
    }
  }

  return access
}

private func hasMainActorAnnotation(_ declaration: some DeclGroupSyntax) -> Bool {
  attributes(of: declaration).contains { attribute in
    guard let attribute = attribute.as(AttributeSyntax.self) else { return false }
    let name = attribute.attributeName.trimmedDescription
    return name.split(separator: ".").last == "MainActor"
  }
}

private func hasCustomDumpRepresentableConformance(_ declaration: some DeclGroupSyntax) -> Bool {
  return hasConformance(named: "CustomDumpRepresentable", in: declaration)
}

private func customDumpValueConformances(
  for declaration: some DeclGroupSyntax,
  properties: [ModelDecl.Property]
) -> [String] {
  var conformances: [String] = []
  if let sendableConformance = sendableConformance(in: declaration) {
    conformances.append(sendableConformance)
  }
  if hasConformance(named: "Identifiable", in: declaration),
    properties.contains(where: { $0.name == "id" })
  {
    conformances.append("Identifiable")
  }
  return conformances
}

private func hasConformance(
  named conformanceName: String,
  in declaration: some DeclGroupSyntax
) -> Bool {
  inheritedTypes(in: declaration).contains { inheritedType in
    conformanceBaseName(of: inheritedType.type) == conformanceName
  }
}

private func sendableConformance(in declaration: some DeclGroupSyntax) -> String? {
  for inheritedType in inheritedTypes(in: declaration) {
    guard conformanceBaseName(of: inheritedType.type) == "Sendable" else { continue }
    return hasUncheckedSpecifier(in: inheritedType.type) ? "@unchecked Sendable" : "Sendable"
  }
  return nil
}

private func inheritedTypes(in declaration: some DeclGroupSyntax) -> [InheritedTypeSyntax] {
  guard
    let inheritedTypes =
      declaration.as(ClassDeclSyntax.self)?.inheritanceClause?.inheritedTypes
      ?? declaration.as(StructDeclSyntax.self)?.inheritanceClause?.inheritedTypes
  else { return [] }
  return Array(inheritedTypes)
}

private func conformanceBaseName(of type: TypeSyntax) -> String? {
  if let type = type.as(IdentifierTypeSyntax.self) {
    return type.name.text
  }
  if let type = type.as(MemberTypeSyntax.self) {
    return type.name.text
  }
  if let type = type.as(AttributedTypeSyntax.self) {
    return conformanceBaseName(of: type.baseType)
  }
  return nil
}

private func hasUncheckedSpecifier(in type: TypeSyntax) -> Bool {
  guard let type = type.as(AttributedTypeSyntax.self) else { return false }
  let hasUnchecked =
    type.attributes.contains { attribute in
      guard let attribute = attribute.as(AttributeSyntax.self) else { return false }
      let name = attribute.attributeName.trimmedDescription
      return name.split(separator: ".").last == "unchecked"
    }
  return hasUnchecked || hasUncheckedSpecifier(in: type.baseType)
}

private func modifiers(of declaration: some DeclGroupSyntax) -> DeclModifierListSyntax {
  #if compiler(>=6.0)
    return declaration.modifiers
  #else
    return declaration.modifiers ?? []
  #endif
}

private func attributes(of declaration: some DeclGroupSyntax) -> AttributeListSyntax {
  #if compiler(>=6.0)
    return declaration.attributes
  #else
    return declaration.attributes ?? []
  #endif
}

private func modifiers(of varDecl: VariableDeclSyntax) -> DeclModifierListSyntax {
  #if compiler(>=6.0)
    return varDecl.modifiers
  #else
    return varDecl.modifiers ?? []
  #endif
}

private func attributes(of varDecl: VariableDeclSyntax) -> AttributeListSyntax {
  #if compiler(>=6.0)
    return varDecl.attributes
  #else
    return varDecl.attributes ?? []
  #endif
}

private func rewriteSelf(in expression: ExprSyntax, with typeName: String) -> ExprSyntax {
  SelfRewriter(typeName: typeName).rewrite(expression).cast(ExprSyntax.self)
}

private func rewriteDefaultValue(
  _ expression: ExprSyntax,
  modelTypeName: String,
  propertyTypeName: String?
) -> ExprSyntax {
  let expression = rewriteSelf(in: expression, with: modelTypeName)
  guard let propertyTypeName else { return expression }

  if
    var memberAccess = expression.as(MemberAccessExprSyntax.self),
    memberAccess.base == nil
  {
    memberAccess.base = ExprSyntax(stringLiteral: propertyTypeName)
    return ExprSyntax(memberAccess)
  }

  if
    var functionCall = expression.as(FunctionCallExprSyntax.self),
    var calledExpression = functionCall.calledExpression.as(MemberAccessExprSyntax.self),
    calledExpression.base == nil
  {
    calledExpression.base = ExprSyntax(stringLiteral: propertyTypeName)
    functionCall.calledExpression = ExprSyntax(calledExpression)
    return ExprSyntax(functionCall)
  }

  return expression
}

private final class SelfRewriter: SyntaxRewriter {
  let typeName: String

  init(typeName: String) {
    self.typeName = typeName
  }

  override func visit(_ node: DeclReferenceExprSyntax) -> ExprSyntax {
    guard node.baseName.tokenKind == .keyword(.Self) || node.baseName.text == "Self"
    else { return ExprSyntax(node) }
    var node = node
    node.baseName = .identifier(self.typeName)
    return ExprSyntax(node)
  }

  override func visit(_ node: IdentifierTypeSyntax) -> TypeSyntax {
    guard node.name.tokenKind == .keyword(.Self) || node.name.text == "Self"
    else { return TypeSyntax(node) }
    var node = node
    node.name = .identifier(self.typeName)
    return TypeSyntax(node)
  }
}
