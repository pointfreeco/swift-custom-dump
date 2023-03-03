import CustomDump
import XCTest

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
class XCTAssertNoDifferenceTests: XCTestCase {
  #if DEBUG && compiler(>=5.4) && (os(iOS) || os(macOS) || os(tvOS) || os(watchOS))
    func testXCTAssertNoDifference() {
      XCTExpectFailure()

      let user = User(id: 42, name: "Blob")
      var other = user
      other.name += " Sr."

      XCTAssertNoDifference(user, other)
    }

    func testXCTAssertNoDifferenceNonEquatable() {
      struct Thing {
        indirect enum Choice { case a, b(String), c(Thing) }
        var id: Int
        var choice: Choice
      }

      let thing1 = Thing(id: 1, choice: .a)
      let thing2 = Thing(id: 2, choice: .a)
      let thing3 = Thing(id: 1, choice: .b(""))
      let thing4 = Thing(id: 1, choice: .b("x"))
      let thing5 = Thing(id: 1, choice: .c(thing))
      let thing6 = Thing(id: 1, choice: .c(thing2))

      #if compiler(>=5.7)
        XCTAssertFalse(thing1 is any Equatable)
        XCTAssertFalse(thing1.choice is any Equatable)
      #endif

      XCTAssertNoDifference(thing1, thing1)
      XCTAssertNoDifference(thing2, thing2)
      XCTAssertNoDifference(thing3, thing3)
      XCTAssertNoDifference(thing4, thing4)
      XCTAssertNoDifference(thing5, thing5)
      XCTAssertNoDifference(thing6, thing6)

      XCTExpectFailure { XCTAssertNoDifference(thing1, thing2) }
      XCTExpectFailure { XCTAssertNoDifference(thing1, thing3) }
      XCTExpectFailure { XCTAssertNoDifference(thing1, thing4) }
      XCTExpectFailure { XCTAssertNoDifference(thing1, thing5) }
      XCTExpectFailure { XCTAssertNoDifference(thing1, thing6) }

      XCTExpectFailure { XCTAssertNoDifference(thing2, thing3) }
      XCTExpectFailure { XCTAssertNoDifference(thing2, thing4) }
      XCTExpectFailure { XCTAssertNoDifference(thing2, thing5) }
      XCTExpectFailure { XCTAssertNoDifference(thing2, thing6) }

      XCTExpectFailure { XCTAssertNoDifference(thing3, thing4) }
      XCTExpectFailure { XCTAssertNoDifference(thing3, thing5) }
      XCTExpectFailure { XCTAssertNoDifference(thing3, thing6) }

      XCTExpectFailure { XCTAssertNoDifference(thing4, thing5) }
      XCTExpectFailure { XCTAssertNoDifference(thing4, thing6) }

      XCTExpectFailure { XCTAssertNoDifference(thing5, thing6) }
    }
  #endif
}
