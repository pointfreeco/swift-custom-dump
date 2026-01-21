#if swift(>=5.9) && canImport(SwiftData)
  import CustomDump
  import SwiftData
  import XCTest

  @available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
  final class SwiftDataTests: XCTestCase {
    func testModel() throws {
      let schema = Schema([BucketListItem.self, LivingAccommodation.self, Trip.self])
      let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
      let container = try ModelContainer(for: schema, configurations: [configuration])
      let context = ModelContext(container)

      let trip = Trip(
        name: "Outer Borough Trip #1",
        destination: "Brooklyn, NY",
        startDate: Date(timeIntervalSinceReferenceDate: 0),
        endDate: Date(timeIntervalSinceReferenceDate: 60 * 60 * 24 * 7)
      )
      context.insert(trip)

      let bucketListItem = BucketListItem(
        title: "Brooklyn Bridge Park",
        details: """
          Explore the sweeping vistas, rich ecology, expansive piers, and vibrant programming of \
          this special waterfront park
          """,
        hasReservation: false,
        isInPlan: false
      )
      context.insert(bucketListItem)
      trip.bucketList.append(bucketListItem)

      let livingAccommodation = LivingAccommodation(
        address: """
          60 Furman St
          Brooklyn, NY 11201
          """,
        placeName: "1 Hotel Brooklyn Bridge"
      )
      context.insert(livingAccommodation)
      trip.livingAccommodation = livingAccommodation

      XCTAssertNoDifference(
        String(customDumping: trip),
        #"""
        Trip(
          destination: "Brooklyn, NY",
          endDate: Date(2001-01-08T00:00:00.000Z),
          name: "Outer Borough Trip #1",
          startDate: Date(2001-01-01T00:00:00.000Z),
          bucketList: [
            [0]: BucketListItem(
              details: "Explore the sweeping vistas, rich ecology, expansive piers, and vibrant programming of this special waterfront park",
              hasReservation: false,
              isInPlan: false,
              title: "Brooklyn Bridge Park",
              trip: Trip(↩︎)
            )
          ],
          livingAccommodation: LivingAccommodation(
            address: """
              60 Furman St
              Brooklyn, NY 11201
              """,
            placeName: "1 Hotel Brooklyn Bridge",
            trip: Trip(↩︎)
          )
        )
        """#
      )
    }
  }

  @available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
  @Model final class BucketListItem {
    var details: String
    var hasReservation: Bool
    var isInPlan: Bool
    var title: String
    var trip: Trip?

    init(title: String, details: String, hasReservation: Bool, isInPlan: Bool) {
      self.title = title
      self.details = details
      self.hasReservation = hasReservation
      self.isInPlan = isInPlan
    }
  }

  @available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
  @Model final class LivingAccommodation {
    var address: String
    var placeName: String
    var trip: Trip?

    init(address: String, placeName: String) {
      self.address = address
      self.placeName = placeName
    }
  }

  @available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
  @Model final class Trip {
    var destination: String
    var endDate: Date
    var name: String
    var startDate: Date

    @Relationship(deleteRule: .cascade, inverse: \BucketListItem.trip)
    var bucketList: [BucketListItem] = [BucketListItem]()

    @Relationship(deleteRule: .cascade, inverse: \LivingAccommodation.trip)
    var livingAccommodation: LivingAccommodation?

    init(
      name: String, destination: String,
      startDate: Date = .now, endDate: Date = .distantFuture
    ) {
      self.name = name
      self.destination = destination
      self.startDate = startDate
      self.endDate = endDate
    }
  }
#endif
