#if os(macOS)
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
          private var count: Int
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
          private var count: Int
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

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
          public struct CustomDumpValue: Equatable {
            public var title: String
          }

          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(title: self.title)
          }
        }
        """
      }
    }

    @Test func mainActor() {
      assertMacro {
        """
        @MainActor
        @CustomDump
        final class FeatureModel {
          var count: Int

          init(count: Int) {
            self.count = count
          }
        }
        """
      } expansion: {
        """
        @MainActor
        final class FeatureModel {
          var count: Int

          init(count: Int) {
            self.count = count
          }
        }

        extension FeatureModel: @MainActor CustomDump.CustomDumpRepresentable {
          public struct CustomDumpValue: Equatable {
            public var count: Int
          }

          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }
        }
        """
      }
    }
  }
#endif
