
import XCTest

@testable import SortedTests

let tests: [XCTestCaseEntry] = [
	testCase(SortedArrayTests.allTests),
	]

XCTMain(tests)
