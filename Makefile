PLATFORM_IOS = iOS Simulator,name=iPhone 11 Pro Max
PLATFORM_MACOS = macOS
PLATFORM_MAC_CATALYST = macOS,variant=Mac Catalyst
PLATFORM_TVOS = tvOS Simulator,name=Apple TV
PLATFORM_WATCHOS = watchOS Simulator,name=Apple Watch Series 5 - 44mm
SWIFT_VERSION = 5.5
ifeq ($(SWIFT_VERSION),5.3)
SWIFT_BUILD_ARGS = --enable-test-discovery
endif
SWIFT_TEST_ARGS = --parallel

test-all: test-linux test-swift test-platforms

test-linux:
	docker run \
		--rm \
		-v "$(PWD):$(PWD)" \
		-w "$(PWD)" \
		swift:$(SWIFT_VERSION) \
		bash -c 'make test-swift SWIFT_VERSION=$(SWIFT_VERSION)'

test-swift:
	swift test $(SWIFT_BUILD_ARGS) $(SWIFT_TEST_ARGS)
	swift build --configuration release $(SWIFT_BUILD_ARGS)

test-platforms:
	xcodebuild test \
		-scheme swift-custom-dump \
		-destination platform="$(PLATFORM_IOS)"
	xcodebuild \
		-scheme swift-custom-dump \
		-configuration Release \
		-destination platform="$(PLATFORM_IOS)"

	xcodebuild test \
		-scheme swift-custom-dump \
		-destination platform="$(PLATFORM_MACOS)"
	xcodebuild \
		-scheme swift-custom-dump \
		-configuration Release \
		-destination platform="$(PLATFORM_MACOS)"

	xcodebuild test \
		-scheme swift-custom-dump \
		-destination platform="$(PLATFORM_MAC_CATALYST)"
	xcodebuild \
		-scheme swift-custom-dump \
		-configuration Release \
		-destination platform="$(PLATFORM_MAC_CATALYST)"

	xcodebuild test \
		-scheme swift-custom-dump \
		-destination platform="$(PLATFORM_TVOS)"
	xcodebuild \
		-scheme swift-custom-dump \
		-configuration Release \
		-destination platform="$(PLATFORM_TVOS)"

	xcodebuild \
		-scheme swift-custom-dump \
		-destination platform="$(PLATFORM_WATCHOS)"
	xcodebuild \
		-scheme CustomDump_watchOS \
		-configuration Release \
		-destination platform="$(PLATFORM_WATCHOS)"

format:
	swift format --in-place --recursive .

.PHONY: format test-all test-linux test-swift
