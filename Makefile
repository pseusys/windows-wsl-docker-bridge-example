.ONESHELL:
.EXPORT_ALL_VARIABLES:
.DEFAULT_GOAL := help

SHELL=/bin/bash
.SHELLFLAGS=-c -e

WINDIVERT_VERSION=2.2.2
WINDIVERT_PATH=windivert-bin

WINDIVERT_TEMP=windivert-source
WINDIVERT_SOURCE=WinDivert-$(WINDIVERT_VERSION)-A
WNDIVERT_URL=https://github.com/basil00/WinDivert/releases/download/v$(WINDIVERT_VERSION)/$(WINDIVERT_SOURCE).zip

SYS_ARCH := $(shell uname -m | grep -q '64' && echo 'x64' || echo 'x32')


help:
	@ # Print available make target information
	echo -e "help"
.PHONY: help

dependencies:
	@ # Dowload and unpack windivert distribution
	curl -sSL -o $(WINDIVERT_SOURCE).zip $(WNDIVERT_URL)
	mkdir -p $(WINDIVERT_TEMP)
	unzip -q -o $(WINDIVERT_SOURCE).zip -d $(WINDIVERT_TEMP)
	mkdir -p $(WINDIVERT_PATH)
	mv $(WINDIVERT_TEMP)/$(WINDIVERT_SOURCE)/$(SYS_ARCH)/* $(WINDIVERT_PATH)/
	rm -rf $(WINDIVERT_TEMP)
.PHONY: dependencies

build: dependencies
	@ # Build reef locally TODO: add feature strict, checking warnings, docs, removing debug info
	cargo build --all-features
.PHONY: build

run: build
	@ # Run reef locally
	cargo run --features cli-exec --bin cli
.PHONY: run

clean:
	@ # Clean all reef build artifacts
	rm -rf target $(WINDIVERT_PATH)
	rm -f Cargo.lock $(WINDIVERT_SOURCE).zip
.PHONY: clean
