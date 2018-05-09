
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

extension Collection {
	/// The index in the middle of this collection. Returns nil if the collection is empty.
	fileprivate func indexInMiddle(count: Int) -> (Index, Int)? {
		guard !isEmpty else { return nil }
		let newcount = (count) / 2
		return (index(startIndex, offsetBy: newcount), newcount)
	}
}

extension SortedCollection {
	public func insertionIndex(for element: Element) -> Index {
		return insertionIndex(for: element, count: self.count)
	}

	func insertionIndex(for element: Element, count: Int) -> Index {
		// Binary search for element.
		guard let (middle, newcount) = indexInMiddle(count: count) else { return endIndex }
		if areInIncreasingOrder(self[middle], element) {
			return self[index(after: middle)...].insertionIndex(for: element, count: newcount-1)
		} else if areInIncreasingOrder(element, self[middle]) {
			return self[..<middle].insertionIndex(for: element, count: newcount)
		}
		return middle
	}

	/// The first possible index for this element, if it were to be inserted into the collection.
	/// If the element already occurs, the index of the first occurrence will be returned.
	func firstInsertionIndex(of element: Element, count: Int) -> Index {
		guard let (middle, newcount) = indexInMiddle(count: count) else { return endIndex }
		if areInIncreasingOrder(self[middle], element) {
			return self[index(after: middle)...].firstInsertionIndex(of: element, count: newcount-1)
		}
		return self[..<middle].firstInsertionIndex(of: element, count: newcount)
	}

	/// The last possible index for this element, if it were to be inserted into the collection.
	/// If the element already occurs, the index _after_ the last occurrence will be returned.
	func lastInsertionIndex(of element: Element, count: Int) -> Index {
		guard let (middle, newcount) = indexInMiddle(count: count) else { return endIndex }
		if areInIncreasingOrder(element, self[middle]) {
			return self[..<middle].lastInsertionIndex(of: element, count: newcount)
		}
		return self[index(after: middle)...].lastInsertionIndex(of: element, count: newcount-1)
	}
}

extension SortedCollection where Element: Equatable {
	/// The index of the first occurrence of this element.
	public func firstIndex(of element: Element) -> Index? {
		let index = firstInsertionIndex(of: element, count: self.count)
		return (index != endIndex && self[index] == element) ? index : nil
	}

	public func contains(_ element: Element) -> Bool {
		let i = insertionIndex(for: element)
		return (i != endIndex && self[i] == element)
	}
}

extension SortedCollection where Self: BidirectionalCollection, Element: Equatable {
	/// The index of the last occurrence of this element.
	public func lastIndex(of element: Element) -> Index? {
		var index = lastInsertionIndex(of: element, count: self.count)
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
