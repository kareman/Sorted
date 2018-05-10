
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

extension SortedCollection {
	public func insertionIndex(for element: Element) -> Index {
		return _insertionIndexFromStart(for: element)
	}
}

extension SortedCollection where Element: Comparable {
	@inlinable
	public var areInIncreasingOrder: (Element, Element) -> Bool {
		return (<)
	}
}

// MARK: forward

extension SortedCollection {
	@usableFromInline
	func _insertionIndexFromStart(for element: Element) -> Index {
		for index in self.indices {
			if !areInIncreasingOrder(self[index], element) {
				return index
			}
		}
		return endIndex
	}
}

extension SortedCollection where Element: Equatable {
	/// The index of the first occurrence of this element.
	@inlinable
	public func forward_firstIndex(of element: Element) -> Index? {
		let index = _insertionIndexFromStart(for: element)
		return (index != endIndex && self[index] == element) ? index : nil
	}
}

// MARK: binary search

extension Collection {
	/// The index in the middle of this collection. Returns nil if the collection is empty.
	@usableFromInline
	func binarySearch_indexInMiddle() -> Index? {
		guard !isEmpty else { return nil }
		return index(startIndex, offsetBy: count / 2)
	}
}

extension SortedCollection where Element: Equatable {
	@inlinable
	public func binarySearch_insertionIndex(for element: Element) -> Index {
		// Binary search for element.
		guard let middle = binarySearch_indexInMiddle() else { return startIndex }
		if areInIncreasingOrder(self[middle], element) {
			return self[index(after: middle)...].binarySearch_insertionIndex(for: element)
		} else if areInIncreasingOrder(element, self[middle]) {
			return self[..<middle].binarySearch_insertionIndex(for: element)
		}
		return middle
	}

	/// The first possible index for this element, if it were to be inserted into the collection.
	/// If the element already occurs, the index of the first occurrence will be returned.
	@inlinable
	public func binarySearch_firstInsertionIndex(of element: Element) -> Index {
		guard let middle = binarySearch_indexInMiddle() else { return endIndex }
		if areInIncreasingOrder(self[middle], element) {
			return self[index(after: middle)...].binarySearch_firstInsertionIndex(of: element)
		}
		return self[..<middle].binarySearch_firstInsertionIndex(of: element)
	}

	/// The last possible index for this element, if it were to be inserted into the collection.
	/// If the element already occurs, the index _after_ the last occurrence will be returned.
	@inlinable
	public func binarySearch_lastInsertionIndex(of element: Element) -> Index {
		guard let middle = binarySearch_indexInMiddle() else { return endIndex }
		if areInIncreasingOrder(element, self[middle]) {
			return self[..<middle].binarySearch_lastInsertionIndex(of: element)
		}
		return self[index(after: middle)...].binarySearch_lastInsertionIndex(of: element)
	}

	/// The index of the first occurrence of this element.
	@inlinable
	public func binarySearch_firstIndex(of element: Element) -> Index? {
		let index = binarySearch_firstInsertionIndex(of: element)
		return (index != endIndex && self[index] == element) ? index : nil
	}
}

// MARK: binarySearch2

extension Collection {
	/// The index in the middle of this collection. Returns nil if the collection is empty.
	@usableFromInline
	func binarySearch2_indexInMiddle(count: Int) -> (Index, Int)? {
		guard !isEmpty else { return nil }
		let newcount = (count) / 2
		return (index(startIndex, offsetBy: newcount), newcount)
	}
}

extension SortedCollection where Element: Equatable {
	/// The first possible index for this element, if it were to be inserted into the collection.
	/// If the element already occurs, the index of the first occurrence will be returned.
	@inlinable
	public func binarySearch2_firstInsertionIndex(of element: Element, count: Int) -> Index {
		guard let (middle, newcount) = binarySearch2_indexInMiddle(count: count) else { return endIndex }
		if areInIncreasingOrder(self[middle], element) {
			return self[index(after: middle)...].binarySearch2_firstInsertionIndex(of: element, count: newcount-1)
		}
		return self[..<middle].binarySearch2_firstInsertionIndex(of: element, count: newcount)
	}

	/// The index of the first occurrence of this element.
	@inlinable
	public func binarySearch2_firstIndex(of element: Element) -> Index? {
		let index = binarySearch2_firstInsertionIndex(of: element, count: self.count)
		return (index != endIndex && self[index] == element) ? index : nil
	}
}


// MARK: binarySearchNonRecursive

extension SortedCollection where Element: Equatable {
	/// The first possible index for this element, if it were to be inserted into the collection.
	/// If the element already occurs, the index of the first occurrence will be returned.
	@inlinable
	public func binarySearchNonRecursive_firstInsertionIndex(of element: Element) -> Index {
		var searchRange = startIndex..<endIndex
		var count = self.count
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

	/// The index of the first occurrence of this element.
	@inlinable
	public func binarySearchNonRecursive_firstIndex(of element: Element) -> Index? {
		let index = binarySearchNonRecursive_firstInsertionIndex(of: element)
		return (index != endIndex && self[index] == element) ? index : nil
	}
}



extension SortedCollection where Element: Equatable {
	@inlinable
	public func sorted_contains(_ element: Element) -> Bool {
		let i = binarySearch_insertionIndex(for: element)
		return (i != endIndex && self[i] == element)
	}
}

extension SortedCollection where Self: BidirectionalCollection, Element: Equatable {
	/// The index of the last occurrence of this element.
	@inlinable
	public func binarySearch_lastIndex(of element: Element) -> Index? {
		var index = binarySearch_lastInsertionIndex(of: element)
		guard index > startIndex else { return nil }
		formIndex(before: &index)
		return (self[index] == element) ? index : nil
	}
}


extension Range: SortedCollection
where Bound: Strideable, Bound.Stride: SignedInteger { }

extension DefaultIndices: SortedCollection { }

extension Slice: SortedCollection where Base: SortedCollection {
	@inlinable
	public var areInIncreasingOrder: (Base.Element, Base.Element) -> Bool {
		return base.areInIncreasingOrder
	}
}
