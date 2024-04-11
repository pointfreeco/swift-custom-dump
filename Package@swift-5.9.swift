// swift-tools-version:5.9

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
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.0.0")
  ],
  targets: [
    .target(
      name: "CustomDump",
      dependencies: [
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
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
