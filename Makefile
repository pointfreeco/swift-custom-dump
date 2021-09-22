PLATFORM_IOS = iOS Simulator,name=iPhone 11 Pro Max
PLATFORM_MACOS = macOS
PLATFORM_MAC_CATALYST = macOS,variant=Mac Catalyst
PLATFORM_TVOS = tvOS Simulator,name=Apple TV 4K (at 1080p)
PLATFORM_WATCHOS = watchOS Simulator,name=Apple Watch Series 4 - 44mm

test-all: test-linux-all test-swift test-platforms

test-linux-all: test-linux-5.4 test-linux-5.5

test-linux-5.4:
	$(call test-linux,5.4)

test-linux-5.5:
	$(call test-linux,5.5)

test-linux = docker run \
	--rm \
	-v "$(PWD):$(PWD)" \
	-w "$(PWD)" \
	swift:$(1) \
	bash -c 'make test-swift'

test-swift:
	swift test \
		--parallel
	swift build \
		--configuration release

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
		-scheme CustomDump_watchOS \
		-destination platform="$(PLATFORM_WATCHOS)"
	xcodebuild \
		-scheme CustomDump_watchOS \
		-configuration Release \
		-destination platform="$(PLATFORM_WATCHOS)"

format:
	swift format --in-place --recursive .

.PHONY: format test-all test-linux test-swift
