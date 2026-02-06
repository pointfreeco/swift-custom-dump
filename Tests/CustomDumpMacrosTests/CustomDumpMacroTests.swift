#if os(macOS)
  import CustomDump
  import CustomDumpMacros
  import MacroTesting
  import Testing

  @Suite(
    .macros(
      [CustomDumpMacro.self],
      record: .missing
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
          public var customDumpSubjectType: Any.Type {
            FeatureModel.self
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
          public var customDumpSubjectType: Any.Type {
            FeatureModel.self
          }
        }
        """
      }
    }

    @Test func alreadyConforms() {
      assertMacro {
        """
        @CustomDump
        final class FeatureModel: CustomDumpRepresentable {
          var count: Int

          init(count: Int) {
            self.count = count
          }
        }
        """
      } expansion: {
        """
        final class FeatureModel: CustomDumpRepresentable {
          var count: Int

          init(count: Int) {
            self.count = count
          }
        }

        extension FeatureModel {
          public struct CustomDumpValue: Equatable {
            public var count: Int
          }
          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }
          public var customDumpSubjectType: Any.Type {
            FeatureModel.self
          }
        }
        """
      }
    }

    @Test func alreadyConformsMainActor() {
      assertMacro {
        """
        @CustomDump
        @MainActor
        final class FeatureModel: @MainActor CustomDumpRepresentable {
          var count: Int

          init(count: Int) {
            self.count = count
          }
        }
        """
      } expansion: {
        """
        @MainActor
        final class FeatureModel: @MainActor CustomDumpRepresentable {
          var count: Int

          init(count: Int) {
            self.count = count
          }
        }

        extension FeatureModel {
          public struct CustomDumpValue: Equatable {
            public var count: Int
          }
          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }
          public var customDumpSubjectType: Any.Type {
            FeatureModel.self
          }
        }
        """
      }
    }

    @Test func emptyClass() {
      assertMacro {
        """
        @CustomDump
        final class EmptyModel {
          init() {}
        }
        """
      } expansion: {
        """
        final class EmptyModel {
          init() {}
        }

        extension EmptyModel: CustomDump.CustomDumpRepresentable {
          public struct CustomDumpValue: Equatable {

          }
          public var customDumpValue: CustomDumpValue {
            CustomDumpValue()
          }
          public var customDumpSubjectType: Any.Type {
            EmptyModel.self
          }
        }
        """
      }
    }

    @Test func defaultLiteral() {
      assertMacro {
        """
        @CustomDump
        final class FeatureModel {
          var count = 0
        }
        """
      } expansion: {
        """
        final class FeatureModel {
          var count = 0
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
          public struct CustomDumpValue: Equatable {
            public var count = 0
          }
          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }
          public var customDumpSubjectType: Any.Type {
            FeatureModel.self
          }
        }
        """
      }
    }

    @Test func customDumpProperty() {
      assertMacro {
        """
        @CustomDump
        final class FeatureModel {
          @CustomDump var child: Child
          var count: Int

          init(child: Child, count: Int) {
            self.child = child
            self.count = count
          }
        }
        """
      } expansion: {
        """
        final class FeatureModel {
          var child: Child
          var count: Int

          init(child: Child, count: Int) {
            self.child = child
            self.count = count
          }
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
          public struct CustomDumpValue: Equatable {
            public var child: Child.CustomDumpValue
            public var count: Int
          }
          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(child: self.child.customDumpValue, count: self.count)
          }
          public var customDumpSubjectType: Any.Type {
            FeatureModel.self
          }
        }
        """
      }
    }

    @Test func customDumpValueInheritsHashableAndSendable() {
      assertMacro {
        """
        @CustomDump
        final class FeatureModel: Hashable, Sendable {
          var count: Int

          init(count: Int) {
            self.count = count
          }
        }
        """
      } expansion: {
        """
        final class FeatureModel: Hashable, Sendable {
          var count: Int

          init(count: Int) {
            self.count = count
          }
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
          public struct CustomDumpValue: Equatable, Hashable, Sendable {
            public var count: Int
          }
          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }
          public var customDumpSubjectType: Any.Type {
            FeatureModel.self
          }
        }
        """
      }
    }

    @Test func customDumpValueInheritsSendableOnly() {
      assertMacro {
        """
        @CustomDump
        struct FeatureModel: Sendable {
          var count: Int
        }
        """
      } expansion: {
        """
        struct FeatureModel: Sendable {
          var count: Int
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
          public struct CustomDumpValue: Equatable, Sendable {
            public var count: Int
          }
          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }
          public var customDumpSubjectType: Any.Type {
            FeatureModel.self
          }
        }
        """
      }
    }

    @Test func customDumpValueInheritsIdentifiableWhenIDIncluded() {
      assertMacro {
        """
        @CustomDump
        struct FeatureModel: Identifiable {
          var id: UUID
          var count: Int
        }
        """
      } expansion: {
        """
        struct FeatureModel: Identifiable {
          var id: UUID
          var count: Int
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
          public struct CustomDumpValue: Equatable, Identifiable {
            public var id: UUID
            public var count: Int
          }
          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(id: self.id, count: self.count)
          }
          public var customDumpSubjectType: Any.Type {
            FeatureModel.self
          }
        }
        """
      }
    }

    @Test func customDumpValueDoesNotInheritIdentifiableWhenIDExcluded() {
      assertMacro {
        """
        @CustomDump
        struct FeatureModel: Identifiable {
          @CustomDumpIgnored var id: UUID
          var count: Int
        }
        """
      } expansion: {
        """
        struct FeatureModel: Identifiable {
          @CustomDumpIgnored var id: UUID
          var count: Int
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
          public struct CustomDumpValue: Equatable {
            public var count: Int
          }
          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }
          public var customDumpSubjectType: Any.Type {
            FeatureModel.self
          }
        }
        """
      }
    }

    @Test func customDumpPropertyInferredTypeFromInitializer() {
      assertMacro {
        """
        @CustomDump
        final class FeatureModel {
          @CustomDump var child = Child()
        }
        """
      } expansion: {
        """
        final class FeatureModel {
          var child = Child()
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
          public struct CustomDumpValue: Equatable {
            public var child = (Child()).customDumpValue
          }
          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(child: self.child.customDumpValue)
          }
          public var customDumpSubjectType: Any.Type {
            FeatureModel.self
          }
        }
        """
      }
    }

    @Test func customDumpPropertyInitializerWithExplicitType() {
      assertMacro {
        """
        @CustomDump
        final class FeatureModel {
          @CustomDump var child: Child = Child()
        }
        """
      } expansion: {
        """
        final class FeatureModel {
          var child: Child = Child()
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
          public struct CustomDumpValue: Equatable {
            public var child: Child.CustomDumpValue = (Child()).customDumpValue
          }
          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(child: self.child.customDumpValue)
          }
          public var customDumpSubjectType: Any.Type {
            FeatureModel.self
          }
        }
        """
      }
    }

    @Test func missingTypeAnnotation() {
      assertMacro {
        """
        @CustomDump
        final class FeatureModel {
          @FetchAll(Reminder.all) var reminders
        }
        """
      } diagnostics: {
        """
        @CustomDump
        final class FeatureModel {
          @FetchAll(Reminder.all) var reminders
                                      ┬────────
                                      ╰─ 🛑 '@CustomDump' requires explicit type annotations for stored properties.
        }
        """
      }
    }
  }
#endif
