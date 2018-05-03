//  Many SortedArray unit tests are from https://github.com/ole/SortedArray

import Sorted
import XCTest

class SortedArrayTests: XCTestCase {
/*
	func testLinuxTestSuiteIncludesAllTests() {
		#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
			#if swift(>=4.0)
				let darwinTestCount = SortedArrayTests.defaultTestSuite.testCaseCount
			#else
				let darwinTestCount = Int(SortedArrayTests.defaultTestSuite().testCaseCount)
			#endif
			let linuxTestCount = SortedArrayTests.allTests.count
			XCTAssertEqual(linuxTestCount, darwinTestCount, "allTests (used for testing on Linux) is missing \(darwinTestCount - linuxTestCount) tests")
		#endif
	}
*/
	func testInsertionIndex() {
		let range = 0..<7

		XCTAssertEqual(range.insertionIndex(for: -2), 0)
		XCTAssertEqual(range.insertionIndex(for: -1), 0)
		for i in range {
			XCTAssertEqual(range.insertionIndex(for: i), i)
		}
		XCTAssertEqual(range.insertionIndex(for: 7), 7)
		XCTAssertEqual(range.insertionIndex(for: 8), 7)
	}

	func testInitUnsortedSorts() {
		let sut = SortedArray(unsorted: [3,4,2,1], areInIncreasingOrder: <)
		assertElementsEqual(sut, [1,2,3,4])
	}

	func testInitSortedDoesntResort() {
		// Warning: this is not a valid way to create a SortedArray
		let sut = SortedArray(sorted: [3,2,1])
		assertElementsEqual(Array(sut), [3,2,1])
	}

	func testSortedArrayCanUseArbitraryComparisonPredicate() {
		struct Person {
			var firstName: String
			var lastName: String
		}
		let a = Person(firstName: "A", lastName: "Smith")
		let b = Person(firstName: "B", lastName: "Jones")
		let c = Person(firstName: "C", lastName: "Lewis")

		var sut = SortedArray<Person> { $0.firstName > $1.firstName }
		[b,a,c].forEach { sut.insert($0) }
		assertElementsEqual(sut.map { $0.firstName }, ["C","B","A"])
	}

	func testConvenienceInitsUseLessThan() {
		let sut = SortedArray(unsorted: ["a","c","b"])
		assertElementsEqual(sut, ["a","b","c"])
	}

	func testInsertAtBeginningPreservesSortOrder() {
		var sut = SortedArray(unsorted: 1...3)
		sut.insert(0)
		assertElementsEqual(sut, [0,1,2,3])
	}

	func testInsertInMiddlePreservesSortOrder() {
		var sut = SortedArray(unsorted: 1...5)
		sut.insert(4)
		assertElementsEqual(sut, [1,2,3,4,4,5])
	}

	func testInsertAtEndPreservesSortOrder() {
		var sut = SortedArray(unsorted: 1...3)
		sut.insert(5)
		assertElementsEqual(sut, [1,2,3,5])
	}

	func testInsertAtBeginningReturnsInsertionIndex() {
		var sut = SortedArray(unsorted: [1,2,3])
		let index = sut.insert(0)
		XCTAssertEqual(index, 0)
	}

	func testInsertInMiddleReturnsInsertionIndex() {
		var sut = SortedArray(unsorted: [1,2,3,5])
		let index = sut.insert(4)
		XCTAssertEqual(index, 3)
	}

	func testInsertAtEndReturnsInsertionIndex() {
		var sut = SortedArray(unsorted: [1,2,3])
		let index = sut.insert(100)
		XCTAssertEqual(index, 3)
	}

	func testInsertInEmptyArrayReturnsInsertionIndex() {
		var sut = SortedArray<Int>()
		let index = sut.insert(10)
		XCTAssertEqual(index, 0)
	}

	func testInsertEqualElementReturnsCorrectInsertionIndex() {
		var sut = SortedArray(unsorted: [3,1,0,2,1])
		let index = sut.insert(1)
		XCTAssert(index == 1 || index == 2 || index == 3)
	}

	func testIndexOfFindsElementInMiddle() {
		let sut = SortedArray(unsorted: ["a","z","r","k"])
		let index = sut.firstIndex(of: "k")
		XCTAssertEqual(index, 1)
	}

	func testIndexOfFindsFirstElement() {
		let sut = SortedArray(sorted: 1..<10)
		let index = sut.firstIndex(of: 1)
		XCTAssertEqual(index, 0)
	}

	func testIndexOfFindsLastElement() {
		let sut = SortedArray(sorted: 1..<10)
		let index = sut.firstIndex(of: 9)
		XCTAssertEqual(index, 8)
	}

	func testIndexOfReturnsNilWhenNotFound() {
		let sut = SortedArray(unsorted: "Hello World")
		let index = sut.firstIndex(of: "h")
		XCTAssertNil(index)
	}

	func testIndexOfReturnsNilForEmptyArray() {
		let sut = SortedArray<Int>()
		let index = sut.firstIndex(of: 1)
		XCTAssertNil(index)
	}

	func testIndexOfCanDealWithSingleElementArray() {
		let sut = SortedArray<Int>(unsorted: [5])
		let index = sut.firstIndex(of: 5)
		XCTAssertEqual(index, 0)
	}

	func testIndexOfFindsFirstIndexOfDuplicateElements1() {
		let sut = SortedArray(unsorted: [1,2,3,3,3,3,3,3,3,3,4,5])
		let index = sut.firstIndex(of: 3)
		XCTAssertEqual(index, 2)
	}

	func testIndexOfFindsFirstIndexOfDuplicateElements2() {
		let sut = SortedArray(unsorted: [1,4,4,4,4,4,4,4,4,3,2])
		let index = sut.firstIndex(of: 4)
		XCTAssertEqual(index, 3)
	}

	func testIndexOfFindsFirstIndexOfDuplicateElements3() {
		let sut = SortedArray(unsorted: String(repeating: "A", count: 10))
		let index = sut.firstIndex(of: "A")
		XCTAssertEqual(index, 0)
	}

	func testIndexOfFindsFirstIndexOfDuplicateElements4() {
		let sut = SortedArray<Character>(unsorted: Array(repeating: "a", count: 100_000))
		let index = sut.firstIndex(of: "a")
		XCTAssertEqual(index, 0)
	}

	func testIndexOfFindsFirstIndexOfDuplicateElements5() {
		let sourceArray = Array(repeating: 5, count: 100_000) + [1,2,6,7,8,9]
		let sut = SortedArray(unsorted: sourceArray)
		let index = sut.firstIndex(of: 5)
		XCTAssertEqual(index, 2)
	}

	func testLastIndexOfFindsElementInMiddle() {
		let sut = SortedArray(unsorted: ["a","z","r","k"])
		let index = sut.lastIndex(of: "k")
		XCTAssertEqual(index, 1)
	}

	func testLastIndexOfFindsFirstElement() {
		let sut = SortedArray(sorted: 1..<10)
		let index = sut.lastIndex(of: 1)
		XCTAssertEqual(index, 0)
	}

	func testLastIndexOfFindsLastElement() {
		let sut = SortedArray(sorted: 0...9)
		let index = sut.lastIndex(of: 9)
		XCTAssertEqual(index, 9)
	}

	func testLastIndexOfReturnsNilWhenNotFound() {
		let sut = SortedArray(unsorted: "Hello World")
		let index = sut.lastIndex(of: "h")
		XCTAssertNil(index)
	}

	func testLastIndexOfReturnsNilForEmptyArray() {
		let sut = SortedArray<Int>()
		let index = sut.lastIndex(of: 1)
		XCTAssertNil(index)
	}

	func testLastIndexOfCanDealWithSingleElementArray() {
		let sut = SortedArray<Int>(unsorted: [5])
		let index = sut.lastIndex(of: 5)
		XCTAssertEqual(index, 0)
	}

	func testLastIndexOfFindsLastIndexOfDuplicateElements1() {
		let sut = SortedArray(unsorted: [1,2,3,3,3,3,3,3,3,3,4,5])
		let index = sut.lastIndex(of: 3)
		XCTAssertEqual(index, 9)
	}

	func testLastIndexOfFindsLastIndexOfDuplicateElements2() {
		let sut = SortedArray(unsorted: [1,4,4,4,4,4,4,4,4,3,2])
		let index = sut.lastIndex(of: 4)
		XCTAssertEqual(index, 10)
	}

	func testLastIndexOfFindsLastIndexOfDuplicateElements3() {
		let sut = SortedArray(unsorted: String(repeating: "A", count: 10))
		let index = sut.lastIndex(of: "A")
		XCTAssertEqual(index, 9)
	}

	func testsContains() {
		let sut = SortedArray(unsorted: "Lorem ipsum")
		XCTAssertTrue(sut.contains(" "))
		XCTAssertFalse(sut.contains("a"))
		XCTAssertFalse(sut.contains("z"))
	}

	func testMin() {
		let sut = SortedArray(unsorted: -10...10)
		XCTAssertEqual(sut.min(), -10)
	}

	func testMax() {
		let sut = SortedArray(unsorted: -10...(-1))
		XCTAssertEqual(sut.max(), -1)
	}

	func testFilter() {
		let sut = SortedArray(unsorted: ["a", "b", "c"])
		assertElementsEqual(sut.filter { $0 != "a" }, ["b", "c"])
	}

	func testImplementsEqual() {
		let sut = SortedArray(unsorted: [3,2,1])
		XCTAssertTrue(sut == SortedArray(unsorted: 1...3))
	}

	func testImplementsNotEqual() {
		let sut = SortedArray(unsorted: 1...3)
		XCTAssertTrue(sut != SortedArray(unsorted: 1...4))
	}
}


func assertElementsEqual<S1, S2>(_ expression1: @autoclosure () throws -> S1, _ expression2: @autoclosure () throws -> S2, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line)
	where S1: Sequence, S2: Sequence, S1.Iterator.Element == S2.Iterator.Element, S1.Iterator.Element: Equatable {

		// This should give a better error message than using XCTAssert(try expression1().elementsEqual(expression2()), ...)
		XCTAssertEqual(Array(try expression1()), Array(try expression2()), message, file: file, line: line)
}
