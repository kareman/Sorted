//
//  Created by Kåre Morstøl on 27/04/2018.
//  Many SortedArray methods are from https://github.com/ole/SortedArray
//


protocol WrappedCollection: Collection where Index == Elements.Index, Element == Elements.Element {
	associatedtype Elements: Collection
	var elements: Elements { get }
}

extension WrappedCollection {
	var startIndex: Elements.Index { return elements.startIndex }
	var endIndex: Elements.Index { return elements.endIndex }
	subscript(position: Elements.Index) -> Element { return elements[position] }
	func index(after i: Index) -> Index { return elements.index(after: i) }
	func makeIterator() -> Elements.Iterator { return elements.makeIterator() }
}


struct SortedArray<Element: Comparable>: WrappedCollection, SortedCollection {
	var elements: [Element]
	let areInIncreasingOrder: (Element, Element) -> Bool
}

extension SortedArray {
	@discardableResult
	mutating func insert(_ element: Element) -> Elements.Index {
		let i = insertionIndex(for: element)
		elements.insert(element, at: i)
		return i
	}
}

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
	/// This is faster than `init(unsorted:areInIncreasingOrder:)` because the elements don't have to sorted again.
	///
	/// - Precondition: `sorted` is sorted according to the given comparison predicate. If you violate this condition, the behavior is undefined.
	public init<S: Sequence>(sorted: S, areInIncreasingOrder: @escaping (Element, Element) -> Bool) where S.Iterator.Element == Element {
		self.elements = Array(sorted)
		self.areInIncreasingOrder = areInIncreasingOrder
	}
}

extension SortedArray where Element: Comparable {
	/// Initializes an empty sorted array. Uses `<` as the comparison predicate.
	init() {
		self.init(areInIncreasingOrder: <)
	}

	/// Initializes the array with a sequence of unsorted elements. Uses `<` as the comparison predicate.
	init<S: Sequence>(unsorted: S) where S.Iterator.Element == Element {
		self.init(unsorted: unsorted, areInIncreasingOrder: <)
	}

	/// Initializes the array with a sequence that is already sorted according to the `<` comparison predicate. Uses `<` as the comparison predicate.
	///
	/// This is faster than `init(unsorted:)` because the elements don't have to sorted again.
	///
	/// - Precondition: `sorted` is sorted according to the `<` predicate. If you violate this condition, the behavior is undefined.
	init<S: Sequence>(sorted: S) where S.Iterator.Element == Element {
		self.init(sorted: sorted, areInIncreasingOrder: <)
	}
}

