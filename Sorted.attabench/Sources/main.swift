// Copyright © 2017 Károly Lőrentey.
// This file is part of Attabench: https://github.com/attaswift/Attabench
// For licensing information, see the file LICENSE.md in the Git repository above.

import Benchmarking
//import Sorted

let text = """
	The ☀️ and 🌙 are in the sky,
	it pays not well to wonder why.
	"""

let textCount = text.count


let benchmark = Benchmark<(String)>(title: ".indices.contains") { size in
	let l = size.quotientAndRemainder(dividingBy: textCount)
	return String(repeating: text, count: l.quotient) + text.prefix(l.remainder)
}

benchmark.descriptiveTitle = "Time spent on all elements"
benchmark.descriptiveAmortizedTitle = "Average time spent on a single element"

benchmark.addTask(title: "DefaultIndices.firstIndex") { input in
	let indices = input.indices

	return { timer in
		for value in indices {
			guard indices.firstIndex(of: value) == value else { fatalError() }
		}
	}
}

extension DefaultIndices where Elements: BidirectionalCollection {
	public func new_contains(_ element: Element) -> Bool {
		guard element < endIndex else { return false }
		for index in self {
			if !(index < element) {
				return index == element
			}
		}
		return false
	}

	public func new_bad_contains(_ element: Element) -> Bool {
		guard element < endIndex else { return false }
		for index in self {
			if index == element { return true }
			if !(index < element) {	return false }
		}
		return false
	}
}
/*
benchmark.addTask(title: "newContains(valid index)") { input in
	let indices = input.indices

	return { timer in
		for value in indices {
			guard indices.new_contains(value) else { fatalError() }
		}
	}
}
*/

benchmark.addTask(title: "binarySearch_firstIndex") { input in
	let indices = input.indices

	return { timer in
		for value in indices {
			guard indices.binarySearch_firstIndex(of: value) == value else { fatalError() }
		}
	}
}

benchmark.addTask(title: "binarySearchWithCount_firstIndex") { input in
	let indices = input.indices

	return { timer in
		for value in indices {
			guard indices.binarySearch2_firstIndex(of: value) == value else { fatalError("binarySearchWithCount_firstIndex") }
		}
	}
}

benchmark.addTask(title: "forward_firstIndex") { input in
	let indices = input.indices

	return { timer in
		for value in indices {
			guard indices.forward_firstIndex(of: value) == value else { fatalError() }
		}
	}
}

benchmark.addTask(title: "binarySearchNonRecursive_firstIndex") { input in
	let indices = input.indices

	return { timer in
		for value in indices {
			guard indices.binarySearchNonRecursive_firstIndex(of: value) == value else { fatalError() }
		}
	}
}

benchmark.start()
