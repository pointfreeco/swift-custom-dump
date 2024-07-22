#if canImport(Testing)
  import CustomDump
  import Foundation
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
          Expectation failed: Difference: …

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
