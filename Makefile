test-all: test-linux test-swift

test-linux:
	docker run \
		--rm \
		-v "$(PWD):$(PWD)" \
		-w "$(PWD)" \
		swift:5.4 \
		bash -c 'make test-swift'

test-swift:
	swift test \
		--parallel

format:
	swift format --in-place --recursive .

.PHONY: format test-all test-linux test-swift
