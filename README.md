# Custom Dump

[![CI](https://github.com/pointfreeco/swift-custom-dump/actions/workflows/ci.yml/badge.svg)](https://github.com/pointfreeco/swift-custom-dump/actions/workflows/ci.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fpointfreeco%2Fswift-custom-dump%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/pointfreeco/swift-custom-dump)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fpointfreeco%2Fswift-custom-dump%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/pointfreeco/swift-custom-dump)

A collection of tools for debugging, diffing, and testing your application's data structures.

  * [Motivation](#motivation)
      * [`customDump`](#customdump)
      * [`diff`](#diff)
      * [`XCTAssertNoDifference`](#xctassertnodifference)
  * [Customization](#customization)
      * [`CustomDumpStringConvertible`](#customdumpstringconvertible)
      * [`CustomDumpReflectable`](#customdumpreflectable)
      * [`CustomDumpRepresentable`](#customdumprepresentable)
  * [Contributing](#contributing)
  * [Installation](#installation)
  * [Documentation](#documentation)
  * [Other Libraries](#other-libraries)
  * [License](#license)

## Motivation

Swift comes with a wonderful tool for dumping the contents of any value to a string, and it's called `dump`. It prints all the fields and sub-fields of a value into a tree-like description:

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

This is really useful, and can be great for building debug tools that visualize the data held in runtime values of our applications, but sometimes its output is not ideal.

For example, dumping dictionaries leads to a verbose output that can be hard to read (also note that the keys are unordered):

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

There are also times that `dump` simply does not print useful information, such as enums imported from Objective-C:

```swift
import UserNotifications

dump(UNNotificationSetting.disabled)
```
```text
- __C.UNNotificationSetting
```

So, while the `dump` function can be handy, it is often too crude of a tool to use. This is the motivation for the `customDump` function.

### `customDump`

The `customDump` function emulates the behavior of `dump`, but provides a more refined output of nested structures, optimizing for readability. For example, structs are dumped in a format that more closely mimics the struct syntax in Swift, and arrays are dumped with the indices of each element:

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

Dictionaries are dumped in a more compact format that mimics Swift's syntax, and automatically orders the keys:

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

### `diff`

Using the output of the `customDump` function we can build a very lightweight way to textually diff any two values in Swift:

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

Further, extra work is done to minimize the size of the diff when parts of the structure haven't changed, such as a single element changing in a large collection:

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

For a real world use case we modified Apple's [Landmarks](https://developer.apple.com/tutorials/swiftui/working-with-ui-controls) tutorial application to print the before and after state when favoriting a landmark:

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

### `XCTAssertNoDifference`

The `XCTAssertEqual` function from `XCTest` allows you to assert that two values are equal, and if they are not the test suite will fail with a message:

```swift
var other = user
other.name += "!"

XCTAssertEqual(user, other)
```
```text
XCTAssertEqual failed: ("User(favoriteNumbers: [42, 1729], id: 2, name: "Blob")") is not equal to ("User(favoriteNumbers: [42, 1729], id: 2, name: "Blob!")")
```

Unfortunately this failure message is quite difficult to visually parse and understand. It takes a few moments of hunting through the message to see that the only difference is the exclamation mark at the end of the name. The problem gets worse if the type is more complex, consisting of nested structures and large collections.

This library also ships with an `XCTAssertNoDifference` function to mitigate these problems. It works like `XCTAssertEqual` except the failure message uses a nicely formatted diff to show exactly what is different between the two values:

```swift
XCTAssertNoDifference(user, other)
```
```text
XCTAssertNoDifference failed: …

    User(
      favoriteNumbers: […],
      id: 2,
  −   name: "Blob"
  +   name: "Blob!"
    )

(First: −, Second: +)
```

## Customization

Custom Dump provides a few important ways to customize how a data type is dumped: `CustomDumpStringConvertible`, `CustomDumpReflectable`, and `CustomDumpRepresentable`.

### `CustomDumpStringConvertible`

The `CustomDumpStringConvertible` protocol provides a simple way of converting a type to a raw string for the purpose of dumping. It is most appropriate for types that have a simple, un-nested internal representation, and typically its output fits on a single line, for example dates, UUIDs, URLs, etc:

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

Custom Dump also uses this protocol internally to provide more useful output for enums imported from Objective-C:

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

Encounter an Objective-C enum that doesn't print nicely? See the [contributing](#contributing) section of this README to help submit a fix.

### `CustomDumpReflectable`

The `CustomDumpReflectable` protocol provides a more comprehensive way of dumping a type into a more structured output. It allows you to construct a custom mirror that describes the structure that should be dumped. You can omit, add, and replace fields, or even change the "display style" of how the structure is dumped.

For example, let's say you have a struct representing state that holds a secure token in memory that should never be written to your logs. You can omit the token from `customDump` by providing a mirror that omits this field:

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

The `CustomDumpRepresentable` protocol allows you to return _any_ value for the purpose of dumping. This can be useful to flatten the dump representation of wrapper types. For example, a type-safe identifier may want to dump its raw value directly:

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

## Contributing

There are many types in Apple's ecosystem that do not dump to a nicely formatted string. In particular, all enums that are imported from Objective-C dump to strings that are not very helpful:

```swift
import UserNotifications

dump(UNNotificationSetting.disabled)
```
```text
- __C.UNNotificationSetting
```

For this reason we have conformed a [bunch](Sources/CustomDump/Conformances) of Apple's types to the `CustomDumpStringConvertible` protocol so that they print out more reasonable descriptions. If you come across types that do not print useful information then we would happily accept a PR to conform those types to `CustomDumpStringConvertible`.

## Installation

You can add Custom Dump to an Xcode project by adding it as a package dependency.

> https://github.com/pointfreeco/swift-custom-dump

If you want to use Custom Dump in a [SwiftPM](https://swift.org/package-manager/) project, it's as simple as adding it to a `dependencies` clause in your `Package.swift`:

``` swift
dependencies: [
  .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "0.3.0")
]
```

## Documentation

The latest documentation for the Custom Dump APIs is available [here](https://pointfreeco.github.io/swift-custom-dump/).

## Other libraries

* [Difference](https://github.com/krzysztofzablocki/Difference)
* [MirrorDiffKit](https://github.com/Kuniwak/MirrorDiffKit)

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
