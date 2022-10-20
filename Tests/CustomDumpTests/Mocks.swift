import CustomDump
import Foundation

class RecursiveFoo { var foo: RecursiveFoo? }

class RepeatedObject {
  class Child {
    let grandchild: Grandchild
    init(id: String) {
      grandchild = Grandchild(id: id)
    }
  }
  class Grandchild {
    let id: String
    init(id: String) {
      self.id = id
    }
  }

  let child: Child
  let grandchild: Grandchild
  init(id: String) {
    child = Child(id: id)
    grandchild = child.grandchild
  }
}

class UserClass {
  let id: Int, name: String
  init(id: Int, name: String) {
    self.id = id
    self.name = name
  }
}

enum Enum {
  case foo
  case bar(Int)
  case baz(fizz: Double, buzz: String)
  case fizz(Double, buzz: String)
  case fu(bar: Int)
}

enum Namespaced {
  class Class {
    var x: Int
    init(x: Int) { self.x = x }
  }
  enum Enum { case x(Int) }
  struct Struct { var x: Int }
}

struct Button: CustomDumpReflectable {
  var customDumpMirror: Mirror {
    .init(
      self,
      children: [
        "cancel": (
          action: Any?.none,
          label: "Cancel"
        )
      ],
      displayStyle: .enum
    )
  }
}

struct Email: Equatable { let subject: String, body: String }

struct Foo { struct Bar {} }

struct FriendlyUser: Equatable {
  var id: Int
  var name: String
  var friends: [FriendlyUser]
}

struct ID: Hashable, RawRepresentable { let rawValue: String }

struct Wrapper<RawValue>: CustomDumpRepresentable {
  let rawValue: RawValue

  var customDumpValue: Any {
    self.rawValue
  }
}

struct LoginState: CustomDumpReflectable {
  var email = "", password = "", token: String

  var customDumpMirror: Mirror {
    .init(
      self,
      children: [
        "email": self.email,
        "password": Redacted(rawValue: self.password),
      ],
      displayStyle: .struct
    )
  }
}

struct NestedDate { var date: Date? }

struct NeverEqual: Equatable { static func == (lhs: Self, rhs: Self) -> Bool { false } }

struct NeverEqualUser: Equatable {
  let id: Int
  let name: String

  static func == (lhs: Self, rhs: Self) -> Bool { false }
}

struct Pair { let driver: User, passenger: User }

struct Redacted<RawValue>: CustomDumpStringConvertible {
  var rawValue: RawValue

  var customDumpDescription: String {
    "<redacted>"
  }
}

struct User: Equatable, Identifiable { var id: Int, name: String }
struct HashableUser: Equatable, Identifiable, Hashable { var id: Int, name: String }
