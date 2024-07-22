# ``CustomDump``

A collection of tools for debugging, diffing, and testing your application's data structures.

## Overview

Swift comes with a wonderful tool for dumping the contents of any value to a string, and it's called
`dump`. It prints all the fields and sub-fields of a value into a tree-like description:

```swift
struct User {
  var favoriteNumbers: [Int]
  var id: Int
  var name: String
}

let user = User(
  favoriteNumbers: [42, 1729],
  id: 2,
  name: "Blob"
)

dump(user)
```
```text
▿ User
  ▿ favoriteNumbers: 2 elements
    - 42
    - 1729
  - id: 2
  - name: "Blob"
```

This is really useful, and can be great for building debug tools that visualize the data held in
runtime values of our applications, but sometimes its output is not ideal.

For example, dumping dictionaries leads to a verbose output that can be hard to read (also note that
the keys are unordered):

```swift
dump([1: "one", 2: "two", 3: "three"])
```
```text
▿ 3 key/value pairs
  ▿ (2 elements)
    - key: 2
    - value: "two"
  ▿ (2 elements)
    - key: 3
    - value: "three"
  ▿ (2 elements)
    - key: 1
    - value: "one"
```

Similarly enums have a very verbose output:

```swift
dump(Result<Int, Error>.success(42))
```
```text
▿ Swift.Result<Swift.Int, Swift.Error>.success
  - success: 42
```

It gets even harder to read when dealing with deeply nested structures:

```swift
dump([1: Result<User, Error>.success(user)])
```
```text
▿ 1 key/value pair
  ▿ (2 elements)
    - key: 1
    ▿ value: Swift.Result<User, Swift.Error>.success
      ▿ success: User
        ▿ favoriteNumbers: 2 elements
          - 42
          - 1729
        - id: 2
        - name: "Blob"
```

There are also times that `dump` simply does not print useful information, such as enums imported
from Objective-C:

```swift
import UserNotifications

dump(UNNotificationSetting.disabled)
```
```text
- __C.UNNotificationSetting
```

So, while the `dump` function can be handy, it is often too crude of a tool to use. This is the
motivation for the `customDump` function.

### customDump

The ``customDump(_:name:indent:maxDepth:)`` function emulates the behavior of `dump`, but provides a
more refined output of nested structures, optimizing for readability. For example, structs are
dumped in a format that more closely mimics the struct syntax in Swift, and arrays are dumped with
the indices of each element:

```swift
import CustomDump

customDump(user)
```
```text
User(
  favoriteNumbers: [
    [0]: 42,
    [1]: 1729
  ],
  id: 2,
  name: "Blob"
)
```

Dictionaries are dumped in a more compact format that mimics Swift's syntax, and automatically
orders the keys:

```swift
customDump([1: "one", 2: "two", 3: "three"])
```
```text
[
  1: "one",
  2: "two",
  3: "three"
]
```

Similarly, enums also dump in a more compact, readable format:

```swift
customDump(Result<Int, Error>.success(42))
```
```text
Result.success(42)
```

And deeply nested structures have a simplified tree-structure:

```swift
customDump([1: Result<User, Error>.success(user)])
```
```text
[
  1: Result.success(
    User(
      favoriteNumbers: [
        [0]: 42,
        [1]: 1729
      ],
      id: 2,
      name: "Blob"
    )
  )
]
```

### diff

Using the output of the `customDump` function we can build a very lightweight way to textually diff
any two values in Swift using the ``diff(_:_:format:)`` function:

```swift
var other = user
other.favoriteNumbers[1] = 91

print(diff(user, other)!)
```
```diff
  User(
    favoriteNumbers: [
      [0]: 42,
-     [1]: 1729
+     [1]: 91
    ],
    id: 2,
    name: "Blob"
  )
```

Further, extra work is done to minimize the size of the diff when parts of the structure haven't
changed, such as a single element changing in a large collection:

```swift
let users = (1...5).map {
  User(
    favoriteNumbers: [$0],
    id: $0,
    name: "Blob \($0)"
  )
}

var other = users
other.append(
  .init(
    favoriteNumbers: [42, 1729],
    id: 100,
    name: "Blob Sr."
  )
)

print(diff(users, other)!)
```
```diff
  [
    … (4 unchanged),
+   [4]: User(
+     favoriteNumbers: [
+       [0]: 42,
+       [1]: 1729
+     ],
+     id: 100,
+     name: "Blob Sr."
+   )
  ]
```

For a real world use case we modified Apple's
 [Landmarks](https://developer.apple.com/tutorials/swiftui/working-with-ui-controls) tutorial
application to print the before and after state when favoriting a landmark:

```diff
  [
    [0]: Landmark(
      id: 1001,
      name: "Turtle Rock",
      park: "Joshua Tree National Park",
      state: "California",
      description: "This very large formation lies south of the large Real Hidden Valley parking lot and immediately adjacent to (south of) the picnic areas.",
-     isFavorite: true,
+     isFavorite: false,
      isFeatured: true,
      category: Category.rivers,
      imageName: "turtlerock",
      coordinates: Coordinates(…)
    ),
    … (11 unchanged)
  ]
```

### XCTAssertNoDifference

The `XCTAssertEqual` function from `XCTest` allows you to assert that two values are equal, and if
they are not the test suite will fail with a message:

```swift
var other = user
other.name += "!"

XCTAssertEqual(user, other)
```
```text
XCTAssertEqual failed: ("User(favoriteNumbers: [42, 1729], id: 2, name: "Blob")") is not equal to ("User(favoriteNumbers: [42, 1729], id: 2, name: "Blob!")")
```

Unfortunately this failure message is quite difficult to visually parse and understand. It takes a
few moments of hunting through the message to see that the only difference is the exclamation mark
at the end of the name. The problem gets worse if the type is more complex, consisting of nested
structures and large collections.

This library also ships with an ``XCTAssertNoDifference(_:_:_:file:line:)`` function to mitigate
these problems. It works like `XCTAssertEqual` except the failure message uses a nicely formatted
diff to show exactly what is different between the two values:

```swift
XCTAssertNoDifference(user, other)
```
```diff
XCTAssertNoDifference failed: …

  User(
    favoriteNumbers: […],
    id: 2,
-   name: "Blob"
+   name: "Blob!"
  )

(First: -, Second: +)
```

### XCTAssertDifference

``XCTAssertDifference(_:_:operation:changes:file:line:)-8xfxw`` provides the inverse of
`XCTAssertNoDifference`: it asserts that a value has a set of changes by evaluating a given
expression before and after a given operation and then comparing the results.

For example, given a very simple counter structure, we can write a test against its incrementing
functionality:

```swift
struct Counter {
  var count = 0
  var isOdd = false
  mutating func increment() {
    self.count += 1
    self.isOdd.toggle()
  }
}

var counter = Counter()
XCTAssertDifference(counter) {
  counter.increment()
} changes: {
  $0.count = 1
  $0.isOdd = true
}
```

If the `changes` does not exhaustively describe all changed fields, the assertion will fail.

By omitting the operation you can write a "non-exhaustive" assertion against a value by describing
just the fields you want to assert against in the `changes` closure:

```swift
counter.increment()
XCTAssertDifference(counter) {
  $0.count = 1
  // Don't need to further describe how `isOdd` has changed
}
```

## Customization

Custom Dump provides a few important ways to customize how a data type is dumped:
``CustomDumpStringConvertible``, ``CustomDumpReflectable``, and ``CustomDumpRepresentable``.

### CustomDumpStringConvertible

The ``CustomDumpStringConvertible`` protocol provides a simple way of converting a type to a raw
string for the purpose of dumping. It is most appropriate for types that have a simple, un-nested
internal representation, and typically its output fits on a single line, for example dates, UUIDs,
URLs, etc:

```swift
extension URL: CustomDumpStringConvertible {
  public var customDumpDescription: String {
    "URL(\(self.absoluteString))"
  }
}

customDump(URL(string: "https://www.pointfree.co/")!)
```
```text
URL(https://www.pointfree.co/)
```

Custom Dump also uses this protocol internally to provide more useful output for enums imported from
Objective-C:

```swift
import UserNotifications

print("dump:")
dump(UNNotificationSetting.disabled)
print("customDump:")
customDump(UNNotificationSetting.disabled)
```
```text
dump:
- __C.UNNotificationSetting
customDump:
UNNotificationSettings.disabled
```

### CustomDumpReflectable

The ``CustomDumpReflectable`` protocol provides a more comprehensive way of dumping a type into a
more structured output. It allows you to construct a custom mirror that describes the structure that
should be dumped. You can omit, add, and replace fields, or even change the "display style" of how
the structure is dumped.

For example, let's say you have a struct representing state that holds a secure token in memory that
should never be written to your logs. You can omit the token from `customDump` by providing a mirror
that omits this field:

```swift
struct LoginState: CustomDumpReflectable {
  var username: String
  var token: String

  var customDumpMirror: Mirror {
    .init(
      self,
      children: [
        "username": self.username,
        // omit token from logs
      ],
      displayStyle: .struct
    )
  }
}

customDump(
  LoginState(
    username: "blob",
    token: "secret"
  )
)
```
```text
LoginState(username: "blob")
```

And just like that, no token data will be written to the dump.

### `CustomDumpRepresentable`

The `CustomDumpRepresentable` protocol allows you to return _any_ value for the purpose of dumping.
This can be useful to flatten the dump representation of wrapper types. For example, a type-safe
identifier may want to dump its raw value directly:

```swift
struct ID: RawRepresentable {
  var rawValue: String
}

extension ID: CustomDumpRepresentable {
  var customDumpValue: Any {
    self.rawValue
  }
}

customDump(ID(rawValue: "deadbeef")
```
```text
"deadbeef"
```

## Topics

### Dumping

- ``customDump(_:name:indent:maxDepth:)``
- ``customDump(_:to:name:indent:maxDepth:)``

### Diffing

- ``diff(_:_:format:)``

### Test support

- ``expectNoDifference(_:_:_:fileID:filePath:line:column:)``
- ``expectDifference(_:_:operation:changes:fileID:filePath:line:column:)-5fu8q``

### Customizing output

- ``CustomDumpStringConvertible``
- ``CustomDumpRepresentable``
- ``CustomDumpReflectable``

### Deprecations
