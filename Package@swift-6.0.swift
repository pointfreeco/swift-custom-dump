// swift-tools-version: 6.0

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
    .package(url: "https://github.com/pointfreeco/swift-issue-reporting", from: "1.2.0")
  ],
  targets: [
    .target(
      name: "CustomDump",
      dependencies: [
        .product(name: "IssueReporting", package: "swift-issue-reporting"),
        .product(name: "XCTestDynamicOverlay", package: "swift-issue-reporting"),
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
