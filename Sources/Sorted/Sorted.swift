
protocol SortedCollection: Collection {
	/// An ordering for all elements in the collection.
	var areInIncreasingOrder: (Element, Element) -> Bool { get }
	func insertionIndex(for element: Element) -> Index
}

extension SortedCollection where Element: Comparable {
	var areInIncreasingOrder: (Element, Element) -> Bool {
		return (<)
	}
}

extension SortedCollection {
	func insertionIndex(for element: Element) -> Index {
		for index in self.indices {
			if !areInIncreasingOrder(self[index], element) {
				return index
			}
		}
		return endIndex
	}
}
/*
extension SortedCollection where Self: BidirectionalCollection, Element: Equatable {
func insertionIndex(for element: Element) -> Index {
if !isEmpty {
let secondLastIndex = index(before: endIndex)
guard areInIncreasingOrder(element, self[secondLastIndex]) else {
return secondLastIndex
}
}
for index in self.indices {
if !areInIncreasingOrder(self[index], element) {
return index
}
}
return endIndex
}
}
*/

extension RandomAccessCollection {
	/// The value in the middle of this range. Returns nil if the range is empty.
	fileprivate func index(inMiddleOf range: Range<Index>) -> Index? {
		guard !range.isEmpty else { return nil }
		return index(range.lowerBound, offsetBy: distance(from: range.lowerBound, to: range.upperBound) / 2)
	}
}

extension SortedCollection where Self: RandomAccessCollection {
	fileprivate func insertionIndex(for element: Element, in range: Range<Index>) -> Index {
		guard let middle = index(inMiddleOf: range) else { return range.upperBound }
		if areInIncreasingOrder(self[middle], element) {
			return insertionIndex(for: element, in: index(after: middle)..<range.upperBound)
		} else if areInIncreasingOrder(element, self[middle]) {
			return insertionIndex(for: element, in: range.lowerBound..<middle)
		}
		return middle
	}

	/// The index to use if you were to insert this element.
	///
	/// - Parameters:
	///   - element: The element to hypothetically insert.
	/// - Note: If the element already occurs multiple times, the index to 1 of those occurrences will be returned.
	func insertionIndex(for element: Element) -> Index {
		return insertionIndex(for: element, in: startIndex..<endIndex)
	}
}

extension SortedCollection where Self: RandomAccessCollection, Element: Equatable {
	fileprivate func firstIndex(of element: Element, in range: Range<Index>) -> Index? {
		guard let middle = index(inMiddleOf: range) else {
			let index = range.upperBound
			return (index != endIndex && self[index] == element) ? index : nil
		}
		if areInIncreasingOrder(self[middle], element) {
			return firstIndex(of: element, in: index(after: middle)..<range.upperBound)
		}
		return firstIndex(of: element, in: range.lowerBound..<middle)
	}

	/// The index of the first occurrence of this element.
	///
	/// - Parameters:
	///   - element: The element to search for.
	/// - Returns: The index, or nil if not found.
	func firstIndex(of element: Element) -> Index? {
		return firstIndex(of: element, in: startIndex..<endIndex)
	}

	fileprivate func lastIndex(of element: Element, in range: Range<Index>) -> Index? {
		guard let middle = index(inMiddleOf: range) else {
			let index = self.index(before: range.upperBound)
			return (index != endIndex && self[index] == element) ? index : nil
		}
		if areInIncreasingOrder(self[middle], element) {
			return lastIndex(of: element, in: range.lowerBound..<middle)
		}
		return lastIndex(of: element, in: index(after: middle)..<range.upperBound)
	}

	/// The index of the last occurrence of this element.
	///
	/// - Parameters:
	///   - element: The element to search for.
	/// - Returns: The index, or nil if not found.
	func lastIndex(of element: Element) -> Index? {
		return lastIndex(of: element, in: startIndex..<endIndex)
	}
}


extension Range: SortedCollection
where Bound: Strideable, Bound.Stride: SignedInteger { }

extension DefaultIndices: SortedCollection { }
