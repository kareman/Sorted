//
//  DefaultCollection.swift
//  Sorted
//
//  Created by Kåre Morstøl on 27/04/2018.
//


protocol DefaultCollection: Collection where Index == MyElements.Index, Element == MyElements.Element {
	associatedtype MyElements: Collection
	var elements: MyElements { get }
}

extension DefaultCollection {
	var startIndex: MyElements.Index { return elements.startIndex }
	var endIndex: MyElements.Index { return elements.endIndex }
	subscript(position: MyElements.Index) -> Element { return elements[position] }
	func index(after i: Index) -> Index { return elements.index(after: i) }
	func makeIterator() -> MyElements.Iterator { return elements.makeIterator() }
}


struct SortedArray<Element: Comparable>: DefaultCollection, SortedCollection {
	var elements: [Element]

	public typealias Comparator<A> = (A, A) -> Bool
	let areInIncreasingOrder: (Element, Element) -> Bool
}

extension SortedArray {
	/// Initializes an empty array.
	///
	/// - Parameter areInIncreasingOrder: The comparison predicate the array should use to sort its elements.
	public init(areInIncreasingOrder: @escaping Comparator<Element>) {
		self.elements = []
		self.areInIncreasingOrder = areInIncreasingOrder
	}

	/// Initializes the array with a sequence of unsorted elements and a comparison predicate.
	public init<S: Sequence>(unsorted: S, areInIncreasingOrder: @escaping Comparator<Element>) where S.Iterator.Element == Element {
		let sorted = unsorted.sorted(by: areInIncreasingOrder)
		self.elements = sorted
		self.areInIncreasingOrder = areInIncreasingOrder
	}

	/// Initializes the array with a sequence that is already sorted according to the given comparison predicate.
	///
	/// This is faster than `init(unsorted:areInIncreasingOrder:)` because the elements don't have to sorted again.
	///
	/// - Precondition: `sorted` is sorted according to the given comparison predicate. If you violate this condition, the behavior is undefined.
	public init<S: Sequence>(sorted: S, areInIncreasingOrder: @escaping Comparator<Element>) where S.Iterator.Element == Element {
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

