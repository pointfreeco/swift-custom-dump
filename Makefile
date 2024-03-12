PLATFORM_IOS = iOS Simulator,name=iPhone 11 Pro Max
PLATFORM_MACOS = macOS
PLATFORM_MAC_CATALYST = macOS,variant=Mac Catalyst
PLATFORM_TVOS = tvOS Simulator,name=Apple TV
SWIFT_VERSION = 5.7
SWIFT_TEST_ARGS = --parallel

test-all: test-linux test-swift test-platforms

test-linux:
	docker run \
		--rm \
		-v "$(PWD):$(PWD)" \
		-w "$(PWD)" \
		swift:$(SWIFT_VERSION) \
		bash -c 'apt-get update && apt-get -y install make && make test-swift SWIFT_VERSION=$(SWIFT_VERSION)'

test-swift:
	swift test $(SWIFT_TEST_ARGS)
	swift test --configuration release $(SWIFT_TEST_ARGS)

test-platforms:
	xcodebuild test \
		-workspace CustomDump.xcworkspace \
		-scheme CustomDump \
		-destination platform="$(PLATFORM_IOS)"
	xcodebuild test \
		-workspace CustomDump.xcworkspace \
		-scheme CustomDump \
		-configuration Release \
		-destination platform="$(PLATFORM_IOS)"

	xcodebuild test \
		-workspace CustomDump.xcworkspace \
		-scheme CustomDump \
		-destination platform="$(PLATFORM_MACOS)"
	xcodebuild \
		-workspace CustomDump.xcworkspace \
		-scheme CustomDump \
		-configuration Release \
		-destination platform="$(PLATFORM_MACOS)"

	xcodebuild test \
		-workspace CustomDump.xcworkspace \
		-scheme CustomDump \
		-destination platform="$(PLATFORM_MAC_CATALYST)"
	xcodebuild test \
		-workspace CustomDump.xcworkspace \
		-scheme CustomDump \
		-configuration Release \
		-destination platform="$(PLATFORM_MAC_CATALYST)"

	xcodebuild test \
		-workspace CustomDump.xcworkspace \
		-scheme CustomDump \
		-destination platform="$(PLATFORM_TVOS)"
	xcodebuild test \
		-workspace CustomDump.xcworkspace \
		-scheme CustomDump \
		-configuration Release \
		-destination platform="$(PLATFORM_TVOS)"

	xcodebuild \
		-workspace CustomDump.xcworkspace \
		-scheme CustomDump \
		-destination generic/platform=watchOS
	xcodebuild \
		-workspace CustomDump.xcworkspace \
		-scheme CustomDump \
		-configuration Release \
		-destination generic/platform=watchOS

format:
	swift format --in-place --recursive .

.PHONY: format test-all test-linux test-swift
