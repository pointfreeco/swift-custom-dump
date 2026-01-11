import CustomDump
import Foundation
import IssueReportingTestSupport

#if canImport(XCTest)
import XCTest

#if canImport(Testing)
  import Testing

  @Suite
  struct ExpectNoDifferenceTests {
    @Test func basics() {
      struct User: Equatable {
        var id: UUID
        var name: String
        var bio: String
      }
      let user = User(
        id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")!,
        name: "Blob",
        bio: "Blobbed around the world."
      )
      var otherUser = user
      otherUser.name += " Jr."
      withKnownIssue {
        expectNoDifference(user, otherUser)
      } matching: {
        $0.description == """
          Issue recorded (error): Difference: …

              ExpectNoDifferenceTests.User(
                id: UUID(DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF),
            −   name: "Blob",
            +   name: "Blob Jr.",
                bio: "Blobbed around the world."
              )

          (First: −, Second: +)
          """
      }
    }
  }
#endif

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
class ExpectNoDifferenceXCTests: XCTestCase {
  #if DEBUG && compiler(>=5.4) && (os(iOS) || os(macOS) || os(tvOS) || os(watchOS))
    func testExpectNoDifference() {
      XCTExpectFailure()

      let user = User(id: 42, name: "Blob")
      var other = user
      other.name += " Sr."

      expectNoDifference(user, other)
    }
  #endif
}
#endif
