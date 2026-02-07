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

          public struct CustomDumpValue {
            public var title: String
          }

          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(title: self.title)
          }

          public var customDumpSubjectType: Any.Type {
            Self.self
          }
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
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

          public struct CustomDumpValue {
            public var count: Int
          }

          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }

          public var customDumpSubjectType: Any.Type {
            Self.self
          }
        }

        extension FeatureModel: @MainActor CustomDump.CustomDumpRepresentable {
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

          public struct CustomDumpValue {
            public var count: Int
          }

          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }

          public var customDumpSubjectType: Any.Type {
            Self.self
          }
        }

        extension FeatureModel {
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

          public struct CustomDumpValue {
            public var count: Int
          }

          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }

          public var customDumpSubjectType: Any.Type {
            Self.self
          }
        }

        extension FeatureModel {
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

          public struct CustomDumpValue {

          }

          public var customDumpValue: CustomDumpValue {
            CustomDumpValue()
          }

          public var customDumpSubjectType: Any.Type {
            Self.self
          }
        }

        extension EmptyModel: CustomDump.CustomDumpRepresentable {
        }
        """
      }
    }

    @Test func privateTypeUsesFileprivateMembers() {
      assertMacro {
        """
        @CustomDump
        private final class FeatureModel {
          var count: Int

          init(count: Int) {
            self.count = count
          }
        }
        """
      } expansion: {
        """
        private final class FeatureModel {
          var count: Int

          init(count: Int) {
            self.count = count
          }

          public struct CustomDumpValue {
            public var count: Int
          }

          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }

          public var customDumpSubjectType: Any.Type {
            Self.self
          }
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
        }
        """
      }
    }

    @Test func privateContainerUsesFileprivateMembers() {
      assertMacro {
        """
        private struct Parent {
          @CustomDump
          final class FeatureModel {
            var count: Int

            init(count: Int) {
              self.count = count
            }
          }
        }
        """
      } expansion: {
        """
        private struct Parent {
          final class FeatureModel {
            var count: Int

            init(count: Int) {
              self.count = count
            }

            public struct CustomDumpValue {
              public var count: Int
            }

            public var customDumpValue: CustomDumpValue {
              CustomDumpValue(count: self.count)
            }

            public var customDumpSubjectType: Any.Type {
              Self.self
            }
          }
        }

        extension Parent.FeatureModel: CustomDump.CustomDumpRepresentable {
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

          public struct CustomDumpValue {
            public var count = 0
          }

          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }

          public var customDumpSubjectType: Any.Type {
            Self.self
          }
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
        }
        """
      }
    }

    @Test func customDumpProperty() {
      assertMacro {
        """
        @CustomDump
        final class FeatureModel {
          @CustomDumpValue var child: Child
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
          @CustomDumpValue var child: Child
          var count: Int

          init(child: Child, count: Int) {
            self.child = child
            self.count = count
          }

          public struct CustomDumpValue {
            public var child: Child.CustomDumpValue
            public var count: Int
          }

          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(child: self.child.customDumpValue, count: self.count)
          }

          public var customDumpSubjectType: Any.Type {
            Self.self
          }
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
        }
        """
      }
    }

    @Test func customDumpValueInheritsSendableNotHashable() {
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

          public struct CustomDumpValue: Sendable {
            public var count: Int
          }

          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }

          public var customDumpSubjectType: Any.Type {
            Self.self
          }
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
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

          public struct CustomDumpValue: Sendable {
            public var count: Int
          }

          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }

          public var customDumpSubjectType: Any.Type {
            Self.self
          }
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
        }
        """
      }
    }

    @Test func customDumpValueInheritsUncheckedSendable() {
      assertMacro {
        """
        @CustomDump
        final class FeatureModel: @unchecked Sendable {
          var count: Int
        }
        """
      } expansion: {
        """
        final class FeatureModel: @unchecked Sendable {
          var count: Int

          public struct CustomDumpValue: @unchecked Sendable {
            public var count: Int
          }

          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }

          public var customDumpSubjectType: Any.Type {
            Self.self
          }
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
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

          public struct CustomDumpValue: Identifiable {
            public var id: UUID
            public var count: Int
          }

          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(id: self.id, count: self.count)
          }

          public var customDumpSubjectType: Any.Type {
            Self.self
          }
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
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

          public struct CustomDumpValue {
            public var count: Int
          }

          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }

          public var customDumpSubjectType: Any.Type {
            Self.self
          }
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
        }
        """
      }
    }

    @Test func customDumpPropertyInferredTypeFromInitializer() {
      assertMacro {
        """
        @CustomDump
        final class FeatureModel {
          @CustomDumpValue var child = Child()
        }
        """
      } expansion: {
        """
        final class FeatureModel {
          @CustomDumpValue var child = Child()

          public struct CustomDumpValue {
            public var child = (Child()).customDumpValue
          }

          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(child: self.child.customDumpValue)
          }

          public var customDumpSubjectType: Any.Type {
            Self.self
          }
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
        }
        """
      }
    }

    @Test func customDumpPropertyInitializerWithExplicitType() {
      assertMacro {
        """
        @CustomDump
        final class FeatureModel {
          @CustomDumpValue var child: Child = Child()
        }
        """
      } expansion: {
        """
        final class FeatureModel {
          @CustomDumpValue var child: Child = Child()

          public struct CustomDumpValue {
            public var child: Child.CustomDumpValue = (Child()).customDumpValue
          }

          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(child: self.child.customDumpValue)
          }

          public var customDumpSubjectType: Any.Type {
            Self.self
          }
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
        }
        """
      }
    }

    @Test func customDumpPropertyInitializerRewritesSelf() {
      assertMacro {
        """
        @CustomDump
        final class FeatureModel {
          @CustomDumpValue var child: Child = Self.makeChild()

          static func makeChild() -> Child {
            Child()
          }
        }
        """
      } expansion: {
        """
        final class FeatureModel {
          @CustomDumpValue var child: Child = Self.makeChild()

          static func makeChild() -> Child {
            Child()
          }

          public struct CustomDumpValue {
            public var child: Child.CustomDumpValue = (FeatureModel.makeChild()).customDumpValue
          }

          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(child: self.child.customDumpValue)
          }

          public var customDumpSubjectType: Any.Type {
            Self.self
          }
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
        }
        """
      }
    }

    @Test func customDumpPropertyInitializerStaticShorthand() {
      assertMacro {
        """
        @CustomDump
        final class FeatureModel {
          @CustomDumpValue var child: Child = .make()
        }
        """
      } expansion: {
        """
        final class FeatureModel {
          @CustomDumpValue var child: Child = .make()

          public struct CustomDumpValue {
            public var child: Child.CustomDumpValue = (Child.make()).customDumpValue
          }

          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(child: self.child.customDumpValue)
          }

          public var customDumpSubjectType: Any.Type {
            Self.self
          }
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
        }
        """
      }
    }

    @Test func customDumpPropertyInitializerRewritesNestedSelfTypeReferences() {
      assertMacro {
        """
        @CustomDump
        final class FeatureModel {
          @CustomDumpValue var child: Child = Factory<Self>.make()
        }
        """
      } expansion: {
        """
        final class FeatureModel {
          @CustomDumpValue var child: Child = Factory<Self>.make()

          public struct CustomDumpValue {
            public var child: Child.CustomDumpValue = (Factory<FeatureModel>.make()).customDumpValue
          }

          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(child: self.child.customDumpValue)
          }

          public var customDumpSubjectType: Any.Type {
            Self.self
          }
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
        }
        """
      }
    }

    @Test func customDumpPropertyInitializerNestedImplicitMemberUnchanged() {
      assertMacro {
        """
        @CustomDump
        final class FeatureModel {
          @CustomDumpValue var child: ChildContainer = ChildContainer(child: .make())
        }
        """
      } expansion: {
        """
        final class FeatureModel {
          @CustomDumpValue var child: ChildContainer = ChildContainer(child: .make())

          public struct CustomDumpValue {
            public var child: ChildContainer.CustomDumpValue = (ChildContainer(child: .make())).customDumpValue
          }

          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(child: self.child.customDumpValue)
          }

          public var customDumpSubjectType: Any.Type {
            Self.self
          }
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
        }
        """
      }
    }

    @Test func customDumpPropertyInitializerClosureInvocationRewritesSelf() {
      assertMacro {
        """
        @CustomDump
        final class FeatureModel {
          @CustomDumpValue var child = { Self.makeChild() }()

          static func makeChild() -> Child {
            Child()
          }
        }
        """
      } expansion: {
        """
        final class FeatureModel {
          @CustomDumpValue var child = { Self.makeChild() }()

          static func makeChild() -> Child {
            Child()
          }

          public struct CustomDumpValue {
            public var child = ({
                FeatureModel.makeChild()
              }()).customDumpValue
          }

          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(child: self.child.customDumpValue)
          }

          public var customDumpSubjectType: Any.Type {
            Self.self
          }
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
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
                                         ✏️ Insert ': <#Type#>'
        }
        """
      } fixes: {
        """
        @CustomDump
        final class FeatureModel {
          @FetchAll(Reminder.all) var reminders: <#Type#>
        }
        """
      } expansion: {
        """
        final class FeatureModel {
          @FetchAll(Reminder.all) var reminders: <#Type#>

          public struct CustomDumpValue {
            public var reminders: <#Type#>
          }

          public var customDumpValue: CustomDumpValue {
            CustomDumpValue(reminders: self.reminders)
          }

          public var customDumpSubjectType: Any.Type {
            Self.self
          }
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
        }
        """
      }
    }
  }
#endif
