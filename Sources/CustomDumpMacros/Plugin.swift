import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct CustomDumpMacrosPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    DebugSnapshotMacro.self,
    DebugSnapshotIgnoredMacro.self,
    DebugSnapshotValueMacro.self,
  ]
}
