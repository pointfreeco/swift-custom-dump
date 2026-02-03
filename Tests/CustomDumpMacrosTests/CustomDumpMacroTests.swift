import CustomDump
import CustomDumpMacros
import MacroTesting
import Testing

@Suite(
  .macros(
    [CustomDumpMacro.self],
    record: .failed
  )
)
struct CustomDumpMacroTests {
  @Test func basics() {
    assertMacro {
      """
      @CustomDump
      final class FeatureModel {
        var count: Int
        var title: String
        var onChange: (Int) -> Void
        @CustomDumpIgnored var ignored: UUID

        init(count: Int, title: String, onChange: @escaping (Int) -> Void, ignored: UUID) {
          self.count = count
          self.title = title
          self.onChange = onChange
          self.ignored = ignored
        }
      }
      """
    } expansion: {
      """
      final class FeatureModel {
        var count: Int
        var title: String
        var onChange: (Int) -> Void
        @CustomDumpIgnored var ignored: UUID

        init(count: Int, title: String, onChange: @escaping (Int) -> Void, ignored: UUID) {
          self.count = count
          self.title = title
          self.onChange = onChange
          self.ignored = ignored
        }

        public struct CustomDumpValue: Equatable {
          public var count: Int
          public var title: String
        }

        public var customDumpValue: CustomDumpValue {
          CustomDumpValue(count: self.count, title: self.title)
        }
      }

      extension FeatureModel: CustomDump.CustomDumpRepresentable {
      }
      """
    }
  }
}
