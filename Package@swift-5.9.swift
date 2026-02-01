// swift-tools-version: 5.9

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
    .package(url: "https://github.com/apple/swift-syntax", from: "509.0.0"),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.2.2")
  ],
  targets: [
    .target(
      name: "CustomDump",
      dependencies: [
        "CustomDumpMacros",
        .product(name: "IssueReporting", package: "xctest-dynamic-overlay"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency")
      ]
    ),
    .macro(
      name: "CustomDumpMacros",
      dependencies: [
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        .product(name: "SwiftDiagnostics", package: "swift-syntax"),
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
      ]
    ),
    .testTarget(
      name: "CustomDumpTests",
      dependencies: [
        "CustomDump",
        "CustomDumpMacros"
      ]
    ),
  ]
)
