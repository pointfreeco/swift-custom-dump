import CustomDump
import Foundation
import XCTest

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class FoundationTests: XCTestCase {
  func testAttributedString() {
    #if compiler(>=5.5) && !targetEnvironment(macCatalyst) && (os(iOS) || os(tvOS) || os(watchOS))
      if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
        var dump = ""
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
  }

  func testCFNumber() {
    // NB: `CFNumber` is unavailable on Linux
    #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
      var dump = ""
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
  }

  #if !os(WASI)
    func testDate() {
      var dump = ""
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
    }
  #endif

  func testDecimal() {
    var dump = ""
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
  }

  func testNSArray() {
    var dump = ""
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
  }

  func testNSAttributedString() {
    let attributedString = NSMutableAttributedString(string: "")
    attributedString.append(NSAttributedString(string: "Hello, "))
    attributedString.append(
      NSAttributedString(string: "Blob", attributes: [.init(rawValue: "name"): true])
    )
    attributedString.append(NSAttributedString(string: "!"))
    var dump = ""
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
  }

  func testNSCalendar() {
    let calendar = NSCalendar(calendarIdentifier: .gregorian)!
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    var dump = ""
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
  }

  func testNSCountedSet() {
    var dump = ""
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
  }

  #if !os(WASI)
    func testNSData() {
      var dump = ""
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
    }
  #endif

  #if !os(WASI)
    func testNSDate() {
      var dump = ""
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
    }
  #endif

  func testNSDictionary() {
    var dump = ""
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
  }

  func testNSError() {
    var dump = ""
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

    #if !os(Windows) && !os(WASI)
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
        FoundationTests.BridgedError.thisIsFine(94)
        """
      )
    #elseif compiler(>=5.4)
      // Can't unwrap bridged Errors on Linux: https://bugs.swift.org/browse/SR-15191
      XCTAssertNoDifference(
        dump.replacingOccurrences(
          of: #"\(unknown context at \$[[:xdigit:]]+\)\."#,
          with: "",
          options: .regularExpression
        ),
        """
        NSError(
          domain: "CustomDumpTests.FoundationTests.BridgedError",
          code: 0,
          userInfo: [:]
        )
        """
      )
    #endif
  }

  func testNSException() {
    // NB: `NSException` is unavailable on Linux
    #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
      var dump = ""
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
  }

  func testNSExpression() {
    // NB: `NSExpression` is unavailable on Linux
    #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
      var dump = ""
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
  }

  func testNSIndexPath() {
    var dump = ""
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
  }

  func testNSIndexSet() {
    var dump = ""
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
  }

  func testNSLocale() {
    var dump = ""
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
  }

  func testNSMeasurement() {
    var dump = ""
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
  }

  #if !os(WASI)
    func testNSNotification() {
      var dump = ""
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
    }
  #endif

  func testNSNull() {
    var dump = ""
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
  }

  func testNSNumber() {
    var dump = ""
    customDump(
      1 as NSNumber,
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      1
      """
    )

    #if canImport(ObjectiveC)
      dump = ""
      customDump(
        NSNumber(),
        to: &dump
      )
      XCTAssertNoDifference(
        dump,
        """
        (null pointer)
        """
      )
    #endif
  }

  func testNSOrderedSet() {
    var dump = ""
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
  }

  func testNSRange() {
    var dump = ""
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
  }

  func testNSSet() {
    var dump = ""
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
  }

  #if !os(WASI)
    func testNSTimeZone() {
      var dump = ""
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
    }
  #endif

  func testNSURL() {
    var dump = ""
    customDump(
      NSURL(fileURLWithPath: "/tmp"),
      to: &dump
    )
    #if os(Windows) || os(WASI)
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
  }

  func testNSURLComponents() {
    var dump = ""
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
  }

  func testNSURLQueryItem() {
    var dump = ""
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
  }

  #if !os(WASI)
    func testNSURLRequest() {
      var dump = ""
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
    }
  #endif

  func testNSUUID() {
    var dump = ""
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
  }

  func testURL() {
    var dump = ""
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
}
