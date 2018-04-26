import XCTest
@testable import Sorted

final class SortedTests: XCTestCase {
	func testExample() {
		let range = 0..<7

		XCTAssertEqual(range.insertionIndex(for: -2), 0)
		XCTAssertEqual(range.insertionIndex(for: -1), 0)
		for i in range {
			XCTAssertEqual(range.insertionIndex(for: i), i)
		}
		XCTAssertEqual(range.insertionIndex(for: 8), 7)
		XCTAssertEqual(range.insertionIndex(for: 9), 7)
	}

	static var allTests = [
		("testExample", testExample),
		]
}
