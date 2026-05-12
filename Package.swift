// swift-tools-version: 6.1
// Bumped from 6.0 to 6.1 to use SwiftPM package traits (added in 6.1).
// The `FoundationNetworking` trait gates the `FoundationNetworking` import +
// the `NSURLRequest: CustomDumpRepresentable` and
// `URLRequest.NetworkServiceType: CustomDumpStringConvertible` conformances.
// Default is on, so existing consumers see no behavior change. Consumers
// cross-compiling for the Swift Android SDK (or any other split-Foundation
// target where `libFoundationNetworking.so` is unwanted in DT_NEEDED) can
// disable it via `traits: []` on their `.package(...)` declaration.

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
