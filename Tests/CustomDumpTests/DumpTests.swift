import CustomDump
import XCTest

#if canImport(CoreGraphics)
  import CoreGraphics
#endif

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

#if canImport(SwiftUI)
  import SwiftUI
#endif

#if os(Windows)
  let unknownContext = "."
#else
  let unknownContext = ".(unknown context).(unknown context)."
#endif

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
final class DumpTests: XCTestCase {
  func testAnyType() {
    var dump = ""
    customDump(Foo.Bar.self, to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      Foo.Bar.self
      """
    )
  }

  func testClass() {
    let user = UserClass(
      id: 42,
      name: "Blob"
    )

    var dump = ""
    customDump(user, to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      UserClass(
        id: 42,
        name: "Blob"
      )
      """
    )

    dump = ""
    customDump(user, to: &dump, maxDepth: 0)
    XCTAssertNoDifference(
      dump,
      """
      UserClass(…)
      """
    )

    let foo = RecursiveFoo()
    foo.foo = foo

    dump = ""
    customDump(foo, to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      RecursiveFoo(
        foo: RecursiveFoo(↩︎)
      )
      """
    )
  }

  func testCollection() {
    let users = [
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
    ]

    var dump = ""
    customDump(users, to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      [
        [0]: User(
          id: 1,
          name: "Blob"
        ),
        [1]: User(
          id: 2,
          name: "Blob, Jr."
        ),
        [2]: User(
          id: 3,
          name: "Blob, Sr."
        )
      ]
      """
    )

    dump = ""
    customDump(users, to: &dump, maxDepth: 1)
    XCTAssertNoDifference(
      dump,
      """
      [
        [0]: User(…),
        [1]: User(…),
        [2]: User(…)
      ]
      """
    )

    dump = ""
    customDump(users, to: &dump, maxDepth: 0)
    XCTAssertNoDifference(
      dump,
      """
      […]
      """
    )
  }

  func testDictionary() {
    var dump = ""
    customDump(
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
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      [
        1: User(
          id: 1,
          name: "Blob"
        ),
        2: User(
          id: 2,
          name: "Blob, Jr."
        )
      ]
      """
    )

    dump = ""
    customDump(
      [
        ID(rawValue: "deadbeef"): User(
          id: 1,
          name: "Blob"
        ),
        ID(rawValue: "beefdead"): User(
          id: 2,
          name: "Blob, Jr."
        ),
      ],
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      [
        ID(rawValue: "beefdead"): User(
          id: 2,
          name: "Blob, Jr."
        ),
        ID(rawValue: "deadbeef"): User(
          id: 1,
          name: "Blob"
        )
      ]
      """
    )
  }

  func testEnum() {
    var dump = ""
    customDump(Enum.foo, to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      Enum.foo
      """
    )

    dump = ""
    customDump(Enum.bar(42), to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      Enum.bar(42)
      """
    )

    dump = ""
    customDump(Enum.fu(bar: 42), to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      Enum.fu(bar: 42)
      """
    )

    dump = ""
    customDump(Enum.baz(fizz: 0.9, buzz: "2"), to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      Enum.baz(
        fizz: 0.9,
        buzz: "2"
      )
      """
    )

    dump = ""
    customDump(Enum.fizz(0.9, buzz: "2"), to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      Enum.fizz(
        0.9,
        buzz: "2"
      )
      """
    )
  }

  func testOptional() {
    var dump = ""
    customDump(User?(.init(id: 42, name: "Blob")), to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      User(
        id: 42,
        name: "Blob"
      )
      """
    )

    dump = ""
    customDump(User?(nil), to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      nil
      """
    )
  }

  func testSet() {
    var dump = ""
    customDump(Set([1, 2, 3]), to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      Set([
        1,
        2,
        3
      ])
      """
    )
  }

  func testSingleValue() {
    var dump = ""
    customDump(1, to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      1
      """
    )

    dump = ""
    customDump(true, to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      true
      """
    )
  }

  func testStruct() {
    let user = User(
      id: 42,
      name: "Blob"
    )

    var dump = ""
    customDump(user, to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      User(
        id: 42,
        name: "Blob"
      )
      """
    )

    dump = ""
    customDump(user, to: &dump, maxDepth: 0)
    XCTAssertNoDifference(
      dump,
      """
      User(…)
      """
    )

    let pair = Pair(
      driver: User(
        id: 1,
        name: "Blob"
      ),
      passenger: User(
        id: 2,
        name: "Blob, Jr."
      )
    )

    dump = ""
    customDump(pair, to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      Pair(
        driver: User(
          id: 1,
          name: "Blob"
        ),
        passenger: User(
          id: 2,
          name: "Blob, Jr."
        )
      )
      """
    )

    dump = ""
    customDump(pair, to: &dump, maxDepth: 1)
    XCTAssertNoDifference(
      dump,
      """
      Pair(
        driver: User(…),
        passenger: User(…)
      )
      """
    )
  }

  func testTuple() {
    var dump = ""
    customDump((1, 2), to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      (
        1,
        2
      )
      """
    )

    dump = ""
    customDump((x: 1, y: 2, ()), to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      (
        x: 1,
        y: 2,
        ()
      )
      """
    )
  }

  func testMultilineString() {
    var dump = ""
    customDump("Hello,\nWorld!", to: &dump)
    XCTAssertNoDifference(
      dump,
      #"""
      """
      Hello,
      World!
      """
      """#
    )

    dump = ""
    customDump("Hello,\nWorld!"[...], to: &dump)
    XCTAssertNoDifference(
      dump,
      #"""
      """
      Hello,
      World!
      """
      """#
    )

    dump = ""
    customDump(
      Email(
        subject: "RE: Upcoming Event",
        body: """
          To whom it may concern,

          Look forward to it!

          Yours,
          Blob
          """
      ),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      Email(
        subject: "RE: Upcoming Event",
        body: \"\"\"
          To whom it may concern,
          \n\
          Look forward to it!
          \n\
          Yours,
          Blob
          \"\"\"
      )
      """
    )

    dump = ""
    customDump(
      ##"""
      print(
        #"""
        Hello, world!
        """#
      )
      """##,
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      ###"""
      ##"""
      print(
        #"""
        Hello, world!
        """#
      )
      """##
      """###
    )
  }

  func testAnyHashable() {
    var dump = ""
    customDump(AnyHashable(42), to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      42
      """
    )

    dump = ""
    customDump(
      [
        AnyHashable(1): User(id: 1, name: "Blob"),
        AnyHashable("Blob, Jr."): User(id: 2, name: "Blob, Jr."),
      ],
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      [
        "Blob, Jr.": User(
          id: 2,
          name: "Blob, Jr."
        ),
        1: User(
          id: 1,
          name: "Blob"
        )
      ]
      """
    )
  }

  #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
    func testKeyPath() {
      var dump = ""

      // Run twice to exercise cached lookup
      for _ in 1...2 {
        dump = ""
        customDump(\UserClass.name, to: &dump)
        XCTAssertNoDifference(
          dump,
          #"""
          \UserClass.name
          """#
        )

        dump = ""
        customDump(\Pair.driver.name, to: &dump)
        XCTAssertNoDifference(
          dump,
          #"""
          \Pair.driver.name
          """#
        )

        dump = ""
        customDump(\User.name.count, to: &dump)
        XCTAssertNoDifference(
          dump,
          #"""
          KeyPath<User, Int>
          """#
        )

        dump = ""
        customDump(\(x: Double, y: Double).x, to: &dump)
        XCTAssertNoDifference(
          dump,
          #"""
          WritableKeyPath<(x: Double, y: Double), Double>
          """#
        )
      }
    }
  #endif

  func testNamespacedTypes() {
    var dump = ""
    customDump(
      Namespaced.Class(x: 0),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      Namespaced.Class(x: 0)
      """
    )

    dump = ""
    customDump(
      Namespaced.Enum.x(0),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      Namespaced.Enum.x(0)
      """
    )

    dump = ""
    customDump(
      Namespaced.Struct(x: 0),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      Namespaced.Struct(x: 0)
      """
    )
  }

  func testGenerics() {
    var dump = ""
    customDump(
      Result<Result<Int, Error>, Error>.success(.success(42)),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      Result.success(
        Result.success(42)
      )
      """
    )
  }

  func testUnknownContexts() {
    struct Inline {}

    var dump = ""
    customDump(
      Inline.self,
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      DumpTests\(unknownContext)Inline.self
      """
    )

    dump = ""
    customDump(
      Inline(),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      DumpTests\(unknownContext)Inline()
      """
    )
  }

  func testCustomMirror() {
    var dump = ""
    customDump(Button(), to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      Button.cancel(
        action: nil,
        label: "Cancel"
      )
      """
    )

    dump = ""
    customDump(
      LoginState(
        email: "blob@pointfree.co",
        password: "bl0bisawesome!",
        token: "secret"
      ),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      LoginState(
        email: "blob@pointfree.co",
        password: <redacted>
      )
      """
    )
  }

  func testCustomOverride() {
    var dump = ""
    customDump(Wrapper(rawValue: 42), to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      42
      """
    )
  }

  func testStandardLibrary() {
    var dump = ""
    customDump("©" as Character, to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      "©"
      """
    )

    dump = ""
    customDump("Blob" as StaticString, to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      "Blob"
      """
    )

    dump = ""
    customDump("©" as UnicodeScalar, to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      "©"
      """
    )
  }

  func testFoundation() {
    var dump = ""

    #if compiler(>=5.5) && !os(macOS) && !os(Linux)
      if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
        dump = ""
        customDump(
          try? AttributedString(markdown: "Hello, **Blob**!"),
          to: &dump
        )
        XCTAssertNoDifference(
          dump,
          """
          "Hello, Blob!"
          """
        )
      }
    #endif

    // NB: `CFNumber` is unavailable on Linux
    #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
      dump = ""
      customDump(
        42 as CFNumber,
        to: &dump
      )
      XCTAssertNoDifference(
        dump,
        """
        42
        """
      )
    #endif

    dump = ""
    customDump(
      Date(timeIntervalSince1970: 0),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      Date(1970-01-01T00:00:00.000Z)
      """
    )

    #if compiler(>=5.4)
      dump = ""
      customDump(
        NestedDate(date: Date(timeIntervalSince1970: 0)),
        to: &dump
      )
      XCTAssertNoDifference(
        dump,
        """
        NestedDate(date: Date(1970-01-01T00:00:00.000Z))
        """
      )
    #endif

    dump = ""
    customDump(
      Decimal(string: "1.23"),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      1.23
      """
    )

    dump = ""
    customDump(
      [1, 2, 3] as NSArray,
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      [
        [0]: 1,
        [1]: 2,
        [2]: 3
      ]
      """
    )

    let attributedString = NSMutableAttributedString(string: "")
    attributedString.append(NSAttributedString(string: "Hello, "))
    attributedString.append(
      NSAttributedString(string: "Blob", attributes: [.init(rawValue: "name"): true])
    )
    attributedString.append(NSAttributedString(string: "!"))
    dump = ""
    customDump(
      attributedString,
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      "Hello, Blob!"
      """
    )

    let calendar = NSCalendar(calendarIdentifier: .gregorian)!
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    dump = ""
    customDump(
      calendar,
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      Calendar(
        identifier: Calendar.Identifier.gregorian,
        locale: Locale(),
        timeZone: TimeZone(
          identifier: "GMT",
          abbreviation: "GMT",
          secondsFromGMT: 0,
          isDaylightSavingTime: false
        ),
        firstWeekday: 1,
        minimumDaysInFirstWeek: 1
      )
      """
    )

    dump = ""
    customDump(
      NSCountedSet(array: [1, 2, 2, 3, 3, 3]),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      Set([
        1,
        2,
        3
      ])
      """
    )

    dump = ""
    customDump(
      NSData(data: .init(repeating: 0, count: 4)),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      Data(4 bytes)
      """
    )

    dump = ""
    customDump(
      NSDate(timeIntervalSince1970: 0),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      Date(1970-01-01T00:00:00.000Z)
      """
    )

    dump = ""
    customDump(
      [1: "1", 2: "2", 3: "3"] as NSDictionary,
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      [
        1: "1",
        2: "2",
        3: "3"
      ]
      """
    )

    dump = ""
    customDump(
      NSError(
        domain: "co.pointfree",
        code: 42,
        userInfo: [
          NSLocalizedDescriptionKey: "An error occurred" as NSString
        ]
      ),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      NSError(
        domain: "co.pointfree",
        code: 42,
        userInfo: [
          "NSLocalizedDescription": "An error occurred"
        ]
      )
      """
    )

    #if !os(Windows)
    class SubclassedError: NSError {}

    dump = ""
    customDump(
      SubclassedError(
        domain: "co.pointfree",
        code: 43,
        userInfo: [
          NSLocalizedDescriptionKey: "An error occurred" as NSString
        ]
      ),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      NSError(
        domain: "co.pointfree",
        code: 43,
        userInfo: [
          "NSLocalizedDescription": "An error occurred"
        ]
      )
      """
    )
    #endif

    enum BridgedError: Error {
      case thisIsFine(Int)
    }

    dump = ""
    customDump(BridgedError.thisIsFine(94) as NSError, to: &dump)
    #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
      XCTAssertNoDifference(
        dump,
        """
        DumpTests\(unknownContext)BridgedError.thisIsFine(94)
        """
      )
    #else
      // Can't unwrap bridged Errors on Linux: https://bugs.swift.org/browse/SR-15191
      XCTAssertNoDifference(
        dump,
        """
        NSError(
          domain: "CustomDumpTests.DumpTests.BridgedError",
          code: 0,
          userInfo: [:]
        )
        """
      )
    #endif

    // NB: `NSException` is unavailable on Linux
    #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
      dump = ""
      customDump(
        NSException(name: .genericException, reason: "Oops!", userInfo: nil),
        to: &dump
      )
      XCTAssertNoDifference(
        dump,
        """
        NSException(
          name: NSGenericException,
          reason: "Oops!",
          userInfo: nil
        )
        """
      )
    #endif

    // NB: `NSExpression` is unavailable on Linux
    #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
      dump = ""
      customDump(
        NSExpression(format: "1 + 1"),
        to: &dump
      )
      XCTAssertNoDifference(
        dump,
        """
        1 + 1
        """
      )
    #endif

    dump = ""
    customDump(
      NSIndexPath(),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      []
      """
    )

    dump = ""
    customDump(
      NSIndexSet(indexSet: [1, 2, 3, 5, 7]),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      IndexSet(
        ranges: [
          [0]: 1..<4,
          [1]: 5..<6,
          [2]: 7..<8
        ]
      )
      """
    )

    dump = ""
    customDump(
      NSLocale(localeIdentifier: "en_US"),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      Locale(en_US)
      """
    )

    dump = ""
    customDump(
      NSMeasurement(doubleValue: 42, unit: Unit(symbol: "kg")),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      Measurement(
        value: 42.0,
        unit: "kg"
      )
      """
    )

    dump = ""
    customDump(
      NSNotification(name: .init(rawValue: "co.pointfree"), object: nil, userInfo: nil),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      Notification(name: "co.pointfree")
      """
    )

    dump = ""
    customDump(
      NSNull(),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      NSNull()
      """
    )

    dump = ""
    customDump(
      NSNumber(booleanLiteral: true),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      1
      """
    )

    dump = ""
    customDump(
      [1, 2, 3] as NSOrderedSet,
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      [
        [0]: 1,
        [1]: 2,
        [2]: 3
      ]
      """
    )

    dump = ""
    customDump(
      NSRange(0..<1),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      0..<1
      """
    )

    dump = ""
    customDump(
      NSSet(array: [1, 2, 3]),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      Set([
        1,
        2,
        3
      ])
      """
    )

    dump = ""
    customDump(
      NSTimeZone(forSecondsFromGMT: 0),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      TimeZone(
        identifier: "GMT",
        abbreviation: "GMT",
        secondsFromGMT: 0,
        isDaylightSavingTime: false
      )
      """
    )

    dump = ""
    customDump(
      NSURL(fileURLWithPath: "/tmp"),
      to: &dump
    )
    #if os(Windows)
      XCTAssertNoDifference(
        dump,
        """
        URL(file:///tmp)
        """
      )
    #else
      XCTAssertNoDifference(
        dump,
        """
        URL(file:///tmp/)
        """
      )
    #endif

    dump = ""
    customDump(
      NSURLComponents(string: "https://www.pointfree.co/login?redirect=episodes"),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      URLComponents(
        scheme: "https",
        host: "www.pointfree.co",
        path: "/login",
        queryItems: [
          [0]: URLQueryItem(
            name: "redirect",
            value: "episodes"
          )
        ]
      )
      """
    )

    dump = ""
    customDump(
      NSURLQueryItem(name: "search", value: "composable architecture"),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      URLQueryItem(
        name: "search",
        value: "composable architecture"
      )
      """
    )

    dump = ""
    let request = NSMutableURLRequest(url: URL(string: "https://www.pointfree.co")!)
    request.addValue("text/html", forHTTPHeaderField: "Accept")
    request.httpShouldUsePipelining = false
    customDump(
      request,
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      URLRequest(
        url: URL(https://www.pointfree.co),
        cachePolicy: 0,
        timeoutInterval: 60.0,
        mainDocumentURL: nil,
        networkServiceType: URLRequest.NetworkServiceType.default,
        allowsCellularAccess: true,
        httpMethod: "GET",
        allHTTPHeaderFields: [
          "Accept": "text/html"
        ],
        httpBody: nil,
        httpBodyStream: nil,
        httpShouldHandleCookies: true,
        httpShouldUsePipelining: false
      )
      """
    )

    dump = ""
    customDump(
      NSUUID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef"),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      UUID(DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF)
      """
    )

    dump = ""
    customDump(
      URL(string: "https://www.pointfree.co/"),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      URL(https://www.pointfree.co/)
      """
    )
  }

  #if canImport(CoreGraphics)
    func testCoreGraphics() {
      var dump = ""
      customDump(
        CGRect(x: 0.5, y: 0.5, width: 1.5, height: 1.5),
        to: &dump
      )
      XCTAssertNoDifference(
        dump,
        """
        CGRect(
          origin: CGPoint(
            x: 0.5,
            y: 0.5
          ),
          size: CGSize(
            width: 1.5,
            height: 1.5
          )
        )
        """
      )
    }
  #endif

  #if canImport(SwiftUI)
    func testSwiftUI() {
      var dump = ""
      customDump(
        Animation.easeInOut,
        to: &dump
      )
      XCTAssertNoDifference(
        dump,
        """
        Animation.easeInOut
        """
      )
    }
  #endif
}
