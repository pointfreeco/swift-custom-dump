import CustomDump
import XCTest

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
final class DiffTests: XCTestCase {
  func testAny() {
    XCTAssertEqual(
      diff(
        (1, 2) as Any,
        (1, 2)
      ),
      nil
    )

    XCTAssertNoDifference(
      diff(
        (1, (2, 3)) as Any,
        "Blob"
      ),
      """
      - (
      -   1,
      -   (
      -     2,
      -     3
      -   )
      - )
      + "Blob"
      """
    )
  }

  func testAnyType() {
    XCTAssertNoDifference(
      diff(
        Foo.Bar.self as Any.Type,
        Foo.self
      ),
      """
      - Foo.Bar.self
      + Foo.self
      """
    )
  }

  func testClass() {
    XCTAssertNoDifference(
      diff(
        UserClass(
          id: 42,
          name: "Blob"
        ),
        UserClass(
          id: 42,
          name: "Blob, Jr."
        )
      ),
      """
        UserClass(
          id: 42,
      -   name: "Blob"
      +   name: "Blob, Jr."
        )
      """
    )

    XCTAssertNoDifference(
      diff(
        NSObject(),
        NSObject()
      ),
      """
      - NSObject()
      + NSObject()
      """
    )

    XCTAssertNoDifference(
      diff(
        RepeatedObject(id: "a"),
        RepeatedObject(id: "b")
      ),
      """
        RepeatedObject(
          child: RepeatedObject.Child(
      -     grandchild: RepeatedObject.Grandchild(id: "a")
      +     grandchild: RepeatedObject.Grandchild(id: "b")
          ),
      -   grandchild: RepeatedObject.Grandchild(↩︎)
      +   grandchild: RepeatedObject.Grandchild(↩︎)
        )
      """
    )
  }

  func testClassObjectIdentity() {
    class User: NSObject {
      let id = 42
      let name = "Blob"
    }

    XCTAssertNoDifference(
      diff(
        User(),
        User()
      )?.replacingOccurrences(of: "0x[[:xdigit:]]+", with: "0x…", options: .regularExpression),
      """
        DiffTests.User(
      -   _: ObjectIdentifier(0x…),
      +   _: ObjectIdentifier(0x…),
          id: 42,
          name: "Blob"
        )
      """
    )
  }

  func testCollection() {
    XCTAssertNoDifference(
      diff(
        [
          User(
            id: 1,
            name: "Blob"
          ),
          User(
            id: 2,
            name: "Blob, Jr."
          ),
          User(
            id: 3,
            name: "Blob, Sr."
          ),
        ],
        [
          User(
            id: 1,
            name: "Blob, Esq."
          ),
          User(
            id: 3,
            name: "Blob, Sr."
          ),
          User(
            id: 4,
            name: "Blob, Jr."
          ),
        ]
      ),
      """
        [
          [0]: User(
            id: 1,
      -     name: "Blob"
      +     name: "Blob, Esq."
          ),
      -   [1]: User(
      -     id: 2,
      -     name: "Blob, Jr."
      -   ),
          [1]: User(…),
      +   [2]: User(
      +     id: 4,
      +     name: "Blob, Jr."
      +   )
        ]
      """
    )
  }

  func testCollectionCollapsing() {
    let largeArray = Array(1...1_000)
    var other = largeArray
    other[100] = 42
    other[102] = 42
    other.insert(42, at: 300)
    other.remove(at: 700)

    XCTAssertNoDifference(
      diff(largeArray, other),
      """
        [
          … (100 unchanged),
      -   [100]: 101,
      +   [100]: 42,
          [101]: 102,
      -   [102]: 103,
      +   [102]: 42,
          … (197 unchanged),
      +   [300]: 42,
          … (399 unchanged),
      -   [699]: 700,
          … (300 unchanged)
        ]
      """
    )
  }

  func testDictionary() {
    XCTAssertNoDifference(
      diff(
        [
          1: User(
            id: 1,
            name: "Blob"
          ),
          2: User(
            id: 2,
            name: "Blob, Jr."
          ),
        ],
        [
          1: User(
            id: 1,
            name: "Blob"
          ),
          2: User(
            id: 2,
            name: "Blob, Sr."
          ),
          3: User(
            id: 3,
            name: "Dr. Blob"
          ),
        ]
      ),
      """
        [
          2: User(
            id: 2,
      -     name: "Blob, Jr."
      +     name: "Blob, Sr."
          ),
      +   3: User(
      +     id: 3,
      +     name: "Dr. Blob"
      +   ),
          … (1 unchanged)
        ]
      """
    )

    XCTAssertNoDifference(
      diff(
        OrderedDictionary(pairs: [
          1: User(
            id: 1,
            name: "Blob"
          ),
          2: User(
            id: 2,
            name: "Blob, Jr."
          ),
        ]),
        OrderedDictionary(pairs: [
          1: User(
            id: 1,
            name: "Blob"
          ),
          2: User(
            id: 2,
            name: "Blob, Sr."
          ),
          3: User(
            id: 3,
            name: "Dr. Blob"
          ),
        ])
      ),
      """
        [
          1: User(…),
          2: User(
            id: 2,
      -     name: "Blob, Jr."
      +     name: "Blob, Sr."
          ),
      +   3: User(
      +     id: 3,
      +     name: "Dr. Blob"
      +   )
        ]
      """
    )

    XCTAssertNoDifference(
      diff(
        OrderedDictionary(pairs: [
          0: User(
            id: 0,
            name: "Original Blob"
          ),
          1: User(
            id: 1,
            name: "Blob"
          ),
          2: User(
            id: 2,
            name: "Blob, Jr."
          ),
        ]),
        OrderedDictionary(pairs: [
          0: User(
            id: 0,
            name: "Original Blob"
          ),
          1: User(
            id: 1,
            name: "Blob"
          ),
          2: User(
            id: 2,
            name: "Blob, Sr."
          ),
          3: User(
            id: 3,
            name: "Dr. Blob"
          ),
        ])
      ),
      """
        [
          … (2 unchanged),
          2: User(
            id: 2,
      -     name: "Blob, Jr."
      +     name: "Blob, Sr."
          ),
      +   3: User(
      +     id: 3,
      +     name: "Dr. Blob"
      +   )
        ]
      """
    )
  }

  func testDictionaryCollapsing() {
    let largeDictionary = Dictionary(uniqueKeysWithValues: Array(1...1_000).map { ($0, "\($0)") })
    var other = largeDictionary
    other[100] = "42"
    other[102] = "42"
    other[300] = "42"
    other[700] = nil

    XCTAssertNoDifference(
      diff(largeDictionary, other),
      """
        [
      -   100: "100",
      +   100: "42",
      -   102: "102",
      +   102: "42",
      -   300: "300",
      +   300: "42",
      -   700: "700",
          … (996 unchanged)
        ]
      """
    )
  }

  func testEnum() {
    XCTAssertEqual(diff(Enum.foo, Enum.foo), nil)
    XCTAssertEqual(diff(Enum.bar(42), Enum.bar(42)), nil)
    XCTAssertEqual(
      diff(Enum.baz(fizz: 1.2, buzz: "Blob"), Enum.baz(fizz: 1.2, buzz: "Blob")), nil)

    XCTAssertNoDifference(
      diff(Enum.foo, Enum.bar(42)),
      """
      - Enum.foo
      + Enum.bar(42)
      """
    )

    XCTAssertNoDifference(
      diff(Enum.bar(42), Enum.bar(43)),
      """
      - Enum.bar(42)
      + Enum.bar(43)
      """
    )

    XCTAssertNoDifference(
      diff(Enum.fizz(42, buzz: "Blob"), Enum.fizz(42, buzz: "Glob")),
      """
        Enum.fizz(
          42.0,
      -   buzz: "Blob"
      +   buzz: "Glob"
        )
      """
    )

    XCTAssertNoDifference(
      diff(
        Nested.nest(.fizz(42, buzz: "Blob")),
        Nested.nest(.fizz(42, buzz: "Glob"))
      ),
      """
        Nested.nest(
          .fizz(
            42.0,
      -     buzz: "Blob"
      +     buzz: "Glob"
          )
        )
      """
    )

    XCTAssertNoDifference(
      diff(
        Enum.foo,
        Enum.buzz
      ),
      """
      - Enum.foo
      + Enum.buzz
      """
    )

    XCTAssertNoDifference(
      diff(
        Nested.nest(.foo),
        Nested.nest(.buzz)
      ),
      """
      - Nested.nest(.foo)
      + Nested.nest(.buzz)
      """
    )

    XCTAssertNoDifference(
      diff(
        Nested.largerNest(1, .foo),
        Nested.largerNest(1, .buzz)
      ),
      """
        Nested.largerNest(
          1,
      -   .foo
      +   .buzz
        )
      """
    )
  }

  func testEnumCollapsing() {
    enum Offset: Equatable {
      case page(Int, perPage: Int = 10)
    }
    struct State: Equatable {
      var offset: Offset
      let result: String
    }
    XCTAssertNoDifference(
      diff(
        State(offset: .page(1), result: "Hello, world!"),
        State(offset: .page(1), result: "Good night, moon!")
      ),
      """
        DiffTests.State(
          offset: .page(…),
      -   result: "Hello, world!"
      +   result: "Good night, moon!"
        )
      """
    )
  }

  func testOptional() {
    XCTAssertEqual(
      diff(nil as User?, nil), nil
    )
    XCTAssertEqual(
      diff(User?(.init(id: 42, name: "Blob")), User?(.init(id: 42, name: "Blob"))),
      nil
    )

    XCTAssertNoDifference(
      diff(User?(.init(id: 42, name: "Blob")), nil),
      """
      - User(
      -   id: 42,
      -   name: "Blob"
      - )
      + nil
      """
    )
    XCTAssertNoDifference(
      diff(User?(.init(id: 42, name: "Blob")), User?(.init(id: 42, name: "Blob, Esq."))),
      """
        User(
          id: 42,
      -   name: "Blob"
      +   name: "Blob, Esq."
        )
      """
    )
  }

  func testSet() {
    XCTAssertEqual(diff(Set([1, 2, 3]), Set([1, 2, 3])), nil)

    XCTAssertNoDifference(
      diff(
        Set([1, 2, 3]),
        Set([1, 3, 4])
      ),
      """
        Set([
      -   2,
      +   4,
          … (2 unchanged)
        ])
      """
    )
  }

  func testSetCollapsing() {
    let largeSet = Set(Array(1...1_000))
    var other = largeSet
    other.remove(100)
    other.remove(102)
    other.insert(9999)

    XCTAssertNoDifference(
      diff(largeSet, other),
      """
        Set([
      -   100,
      -   102,
      +   9999,
          … (998 unchanged)
        ])
      """
    )
  }

  func testSingleValue() {
    XCTAssertEqual(diff(1, 1), nil)
    XCTAssertNoDifference(
      diff(1, 2),
      """
      - 1
      + 2
      """
    )

    XCTAssertEqual(diff(true, true), nil)
    XCTAssertNoDifference(
      diff(true, false),
      """
      - true
      + false
      """
    )
  }

  func testStruct() {
    XCTAssertNoDifference(
      diff(
        NeverEqual(),
        NeverEqual()
      ),
      """
        // Not equal but no difference detected:
      - NeverEqual()
      + NeverEqual()
      """
    )

    XCTAssertNoDifference(
      diff(
        User(
          id: 42,
          name: "Blob"
        ),
        User(
          id: 42,
          name: "Blob, Jr."
        )
      ),
      """
        User(
          id: 42,
      -   name: "Blob"
      +   name: "Blob, Jr."
        )
      """
    )

    XCTAssertNoDifference(
      diff(
        Pair(
          driver: User(
            id: 1,
            name: "Blob"
          ),
          passenger: User(
            id: 2,
            name: "Blob, Jr."
          )
        ),
        Pair(
          driver: User(
            id: 1,
            name: "Blob"
          ),
          passenger: User(
            id: 2,
            name: "Blob, Sr."
          )
        )
      ),
      """
        Pair(
          driver: User(…),
          passenger: User(
            id: 2,
      -     name: "Blob, Jr."
      +     name: "Blob, Sr."
          )
        )
      """
    )

    XCTAssertNoDifference(
      diff(
        NeverEqualUser(id: 1, name: "Blob"),
        NeverEqualUser(id: 1, name: "Blob")
      ),
      """
        // Not equal but no difference detected:
      - NeverEqualUser(…)
      + NeverEqualUser(…)
      """
    )
  }

  func testTuple() {
    XCTAssertEqual(diff((1, 2), (1, 2)), nil)
    XCTAssertNoDifference(
      diff((1, 2), (1, 3)),
      """
        (
          1,
      -   2
      +   3
        )
      """
    )

    XCTAssertEqual(diff((blob: 1, 2), (blob: 1, 2)), nil)
    XCTAssertNoDifference(
      diff((blob: 1, 2), (blob: 1, 3)),
      """
        (
          blob: 1,
      -   2
      +   3
        )
      """
    )

    XCTAssertEqual(diff((1, (2, 3)), (1, (2, 3))), nil)
    XCTAssertNoDifference(
      diff((1, (2, 3)), (0, (2, 3))),
      """
        (
      -   1,
      +   0,
          (…)
        )
      """
    )

    XCTAssertEqual(diff((1, ()), (1, ())), nil)
    XCTAssertNoDifference(
      diff((1, ()), (0, ())),
      """
        (
      -   1,
      +   0,
          ()
        )
      """
    )
  }

  #if !os(WASI)
    func testNestedCustomMirror() {
      #if compiler(>=5.4)
        XCTAssertNoDifference(
          diff(
            NestedDate(date: Date(timeIntervalSince1970: 0)),
            NestedDate(date: Date(timeIntervalSince1970: 1))
          ),
          """
          - NestedDate(date: Date(1970-01-01T00:00:00.000Z))
          + NestedDate(date: Date(1970-01-01T00:00:01.000Z))
          """
        )
      #endif
    }
  #endif

  func testMultilineString() {
    XCTAssertNoDifference(
      diff(
        """
        Hello,
        World!
        """,
        """
        Hello,
        Blob!
        """
      ),
      #"""
        """
        Hello,
      - World!
      + Blob!
        """
      """#
    )

    XCTAssertNoDifference(
      diff(
        """
        Hello,
        World!
        """[...],
        """
        Hello,
        Blob!
        """[...]
      ),
      #"""
        """
        Hello,
      - World!
      + Blob!
        """
      """#
    )

    XCTAssertNoDifference(
      diff(
        Email(
          subject: "RE: Upcoming Event",
          body: """
            To who it may concern,

            Look forward to it!

            Yours,
            Blob
            """
        ),
        Email(
          subject: "RE: Upcoming Event",
          body: """
            To whom it may concern,

            Look forward to it!

            Yours,
            Blob
            """
        )
      ),
      """
        Email(
          subject: "RE: Upcoming Event",
          body: \"\"\"
      -     To who it may concern,
      +     To whom it may concern,
            \n\
            Look forward to it!
            \n\
            Yours,
            Blob
            \"\"\"
        )
      """
    )

    XCTAssertNoDifference(
      diff(
        Email(
          subject: "RE: Upcoming Event",
          body: """
            To whom it may concern,

            Look forward to it!

            Yours,
            Blob
            """
        ),
        Email(
          subject: "Re: Upcoming Event",
          body: """
            To whom it may concern,

            Look forward to it!

            Yours,
            Blob
            """
        )
      ),
      """
        Email(
      -   subject: "RE: Upcoming Event",
      +   subject: "Re: Upcoming Event",
          body: "…"
        )
      """
    )
  }

  func testAnyHashable() {
    XCTAssertNoDifference(
      diff(
        AnyHashable(42),
        AnyHashable(43)
      ),
      """
      - 42
      + 43
      """
    )

    XCTAssertNoDifference(
      diff(
        [
          AnyHashable(1): User(id: 1, name: "Blob"),
          AnyHashable("Blob, Jr."): User(id: 2, name: "Blob, Jr."),
        ],
        [
          AnyHashable(1): User(id: 1, name: "Blob, Sr."),
          AnyHashable("Blob, Jr."): User(id: 2, name: "Blob, Jr., Esq."),
        ]
      ),
      """
        [
          "Blob, Jr.": User(
            id: 2,
      -     name: "Blob, Jr."
      +     name: "Blob, Jr., Esq."
          ),
          1: User(
            id: 1,
      -     name: "Blob"
      +     name: "Blob, Sr."
          )
        ]
      """
    )
  }

  #if !os(WASI)
    func testDeeplyNested() {
      let user = FriendlyUser(
        id: 1,
        name: "Blob",
        friends: [
          .init(
            id: 2,
            name: "Blob Jr.",
            friends: [
              .init(
                id: 3,
                name: "Blob Sr.",
                friends: [.init(id: 4, name: "Someone", friends: [])]
              )
            ]
          )
        ]
      )

      var other = user
      other.friends[0].friends[0].friends[0].name += " Else"

      XCTAssertNoDifference(
        diff(user, other),
        """
          FriendlyUser(
            id: 1,
            name: "Blob",
            friends: [
              [0]: FriendlyUser(
                id: 2,
                name: "Blob Jr.",
                friends: [
                  [0]: FriendlyUser(
                    id: 3,
                    name: "Blob Sr.",
                    friends: [
                      [0]: FriendlyUser(
                        id: 4,
        -               name: "Someone",
        +               name: "Someone Else",
                        friends: []
                      )
                    ]
                  )
                ]
              )
            ]
          )
        """
      )
    }
  #endif

  func testInterleavedIndices() {
    XCTAssertNoDifference(
      diff(
        [
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
          9,
          10,
        ],
        [
          1,
          4,
          64,
          7,
          8,
          9,
          10,
          42,
        ]
      ),
      """
        [
          [0]: 1,
      -   [1]: 2,
      -   [2]: 3,
          [1]: 4,
      -   [4]: 5,
      +   [2]: 64,
      -   [5]: 6,
          … (4 unchanged),
      +   [7]: 42
        ]
      """
    )
  }

  func testNamespacedTypes() {
    XCTAssertNoDifference(
      diff(
        Namespaced.Class(x: 0),
        Namespaced.Class(x: 1)
      ),
      """
      - Namespaced.Class(x: 0)
      + Namespaced.Class(x: 1)
      """
    )

    XCTAssertNoDifference(
      diff(
        Namespaced.Enum.x(0),
        Namespaced.Enum.x(1)
      ),
      """
      - Namespaced.Enum.x(0)
      + Namespaced.Enum.x(1)
      """
    )

    XCTAssertNoDifference(
      diff(
        Namespaced.Struct(x: 0),
        Namespaced.Struct(x: 1)
      ),
      """
      - Namespaced.Struct(x: 0)
      + Namespaced.Struct(x: 1)
      """
    )
  }

  func testCustomMirror() {
    XCTAssertNoDifference(
      diff(
        LoginState(
          email: "blob@pointfree.co",
          password: "bl0bisawesome",
          token: "secret"
        ),
        LoginState(
          email: "blob@pointfree.co",
          password: "bl0bisawesome!",
          token: "secret"
        )
      ),
      """
        LoginState(
          email: "blob@pointfree.co",
      -   password: <redacted>
      +   password: <redacted>
        )
      """
    )
  }

  func testCustomOverride() {
    XCTAssertNoDifference(
      diff(
        Wrapper(rawValue: 1),
        Wrapper(rawValue: 2)
      ),
      """
      - 1
      + 2
      """
    )

    XCTAssertNoDifference(
      diff(
        Wrapper(
          rawValue: LoginState(
            email: "blob@pointfree.co",
            password: "bl0bisawesome",
            token: "secret"
          )
        ),
        Wrapper(
          rawValue: LoginState(
            email: "blob@pointfree.co",
            password: "bl0bisawesome!",
            token: "secret"
          )
        )
      ),
      """
        LoginState(
          email: "blob@pointfree.co",
      -   password: <redacted>
      +   password: <redacted>
        )
      """
    )
  }

  func testDifferentTypes() {
    XCTAssertNoDifference(
      diff(
        29.99 as Float as Any,
        29.99 as Double as Any
      ),
      """
      - 29.99 as Float
      + 29.99 as Double
      """
    )

    XCTAssertNoDifference(
      diff(
        [
          "value": 29.99 as Float
        ] as [String: Any],
        [
          "value": 29.99 as Double
        ]
      ),
      """
        [
      -   "value": 29.99 as Float
      +   "value": 29.99 as Double
        ]
      """
    )
  }

  func testCustomDictionary() {
    XCTAssertEqual(
      String(customDumping: Stack(elements: [(.init(rawValue: 0), "Hello")])),
      """
      [
        #0: "Hello"
      ]
      """
    )

    XCTAssertEqual(
      diff(
        Stack(elements: [(.init(rawValue: 0), "Hello")]),
        Stack(elements: [(.init(rawValue: 1), "Hello")])
      ),
      """
        [
      -   #0: "Hello"
      +   #1: "Hello"
        ]
      """
    )

    struct Child {
      struct State: Equatable {}
    }
    struct Parent {
      struct State: Equatable {
        var children: Stack<Child.State>
      }
    }
    XCTAssertNoDifference(
      diff(
        Parent.State(children: Stack(elements: [(.init(rawValue: 0), Child.State())])),
        Parent.State(children: Stack(elements: [(.init(rawValue: 1), Child.State())]))
      ),
      """
        DiffTests.Parent.State(
          children: [
      -     #0: DiffTests.Child.State()
      +     #1: DiffTests.Child.State()
          ]
        )
      """
    )
  }

  func testCustomDumpRepresentableCollapsing() {
    struct Results: CustomDumpRepresentable, Equatable {
      var customDumpValue: Any {
        [1, 2]
      }
    }
    struct State: Equatable {
      var date: Double
      var results: Results
    }
    XCTAssertNoDifference(
      diff(
        State(date: 123_456_789, results: Results()),
        State(date: 123_456_790, results: Results())
      ),
      """
        DiffTests.State(
      -   date: 123456789.0,
      +   date: 123456790.0,
          results: […]
        )
      """
    )
  }

  func testObservationRegistrarFiltered() {
    struct ObservationRegistrar: Equatable {}
    struct Value: Equatable {
      var name: String
      let _$observationRegistrar = ObservationRegistrar()
    }
    let blobSr = Value(name: "Blob Sr.")
    let blobJr = Value(name: "Blob Jr.")
    XCTAssertNoDifference(
      diff(
        blobSr,
        blobJr
      ),
      """
        DiffTests.Value(
      -   name: "Blob Sr."
      +   name: "Blob Jr."
        )
      """
    )
  }

  func testDiffableObject() {
    let obj = DiffableObject()
    XCTAssertNoDifference(
      diff(obj, obj),
      """
      - "before"
      + "after"
      """
    )

    let bar = DiffableObjects(obj1: obj, obj2: obj)
    XCTAssertNoDifference(
      diff(bar, bar),
      """
        DiffableObjects(
      -   obj1: "before",
      +   obj1: "after",
      -   obj2: "before"
      +   obj2: "after"
        )
      """
    )
  }
}

private class DiffableObject: _CustomDiffObject, Equatable {
  var _customDiffValues: (Any, Any) {
    ("before", "after")
  }
  static func == (lhs: DiffableObject, rhs: DiffableObject) -> Bool {
    false
  }
}

private struct DiffableObjects: Equatable {
  var obj1: DiffableObject
  var obj2: DiffableObject
}

private struct Stack<State: Equatable>: CustomDumpReflectable, Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    zip(lhs.elements, rhs.elements).allSatisfy(==)
  }

  var elements: [(ID, State)]

  struct ID: CustomDumpStringConvertible, Hashable {
    let rawValue: Int
    var customDumpDescription: String {
      "#\(self.rawValue)"
    }
  }

  var customDumpMirror: Mirror {
    Mirror(
      self,
      unlabeledChildren: self.elements,
      displayStyle: .dictionary
    )
  }
}
