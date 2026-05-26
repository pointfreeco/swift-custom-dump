// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "swift-custom-dump",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .library(
      name: "CustomDump",
      targets: ["CustomDump"]
    )
  ],
  traits: [
    "FoundationNetworking",
    .default(enabledTraits: ["FoundationNetworking"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.2.2")
  ],
  targets: [
    .target(
      name: "CustomDump",
      dependencies: [
        .product(name: "IssueReporting", package: "xctest-dynamic-overlay"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),
    .testTarget(
      name: "CustomDumpTests",
      dependencies: [
        "CustomDump",
        .product(name: "IssueReportingTestSupport", package: "xctest-dynamic-overlay"),
      ]
    ),
  ]
)


#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

// Workaround to ensure that all traits are included in documentation. Swift Package Index adds
// SPI_GENERATE_DOCS (https://github.com/SwiftPackageIndex/SwiftPackageIndex-Server/issues/2336)
// when building documentation, so only tweak the default traits in this condition.
let spiGenerateDocs = ProcessInfo.processInfo.environment["SPI_GENERATE_DOCS"] != nil

// Enable all traits for other CI actions.
// Doesn't include OmitCoreLocation unless OMIT_CORE_LOCATION_TRAIT is specified
let enableAllTraitsExplicit = ProcessInfo.processInfo.environment["ENABLE_ALL_TRAITS"] != nil

// Disable OmitCoreLocation trait for CI actions by default
let omitCoreLocationExplicit = ProcessInfo.processInfo.environment["OMIT_CORE_LOCATION_TRAIT"] != nil

let enableAllTraits = spiGenerateDocs || enableAllTraitsExplicit

package.traits.formUnion([
  .trait(
    name: "CoreLocation",
    description: "Enables CoreLocation integration with CustomDump"
  ),
  .trait(
    name: "OmitCoreLocation",
    description: "Enables CoreLocation integration with CustomDump"
  ),
])

var allTraits = package.traits.map(\.name)

if !omitCoreLocationExplicit {
  allTraits.removeAll(where: { $0 == "OmitCoreLocation" })
}

package.traits.insert(.default(
  enabledTraits: Set(enableAllTraits ? allTraits : ["CoreLocation"])
))
