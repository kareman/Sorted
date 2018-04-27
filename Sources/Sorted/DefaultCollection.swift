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
	var startIndex: Index { return elements.startIndex }
	var endIndex: Index { return elements.endIndex }
	subscript(position: MyElements.Index) -> Element { return elements[position] }
	func index(after i: Index) -> Index { return elements.index(after: i) }
	func makeIterator() -> MyElements.Iterator { return elements.makeIterator() }
}


struct SortedArray<Element>: DefaultCollection {
	var elements: [Element]
}



struct SA<Element>: Collection {
	typealias MyElements = [Element]
	typealias Index = MyElements.Index

	var elements: MyElements

	var startIndex: MyElements.Index { return elements.startIndex }
	var endIndex: MyElements.Index { return elements.endIndex }
	subscript(position: Index) -> Element { return elements[position] }
	func index(after i: Index) -> Index { return elements.index(after: i) }
}

