#!/bin/sh

set -e
export TOOLCHAINS=org.swift.4220180425a
swift --version
swift run -c release -Xswiftc -whole-module-optimization Benchmark "$@"
