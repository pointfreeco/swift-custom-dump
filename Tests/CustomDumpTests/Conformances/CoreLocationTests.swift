#if canImport(CoreLocation)
  import CoreLocation
  import CustomDump
  import XCTest

  final class CoreLocationTests: XCTestCase {
    func testCLLocation() {
      guard #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) else { return }

      let date = Date(timeIntervalSinceReferenceDate: 0)
      let sourceInfo = CLLocationSourceInformation(
        softwareSimulationState: true,
        andExternalAccessoryState: false
      )

      let item = CLLocation(
        coordinate: .init(latitude: 10, longitude: 20), altitude: 300,
        horizontalAccuracy: 4, verticalAccuracy: 5,
        course: 6, courseAccuracy: 7,
        speed: 8, speedAccuracy: 9,
        timestamp: date, sourceInfo: sourceInfo
      )

      var dump = ""
      customDump(item, to: &dump)

      expectNoDifference(
        dump,
        """
        CLLocation(
          coordinate: CLLocationCoordinate2D(
            latitude: 10.0,
            longitude: 20.0
          ),
          altitude: 300.0,
          horizontalAccuracy: 4.0,
          verticalAccuracy: 5.0,
          course: 6.0,
          courseAccuracy: 7.0,
          speed: 8.0,
          speedAccuracy: 9.0,
          timestamp: Date(2001-01-01T00:00:00.000Z),
          sourceInformation: CLLocationSourceInformation(
            isProducedByAccessory: false,
            isSimulatedBySoftware: true
          ),
          ellipsoidalAltitude: 0.0,
          floor: nil
        )
        """
      )
    }

    class FakeFloor: CLFloor {
      init(level: Int) {
        _level = level
        super.init()
      }

      required init?(coder: NSCoder) { return nil }

      private var _level: Int
      override var level: Int { _level }
    }

    func testCLFloor() {
      let floor = FakeFloor(level: 10)

      var dump = ""
      customDump(floor, to: &dump)

      XCTAssertEqual(dump, "CLFloor(level: 10)")
    }
  }
#endif
