
public protocol SortedCollection: Collection where SubSequence: SortedCollection {
	/// An ordering for all elements in the collection.
	var areInIncreasingOrder: (Element, Element) -> Bool { get }

	/// The index for this element if it were to be inserted into the collection.
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

extension SortedCollection where Element: Equatable {
	public func contains(_ element: Element) -> Bool {
		let i = insertionIndex(for: element)
		return (i != endIndex && self[i] == element)
	}
}


extension Collection {
	/// The index in the middle of this collection. Returns nil if the collection is empty.
	fileprivate func indexInMiddle() -> Index? {
		guard !isEmpty else { return nil }
		return index(startIndex, offsetBy: count / 2)
	}
}

extension SortedCollection {
	public func insertionIndex(for element: Element) -> Index {
		// Binary search for element.
		guard let middle = indexInMiddle() else { return startIndex }
		if areInIncreasingOrder(self[middle], element) {
			return self[index(after: middle)...].insertionIndex(for: element)
		} else if areInIncreasingOrder(element, self[middle]) {
			return self[..<middle].insertionIndex(for: element)
		}
		return middle
	}

	public func firstInsertionIndex(of element: Element) -> Index {
		guard let middle = indexInMiddle() else { return endIndex }
		if areInIncreasingOrder(self[middle], element) {
			return self[index(after: middle)...].firstInsertionIndex(of: element)
		}
		return self[..<middle].firstInsertionIndex(of: element)
	}

	public func lastInsertionIndex(of element: Element) -> Index {
		guard let middle = indexInMiddle() else { return endIndex }
		if areInIncreasingOrder(element, self[middle]) {
			return self[..<middle].lastInsertionIndex(of: element)
		}
		return self[index(after: middle)...].lastInsertionIndex(of: element)
	}
}

extension SortedCollection where Element: Equatable {
	/// The index of the first occurrence of this element.
	public func firstIndex(of element: Element) -> Index? {
		let index = firstInsertionIndex(of: element)
		return (index != endIndex && self[index] == element) ? index : nil
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
