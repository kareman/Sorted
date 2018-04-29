//
//  Created by Kåre Morstøl on 27/04/2018.
//  Many SortedArray methods are from https://github.com/ole/SortedArray
//

public struct SortedArray<Element>: Collection, SortedCollection {
	public typealias Elements = [Element]
	var elements: Elements
	public let areInIncreasingOrder: (Element, Element) -> Bool
	public var startIndex: Elements.Index { return elements.startIndex }
	public var endIndex: Elements.Index { return elements.endIndex }
	public subscript(position: Elements.Index) -> Element { return elements[position] }
	public func index(after i: Elements.Index) -> Elements.Index { return elements.index(after: i) }
}

extension SortedArray: MutableSortedCollection {
	@discardableResult
	public mutating func insert(_ element: Element) -> Elements.Index {
		let i = insertionIndex(for: element)
		elements.insert(element, at: i)
		return i
	}
}

extension SortedArray: BidirectionalCollection {
	public func index(before i: Elements.Index) -> Elements.Index {
		return elements.index(before: i)
	}
}

extension SortedArray: RandomAccessCollection { }

extension SortedArray {
	/// Initializes an empty array.
	///
	/// - Parameter areInIncreasingOrder: The comparison predicate the array should use to sort its elements.
	public init(areInIncreasingOrder: @escaping (Element, Element) -> Bool) {
		self.elements = []
		self.areInIncreasingOrder = areInIncreasingOrder
	}

	/// Initializes the array with a sequence of unsorted elements and a comparison predicate.
	public init<S: Sequence>(unsorted: S, areInIncreasingOrder: @escaping (Element, Element) -> Bool) where S.Iterator.Element == Element {
		self.elements = unsorted.sorted(by: areInIncreasingOrder)
		self.areInIncreasingOrder = areInIncreasingOrder
	}

	/// Initializes the array with a sequence that is already sorted according to the given comparison predicate.
	///
	/// This is faster than `init(unsorted:areInIncreasingOrder:)` because the elements don't have to be sorted again.
	///
	/// - Precondition: `sorted` is sorted according to the given comparison predicate. If you violate this condition, the behavior is undefined.
	public init<S: Sequence>(sorted: S, areInIncreasingOrder: @escaping (Element, Element) -> Bool) where S.Iterator.Element == Element {
		self.elements = Array(sorted)
		self.areInIncreasingOrder = areInIncreasingOrder
	}
}

extension SortedArray where Element: Comparable {
	/// Initializes an empty sorted array. Uses `<` as the comparison predicate.
	public init() {
		self.init(areInIncreasingOrder: <)
	}

	/// Initializes the array with a sequence of unsorted elements. Uses `<` as the comparison predicate.
	public init<S: Sequence>(unsorted: S) where S.Iterator.Element == Element {
		self.init(unsorted: unsorted, areInIncreasingOrder: <)
	}

	/// Initializes the array with a sequence that is already sorted according to the `<` comparison predicate. Uses `<` as the comparison predicate.
	///
	/// This is faster than `init(unsorted:)` because the elements don't have to be sorted again.
	///
	/// - Precondition: `sorted` is sorted according to the `<` predicate. If you violate this condition, the behavior is undefined.
	public init<S: Sequence>(sorted: S) where S.Iterator.Element == Element {
		self.init(sorted: sorted, areInIncreasingOrder: <)
	}
}

