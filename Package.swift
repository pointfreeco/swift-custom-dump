// swift-tools-version: 5.9

// ⚠️ This fork updates the dependency URL for the 'xctest-dynamic-overlay' repository, 
// which appears to have been renamed to 'swift-issue-reporting'. 
// This change addresses conflicts arising from this renaming.

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
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-issue-reporting", from: "1.2.2"),
  ],
  targets: [
    .target(
      name: "CustomDump",
      dependencies: [
        .product(name: "IssueReporting", package: "swift-issue-reporting"),
        .product(name: "XCTestDynamicOverlay", package: "swift-issue-reporting"),
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency")
      ]
    ),
    .testTarget(
      name: "CustomDumpTests",
      dependencies: [
        "CustomDump"
      ]
    ),
  ]
)
