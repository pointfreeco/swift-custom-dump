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
          struct CustomDumpValue: Equatable {
            var title: String
          }
          var customDumpValue: CustomDumpValue {
            CustomDumpValue(title: self.title)
          }
          var customDumpSubjectType: Any.Type {
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
          struct CustomDumpValue: Equatable {
            var count: Int
          }
          var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }
          var customDumpSubjectType: Any.Type {
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
          struct CustomDumpValue: Equatable {
            var count: Int
          }
          var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }
          var customDumpSubjectType: Any.Type {
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
          struct CustomDumpValue: Equatable {
            var count: Int
          }
          var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }
          var customDumpSubjectType: Any.Type {
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
          struct CustomDumpValue: Equatable {

          }
          var customDumpValue: CustomDumpValue {
            CustomDumpValue()
          }
          var customDumpSubjectType: Any.Type {
            EmptyModel.self
          }
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
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
          fileprivate struct CustomDumpValue: Equatable {
            var count: Int
          }
          fileprivate var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }
          fileprivate var customDumpSubjectType: Any.Type {
            FeatureModel.self
          }
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
          }
        }

        extension Parent.FeatureModel: CustomDump.CustomDumpRepresentable {
          fileprivate struct CustomDumpValue: Equatable {
            var count: Int
          }
          fileprivate var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }
          fileprivate var customDumpSubjectType: Any.Type {
            Parent.FeatureModel.self
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
          struct CustomDumpValue: Equatable {
            var count = 0
          }
          var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }
          var customDumpSubjectType: Any.Type {
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
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
          struct CustomDumpValue: Equatable {
            var child: Child.CustomDumpValue
            var count: Int
          }
          var customDumpValue: CustomDumpValue {
            CustomDumpValue(child: self.child.customDumpValue, count: self.count)
          }
          var customDumpSubjectType: Any.Type {
            FeatureModel.self
          }
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
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
          struct CustomDumpValue: Equatable, Sendable {
            var count: Int
          }
          var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }
          var customDumpSubjectType: Any.Type {
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
          struct CustomDumpValue: Equatable, Sendable {
            var count: Int
          }
          var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }
          var customDumpSubjectType: Any.Type {
            FeatureModel.self
          }
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
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
          struct CustomDumpValue: Equatable, @unchecked Sendable {
            var count: Int
          }
          var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }
          var customDumpSubjectType: Any.Type {
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
          struct CustomDumpValue: Equatable, Identifiable {
            var id: UUID
            var count: Int
          }
          var customDumpValue: CustomDumpValue {
            CustomDumpValue(id: self.id, count: self.count)
          }
          var customDumpSubjectType: Any.Type {
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
          struct CustomDumpValue: Equatable {
            var count: Int
          }
          var customDumpValue: CustomDumpValue {
            CustomDumpValue(count: self.count)
          }
          var customDumpSubjectType: Any.Type {
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
          @CustomDumpValue var child = Child()
        }
        """
      } expansion: {
        """
        final class FeatureModel {
          @CustomDumpValue var child = Child()
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
          struct CustomDumpValue: Equatable {
            var child = (Child()).customDumpValue
          }
          var customDumpValue: CustomDumpValue {
            CustomDumpValue(child: self.child.customDumpValue)
          }
          var customDumpSubjectType: Any.Type {
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
          @CustomDumpValue var child: Child = Child()
        }
        """
      } expansion: {
        """
        final class FeatureModel {
          @CustomDumpValue var child: Child = Child()
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
          struct CustomDumpValue: Equatable {
            var child: Child.CustomDumpValue = (Child()).customDumpValue
          }
          var customDumpValue: CustomDumpValue {
            CustomDumpValue(child: self.child.customDumpValue)
          }
          var customDumpSubjectType: Any.Type {
            FeatureModel.self
          }
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
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
          struct CustomDumpValue: Equatable {
            var child: Child.CustomDumpValue = (FeatureModel.makeChild()).customDumpValue
          }
          var customDumpValue: CustomDumpValue {
            CustomDumpValue(child: self.child.customDumpValue)
          }
          var customDumpSubjectType: Any.Type {
            FeatureModel.self
          }
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
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
          struct CustomDumpValue: Equatable {
            var child: Child.CustomDumpValue = (Child.make()).customDumpValue
          }
          var customDumpValue: CustomDumpValue {
            CustomDumpValue(child: self.child.customDumpValue)
          }
          var customDumpSubjectType: Any.Type {
            FeatureModel.self
          }
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
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
          struct CustomDumpValue: Equatable {
            var child: Child.CustomDumpValue = (Factory<FeatureModel>.make()).customDumpValue
          }
          var customDumpValue: CustomDumpValue {
            CustomDumpValue(child: self.child.customDumpValue)
          }
          var customDumpSubjectType: Any.Type {
            FeatureModel.self
          }
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
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
          struct CustomDumpValue: Equatable {
            var child: ChildContainer.CustomDumpValue = (ChildContainer(child: .make())).customDumpValue
          }
          var customDumpValue: CustomDumpValue {
            CustomDumpValue(child: self.child.customDumpValue)
          }
          var customDumpSubjectType: Any.Type {
            FeatureModel.self
          }
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
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
          struct CustomDumpValue: Equatable {
            var child = ({
                FeatureModel.makeChild()
              }()).customDumpValue
          }
          var customDumpValue: CustomDumpValue {
            CustomDumpValue(child: self.child.customDumpValue)
          }
          var customDumpSubjectType: Any.Type {
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
        }

        extension FeatureModel: CustomDump.CustomDumpRepresentable {
          struct CustomDumpValue: Equatable {
            var reminders: <#Type#>
          }
          var customDumpValue: CustomDumpValue {
            CustomDumpValue(reminders: self.reminders)
          }
          var customDumpSubjectType: Any.Type {
            FeatureModel.self
          }
        }
        """
      }
    }
  }
#endif
