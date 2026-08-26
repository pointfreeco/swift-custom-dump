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
    .package(url: "https://github.com/pointfreeco/swift-issue-reporting", from: "2.0.0")
  ],
  targets: [
    .target(
      name: "CustomDump",
      dependencies: [
        .product(name: "IssueReporting", package: "swift-issue-reporting"),
      ]
    ),
    .testTarget(
      name: "CustomDumpTests",
      dependencies: [
        "CustomDump",
        .product(name: "IssueReportingTestSupport", package: "swift-issue-reporting"),
      ]
    ),
  ]
)

for target in package.targets {
  target.swiftSettings = target.swiftSettings ?? []
  target.swiftSettings?.append(contentsOf: [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("ImmutableWeakCaptures"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
  ])
}
