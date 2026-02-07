#if os(macOS)
  import CustomDump
  import CustomDumpMacros
  import MacroTesting
  import Testing

  @Suite(
    .macros(
      [DebugSnapshotMacro.self],
      record: .missing
    )
  )
  struct CustomDumpMacroTests {
    @Test func basics() {
      assertMacro {
        """
        @DebugSnapshot
        final class FeatureModel {
          private var count: Int
          var title: String
          var onChange: (Int) -> Void
          @DebugSnapshotIgnored var ignored: UUID

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
          @DebugSnapshotIgnored var ignored: UUID

          init(count: Int, title: String, onChange: @escaping (Int) -> Void, ignored: UUID) {
            self.count = count
            self.title = title
            self.onChange = onChange
            self.ignored = ignored
          }

          public struct DebugSnapshot {
            public var title: String
          }

          public var _debugSnapshot: DebugSnapshot {
            DebugSnapshot(title: self.title)
          }
        }

        extension FeatureModel: CustomDump.DebugSnapshotRepresentable {
        }
        """
      }
    }

    @Test func mainActor() {
      assertMacro {
        """
        @MainActor
        @DebugSnapshot
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

          public struct DebugSnapshot {
            public var count: Int
          }

          public var _debugSnapshot: DebugSnapshot {
            DebugSnapshot(count: self.count)
          }
        }

        extension FeatureModel: @MainActor CustomDump.DebugSnapshotRepresentable {
        }
        """
      }
    }

    @Test func alreadyConforms() {
      assertMacro {
        """
        @DebugSnapshot
        final class FeatureModel: DebugSnapshotRepresentable {
          var count: Int

          init(count: Int) {
            self.count = count
          }
        }
        """
      } expansion: {
        """
        final class FeatureModel: DebugSnapshotRepresentable {
          var count: Int

          init(count: Int) {
            self.count = count
          }

          public struct DebugSnapshot {
            public var count: Int
          }

          public var _debugSnapshot: DebugSnapshot {
            DebugSnapshot(count: self.count)
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
        @DebugSnapshot
        @MainActor
        final class FeatureModel: @MainActor DebugSnapshotRepresentable {
          var count: Int

          init(count: Int) {
            self.count = count
          }
        }
        """
      } expansion: {
        """
        @MainActor
        final class FeatureModel: @MainActor DebugSnapshotRepresentable {
          var count: Int

          init(count: Int) {
            self.count = count
          }

          public struct DebugSnapshot {
            public var count: Int
          }

          public var _debugSnapshot: DebugSnapshot {
            DebugSnapshot(count: self.count)
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
        @DebugSnapshot
        final class EmptyModel {
          init() {}
        }
        """
      } expansion: {
        """
        final class EmptyModel {
          init() {}

          public struct DebugSnapshot {

          }

          public var _debugSnapshot: DebugSnapshot {
            DebugSnapshot()
          }
        }

        extension EmptyModel: CustomDump.DebugSnapshotRepresentable {
        }
        """
      }
    }

    @Test func privateTypeUsesFileprivateMembers() {
      assertMacro {
        """
        @DebugSnapshot
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

          public struct DebugSnapshot {
            public var count: Int
          }

          public var _debugSnapshot: DebugSnapshot {
            DebugSnapshot(count: self.count)
          }
        }

        extension FeatureModel: CustomDump.DebugSnapshotRepresentable {
        }
        """
      }
    }

    @Test func privateContainerUsesFileprivateMembers() {
      assertMacro {
        """
        private struct Parent {
          @DebugSnapshot
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

            public struct DebugSnapshot {
              public var count: Int
            }

            public var _debugSnapshot: DebugSnapshot {
              DebugSnapshot(count: self.count)
            }
          }
        }

        extension Parent.FeatureModel: CustomDump.DebugSnapshotRepresentable {
        }
        """
      }
    }

    @Test func defaultLiteral() {
      assertMacro {
        """
        @DebugSnapshot
        final class FeatureModel {
          var count = 0
        }
        """
      } expansion: {
        """
        final class FeatureModel {
          var count = 0

          public struct DebugSnapshot {
            public var count = 0
          }

          public var _debugSnapshot: DebugSnapshot {
            DebugSnapshot(count: self.count)
          }
        }

        extension FeatureModel: CustomDump.DebugSnapshotRepresentable {
        }
        """
      }
    }

    @Test func customDumpProperty() {
      assertMacro {
        """
        @DebugSnapshot
        final class FeatureModel {
          @DebugSnapshotValue var child: Child
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
          @DebugSnapshotValue var child: Child
          var count: Int

          init(child: Child, count: Int) {
            self.child = child
            self.count = count
          }

          public struct DebugSnapshot {
            public var child: Child.DebugSnapshot
            public var count: Int
          }

          public var _debugSnapshot: DebugSnapshot {
            DebugSnapshot(child: self.child._debugSnapshot, count: self.count)
          }
        }

        extension FeatureModel: CustomDump.DebugSnapshotRepresentable {
        }
        """
      }
    }

    @Test func customDumpValueInheritsSendableNotHashable() {
      assertMacro {
        """
        @DebugSnapshot
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

          public struct DebugSnapshot: Sendable {
            public var count: Int
          }

          public var _debugSnapshot: DebugSnapshot {
            DebugSnapshot(count: self.count)
          }
        }

        extension FeatureModel: CustomDump.DebugSnapshotRepresentable {
        }
        """
      }
    }

    @Test func customDumpValueInheritsSendableOnly() {
      assertMacro {
        """
        @DebugSnapshot
        struct FeatureModel: Sendable {
          var count: Int
        }
        """
      } expansion: {
        """
        struct FeatureModel: Sendable {
          var count: Int

          public struct DebugSnapshot: Sendable {
            public var count: Int
          }

          public var _debugSnapshot: DebugSnapshot {
            DebugSnapshot(count: self.count)
          }
        }

        extension FeatureModel: CustomDump.DebugSnapshotRepresentable {
        }
        """
      }
    }

    @Test func customDumpValueInheritsUncheckedSendable() {
      assertMacro {
        """
        @DebugSnapshot
        final class FeatureModel: @unchecked Sendable {
          var count: Int
        }
        """
      } expansion: {
        """
        final class FeatureModel: @unchecked Sendable {
          var count: Int

          public struct DebugSnapshot: @unchecked Sendable {
            public var count: Int
          }

          public var _debugSnapshot: DebugSnapshot {
            DebugSnapshot(count: self.count)
          }
        }

        extension FeatureModel: CustomDump.DebugSnapshotRepresentable {
        }
        """
      }
    }

    @Test func customDumpValueInheritsIdentifiableWhenIDIncluded() {
      assertMacro {
        """
        @DebugSnapshot
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

          public struct DebugSnapshot: Identifiable {
            public var id: UUID
            public var count: Int
          }

          public var _debugSnapshot: DebugSnapshot {
            DebugSnapshot(id: self.id, count: self.count)
          }
        }

        extension FeatureModel: CustomDump.DebugSnapshotRepresentable {
        }
        """
      }
    }

    @Test func customDumpValueDoesNotInheritIdentifiableWhenIDExcluded() {
      assertMacro {
        """
        @DebugSnapshot
        struct FeatureModel: Identifiable {
          @DebugSnapshotIgnored var id: UUID
          var count: Int
        }
        """
      } expansion: {
        """
        struct FeatureModel: Identifiable {
          @DebugSnapshotIgnored var id: UUID
          var count: Int

          public struct DebugSnapshot {
            public var count: Int
          }

          public var _debugSnapshot: DebugSnapshot {
            DebugSnapshot(count: self.count)
          }
        }

        extension FeatureModel: CustomDump.DebugSnapshotRepresentable {
        }
        """
      }
    }

    @Test func customDumpPropertyInferredTypeFromInitializer() {
      assertMacro {
        """
        @DebugSnapshot
        final class FeatureModel {
          @DebugSnapshotValue var child = Child()
        }
        """
      } expansion: {
        """
        final class FeatureModel {
          @DebugSnapshotValue var child = Child()

          public struct DebugSnapshot {
            public var child = (Child())._debugSnapshot
          }

          public var _debugSnapshot: DebugSnapshot {
            DebugSnapshot(child: self.child._debugSnapshot)
          }
        }

        extension FeatureModel: CustomDump.DebugSnapshotRepresentable {
        }
        """
      }
    }

    @Test func customDumpPropertyInitializerWithExplicitType() {
      assertMacro {
        """
        @DebugSnapshot
        final class FeatureModel {
          @DebugSnapshotValue var child: Child = Child()
        }
        """
      } expansion: {
        """
        final class FeatureModel {
          @DebugSnapshotValue var child: Child = Child()

          public struct DebugSnapshot {
            public var child: Child.DebugSnapshot = (Child())._debugSnapshot
          }

          public var _debugSnapshot: DebugSnapshot {
            DebugSnapshot(child: self.child._debugSnapshot)
          }
        }

        extension FeatureModel: CustomDump.DebugSnapshotRepresentable {
        }
        """
      }
    }

    @Test func customDumpPropertyInitializerRewritesSelf() {
      assertMacro {
        """
        @DebugSnapshot
        final class FeatureModel {
          @DebugSnapshotValue var child: Child = Self.makeChild()

          static func makeChild() -> Child {
            Child()
          }
        }
        """
      } expansion: {
        """
        final class FeatureModel {
          @DebugSnapshotValue var child: Child = Self.makeChild()

          static func makeChild() -> Child {
            Child()
          }

          public struct DebugSnapshot {
            public var child: Child.DebugSnapshot = (FeatureModel.makeChild())._debugSnapshot
          }

          public var _debugSnapshot: DebugSnapshot {
            DebugSnapshot(child: self.child._debugSnapshot)
          }
        }

        extension FeatureModel: CustomDump.DebugSnapshotRepresentable {
        }
        """
      }
    }

    @Test func customDumpPropertyInitializerStaticShorthand() {
      assertMacro {
        """
        @DebugSnapshot
        final class FeatureModel {
          @DebugSnapshotValue var child: Child = .make()
        }
        """
      } expansion: {
        """
        final class FeatureModel {
          @DebugSnapshotValue var child: Child = .make()

          public struct DebugSnapshot {
            public var child: Child.DebugSnapshot = (Child.make())._debugSnapshot
          }

          public var _debugSnapshot: DebugSnapshot {
            DebugSnapshot(child: self.child._debugSnapshot)
          }
        }

        extension FeatureModel: CustomDump.DebugSnapshotRepresentable {
        }
        """
      }
    }

    @Test func customDumpPropertyInitializerRewritesNestedSelfTypeReferences() {
      assertMacro {
        """
        @DebugSnapshot
        final class FeatureModel {
          @DebugSnapshotValue var child: Child = Factory<Self>.make()
        }
        """
      } expansion: {
        """
        final class FeatureModel {
          @DebugSnapshotValue var child: Child = Factory<Self>.make()

          public struct DebugSnapshot {
            public var child: Child.DebugSnapshot = (Factory<FeatureModel>.make())._debugSnapshot
          }

          public var _debugSnapshot: DebugSnapshot {
            DebugSnapshot(child: self.child._debugSnapshot)
          }
        }

        extension FeatureModel: CustomDump.DebugSnapshotRepresentable {
        }
        """
      }
    }

    @Test func customDumpPropertyInitializerNestedImplicitMemberUnchanged() {
      assertMacro {
        """
        @DebugSnapshot
        final class FeatureModel {
          @DebugSnapshotValue var child: ChildContainer = ChildContainer(child: .make())
        }
        """
      } expansion: {
        """
        final class FeatureModel {
          @DebugSnapshotValue var child: ChildContainer = ChildContainer(child: .make())

          public struct DebugSnapshot {
            public var child: ChildContainer.DebugSnapshot = (ChildContainer(child: .make()))._debugSnapshot
          }

          public var _debugSnapshot: DebugSnapshot {
            DebugSnapshot(child: self.child._debugSnapshot)
          }
        }

        extension FeatureModel: CustomDump.DebugSnapshotRepresentable {
        }
        """
      }
    }

    @Test func customDumpPropertyInitializerClosureInvocationRewritesSelf() {
      assertMacro {
        """
        @DebugSnapshot
        final class FeatureModel {
          @DebugSnapshotValue var child = { Self.makeChild() }()

          static func makeChild() -> Child {
            Child()
          }
        }
        """
      } expansion: {
        """
        final class FeatureModel {
          @DebugSnapshotValue var child = { Self.makeChild() }()

          static func makeChild() -> Child {
            Child()
          }

          public struct DebugSnapshot {
            public var child = ({
                FeatureModel.makeChild()
              }())._debugSnapshot
          }

          public var _debugSnapshot: DebugSnapshot {
            DebugSnapshot(child: self.child._debugSnapshot)
          }
        }

        extension FeatureModel: CustomDump.DebugSnapshotRepresentable {
        }
        """
      }
    }

    @Test func missingTypeAnnotation() {
      assertMacro {
        """
        @DebugSnapshot
        final class FeatureModel {
          @FetchAll(Reminder.all) var reminders
        }
        """
      } diagnostics: {
        """
        @DebugSnapshot
        final class FeatureModel {
          @FetchAll(Reminder.all) var reminders
                                      ┬────────
                                      ╰─ 🛑 '@DebugSnapshot' requires explicit type annotations for stored properties.
                                         ✏️ Insert ': <#Type#>'
        }
        """
      } fixes: {
        """
        @DebugSnapshot
        final class FeatureModel {
          @FetchAll(Reminder.all) var reminders: <#Type#>
        }
        """
      } expansion: {
        """
        final class FeatureModel {
          @FetchAll(Reminder.all) var reminders: <#Type#>

          public struct DebugSnapshot {
            public var reminders: <#Type#>
          }

          public var _debugSnapshot: DebugSnapshot {
            DebugSnapshot(reminders: self.reminders)
          }
        }

        extension FeatureModel: CustomDump.DebugSnapshotRepresentable {
        }
        """
      }
    }
  }
#endif
