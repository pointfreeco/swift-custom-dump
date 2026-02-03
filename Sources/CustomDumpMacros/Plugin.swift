import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct CustomDumpMacrosPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    CustomDumpMacro.self,
    CustomDumpIgnoredMacro.self,
  ]
}
