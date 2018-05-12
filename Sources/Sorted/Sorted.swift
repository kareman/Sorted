
public protocol SortedCollection: Collection where SubSequence: SortedCollection {
	/// An ordering for all elements in the collection.
	var areInIncreasingOrder: (Element, Element) -> Bool { get }

	/// The index for this element, if it were to be inserted into the collection.
	/// - Note: if the element already occurs several times, the index to any of those,
	/// or the index _after_ the last occurrence, may be returned.
	func insertionIndex(for element: Element) -> Index
}

public protocol MutableSortedCollection: SortedCollection {
	/// Inserts the element into the correct position in this sorted collection, and returns the index.
	mutating func insert(_: Element) -> Index
}

extension SortedCollection where Element: Comparable {
	public var areInIncreasingOrder: (Element, Element) -> Bool {
		return (<)
	}
}

extension SortedCollection {
	public func insertionIndex(for element: Element) -> Index {
		var searchRange = startIndex..<endIndex,
		    count = self.count
		while !searchRange.isEmpty {
			count = count / 2
			let middle = index(searchRange.lowerBound, offsetBy: count)
			if areInIncreasingOrder(self[middle], element) {
				searchRange = index(after: middle)..<searchRange.upperBound
				count -= 1
			} else if areInIncreasingOrder(element, self[middle]) {
				searchRange = searchRange.lowerBound..<middle
			} else {
				return middle
			}
		}
		return searchRange.lowerBound
	}

	/// The first possible index for this element, if it were to be inserted into the collection.
	/// If the element already occurs, the index of the first occurrence will be returned.
	func firstInsertionIndex(of element: Element) -> Index {
		var searchRange = startIndex..<endIndex,
		    count = self.count
		while !searchRange.isEmpty {
			count = count / 2
			let middle = index(searchRange.lowerBound, offsetBy: count)
			if areInIncreasingOrder(self[middle], element) {
				searchRange = index(after: middle)..<searchRange.upperBound
				count -= 1
			} else {
				searchRange = searchRange.lowerBound..<middle
			}
		}
		return searchRange.lowerBound
	}

	/// The last possible index for this element, if it were to be inserted into the collection.
	/// If the element already occurs, the index _after_ the last occurrence will be returned.
	func lastInsertionIndex(of element: Element) -> Index {
		var searchRange = startIndex..<endIndex,
		    count = self.count
		while !searchRange.isEmpty {
			count = count / 2
			let middle = index(searchRange.lowerBound, offsetBy: count)
			if areInIncreasingOrder(element, self[middle]) {
				searchRange = searchRange.lowerBound..<middle
			} else {
				searchRange = index(after: middle)..<searchRange.upperBound
				count -= 1
			}
		}
		return searchRange.lowerBound
	}
}

extension SortedCollection where Element: Equatable {
	/// The index of the first occurrence of this element.
	public func firstIndex(of element: Element) -> Index? {
		let index = firstInsertionIndex(of: element)
		return (index != endIndex && self[index] == element) ? index : nil
	}

	public func contains(_ element: Element) -> Bool {
		let index = insertionIndex(for: element)
		return (index != endIndex && self[index] == element)
	}
}

extension SortedCollection where Self: BidirectionalCollection, Element: Equatable {
	/// The index of the last occurrence of this element.
	public func lastIndex(of element: Element) -> Index? {
		var index = lastInsertionIndex(of: element)
		guard index > startIndex else { return nil }
		formIndex(before: &index)
		return (self[index] == element) ? index : nil
	}
}


extension Range: SortedCollection
where Bound: Strideable, Bound.Stride: SignedInteger { }

extension DefaultIndices: SortedCollection { }

extension Slice: SortedCollection where Base: SortedCollection {
	public var areInIncreasingOrder: (Base.Element, Base.Element) -> Bool {
		return base.areInIncreasingOrder
	}
}
