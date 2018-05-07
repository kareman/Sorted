
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

extension SortedCollection {
	fileprivate func _insertionIndexFromStart(for element: Element) -> Index {
		for index in self.indices {
			if !areInIncreasingOrder(self[index], element) {
				return index
			}
		}
		return endIndex
	}

	public func insertionIndex(for element: Element) -> Index {
		return _insertionIndexFromStart(for: element)
	}
}

extension SortedCollection where Self: BidirectionalCollection {
	public func insertionIndex(for element: Element) -> Index {
		if let last = last, areInIncreasingOrder(last, element) {
			return endIndex
		}
		return _insertionIndexFromStart(for: element)
	}

	fileprivate func _insertionIndexFromEnd(for element: Element) -> Index {
		for index in self.indices.reversed() {
			if !areInIncreasingOrder(element, self[index]) {
				return index
			}
		}
		return startIndex
	}
}

extension SortedCollection where Element: Equatable {
	public func contains(_ element: Element) -> Bool {
		let i = insertionIndex(for: element)
		return (i != endIndex && self[i] == element)
	}

	/// The index of the first occurrence of this element.
	public func firstIndex(of element: Element) -> Index? {
		let i = insertionIndex(for: element)
		return (i != endIndex && self[i] == element) ? i : nil
	}
}

extension SortedCollection where Self: BidirectionalCollection, Element: Equatable {
	/// The index of the last occurrence of this element.
	public func lastIndex(of element: Element) -> Index? {
		let i = _insertionIndexFromEnd(for: element)
		return (i != endIndex && self[i] == element) ? i : nil
	}
}


extension RandomAccessCollection {
	/// The value in the middle of this range. Returns nil if the range is empty.
	fileprivate func index(inMiddleOf range: Range<Index>) -> Index? {
		guard !range.isEmpty else { return nil }
		return index(range.lowerBound, offsetBy: distance(from: range.lowerBound, to: range.upperBound) / 2)
	}
}

extension SortedCollection where Self: RandomAccessCollection {
	/// Binary search for element in range.
	fileprivate func insertionIndex(for element: Element, in range: Range<Index>) -> Index {
		guard let middle = index(inMiddleOf: range) else { return range.upperBound }
		if areInIncreasingOrder(self[middle], element) {
			return insertionIndex(for: element, in: index(after: middle)..<range.upperBound)
		} else if areInIncreasingOrder(element, self[middle]) {
			return insertionIndex(for: element, in: range.lowerBound..<middle)
		}
		return middle
	}

	public func insertionIndex(for element: Element) -> Index {
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
	public func firstIndex(of element: Element) -> Index? {
		return firstIndex(of: element, in: startIndex..<endIndex)
	}

	fileprivate func lastIndex(of element: Element, in range: Range<Index>) -> Index? {
		guard let middle = index(inMiddleOf: range) else {
			guard range.upperBound > startIndex else { return nil }
			let index = self.index(before: range.upperBound)
			return (index != endIndex && self[index] == element) ? index : nil
		}
		if areInIncreasingOrder(element, self[middle]) {
			return lastIndex(of: element, in: range.lowerBound..<middle)
		}
		return lastIndex(of: element, in: index(after: middle)..<range.upperBound)
	}

	/// The index of the last occurrence of this element.
	public func lastIndex(of element: Element) -> Index? {
		return lastIndex(of: element, in: startIndex..<endIndex)
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
