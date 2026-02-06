import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct CustomDumpMacro: ExtensionMacro {
  public static func expansion(
    of node: SwiftSyntax.AttributeSyntax,
    attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
    providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
    conformingTo protocols: [SwiftSyntax.TypeSyntax],
    in context: some SwiftSyntaxMacros.MacroExpansionContext
  ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
    guard let modelDecl = ModelDecl(declaration: declaration, context: context) else {
      return []
    }

    let properties = modelDecl.properties
    let customDumpValueConformances = customDumpValueConformances(
      for: declaration,
      properties: properties
    )

    let propertyLines = properties.map { property in
      let customDumpValueSuffix = property.isCustomDumpRepresentable ? ".CustomDumpValue" : ""
      switch property.kind {
      case .type(let type):
        return "public var \(property.name): \(type)\(customDumpValueSuffix)"
      case .initializer(let defaultValue):
        if property.isCustomDumpRepresentable {
          return "public var \(property.name) = (\(defaultValue)).customDumpValue"
        } else {
          return "public var \(property.name) = \(defaultValue)"
        }
      case .pair(let type, initializer: let defaultValue):
        if property.isCustomDumpRepresentable {
          return """
            public var \(property.name): \(type)\(customDumpValueSuffix) = \
            (\(defaultValue)).customDumpValue
            """
        } else {
          return "public var \(property.name): \(type) = \(defaultValue)"
        }
      }
    }

    let initArguments =
      properties
      .map {
        "\($0.name): self.\($0.name)\($0.isCustomDumpRepresentable ? ".customDumpValue" : "")"
      }
      .joined(separator: ", ")

    let representation =
      """
      public struct CustomDumpValue: \(customDumpValueConformances.joined(separator: ", ")) {
      \(propertyLines.joined(separator: "\n"))
      }
      """

    let customDumpValue =
      """
      public var customDumpValue: CustomDumpValue {
      CustomDumpValue(\(initArguments))
      }
      """
    let customDumpSubjectType = """
      public var customDumpSubjectType: Any.Type {
      \(modelDecl.name).self
      }
      """

    let members = [representation, customDumpValue, customDumpSubjectType].joined(separator: "\n")
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
        extension \(type.trimmed)\(raw: conformance) {
        \(raw: members)
        }
        """
      )
      .cast(ExtensionDeclSyntax.self)
    ]
  }
}

extension CustomDumpMacro: PeerMacro {
  public static func expansion(
    of node: SwiftSyntax.AttributeSyntax,
    providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
    in context: some SwiftSyntaxMacros.MacroExpansionContext
  ) throws -> [SwiftSyntax.DeclSyntax] {
    []
  }
}

struct CustomDumpIgnoredMacro: PeerMacro {
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
    var isCustomDumpRepresentable: Bool

    enum Kind {
      case type(String)
      case initializer(String)
      case pair(type: String, initializer: String)
    }
  }

  var access: AccessLevel
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

    self.access = accessLevel(for: declaration)
    self.name = name.text
    self.properties = Self.storedProperties(
      from: declaration,
      context: context,
      requiredAccess: self.access
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
      guard accessLevel(for: varDecl) >= requiredAccess
      else { return nil }
      guard !hasCustomDumpIgnored(varDecl)
      else { return nil }
      let isCustomDumpRepresentable = hasCustomDump(varDecl)

      return varDecl.bindings.compactMap { binding in
        guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
        else { return nil }

        guard isStoredProperty(binding)
        else { return nil }

        let typeAnnotation = binding.typeAnnotation?.type
        let defaultValue = binding.initializer?.value.trimmedDescription

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
            isCustomDumpRepresentable: isCustomDumpRepresentable
          )
        case (let typeAnnotation?, nil):
          guard !isClosureType(typeAnnotation)
          else { return nil }

          return ModelDecl.Property(
            name: identifier,
            kind: .type(typeAnnotation.trimmedDescription),
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
            isCustomDumpRepresentable: isCustomDumpRepresentable
          )
        }
      }
    }
    .flatMap(\.self)
  }
}

private enum DeclKind {
  case `class`

  init?(_ declaration: some DeclGroupSyntax) {
    if declaration.as(ClassDeclSyntax.self) != nil {
      self = .class
    } else {
      return nil
    }
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
    return name.split(separator: ".").last == "CustomDump"
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

private func isClosureInitializer(_ initializer: String) -> Bool {
  initializer.first == "{"
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

private func accessLevel(for declaration: some DeclGroupSyntax) -> AccessLevel {
  accessLevel(from: modifiers(of: declaration))
}

private func accessLevel(for varDecl: VariableDeclSyntax) -> AccessLevel {
  accessLevel(from: modifiers(of: varDecl))
}

private func accessLevel(from modifiers: DeclModifierListSyntax) -> AccessLevel {
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
  return .internal
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
  var conformances = ["Equatable"]
  if hasConformance(named: "Hashable", in: declaration) {
    conformances.append("Hashable")
  }
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
  inheritedTypeDescriptions(in: declaration).contains { inheritedType in
    let lastToken = inheritedType.split(whereSeparator: { $0 == " " || $0 == "\t" }).last
    return lastToken?.split(separator: ".").last == Substring(conformanceName)
  }
}

private func sendableConformance(in declaration: some DeclGroupSyntax) -> String? {
  for inheritedType in inheritedTypeDescriptions(in: declaration) {
    let lastToken = inheritedType.split(whereSeparator: { $0 == " " || $0 == "\t" }).last
    guard lastToken?.split(separator: ".").last == "Sendable" else { continue }
    return inheritedType.contains("@unchecked") ? "@unchecked Sendable" : "Sendable"
  }
  return nil
}

private func inheritedTypeDescriptions(in declaration: some DeclGroupSyntax) -> [String] {
  guard
    let inheritedTypes =
      declaration.as(ClassDeclSyntax.self)?.inheritanceClause?.inheritedTypes
      ?? declaration.as(StructDeclSyntax.self)?.inheritanceClause?.inheritedTypes
  else { return [] }
  return inheritedTypes.map { $0.type.trimmedDescription }
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
