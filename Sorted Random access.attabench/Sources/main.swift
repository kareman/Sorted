// Copyright © 2017 Károly Lőrentey.
// This file is part of Attabench: https://github.com/attaswift/Attabench
// For licensing information, see the file LICENSE.md in the Git repository above.

import Benchmarking
//import Sorted

let benchmark = Benchmark<(SortedArray<Int>)>(title: ".indices.contains") { size in
	return SortedArray(sorted: 0..<size-1)
}

benchmark.descriptiveTitle = "Time spent on all elements"
benchmark.descriptiveAmortizedTitle = "Average time spent on a single element"

benchmark.addTask(title: "DefaultIndices.firstIndex") { input in
	let indices = input

	return { timer in
		for value in indices {
			guard indices.firstIndex(of: value) == value else { fatalError() }
		}
	}
}


benchmark.addTask(title: "binarySearch_firstIndex") { input in
	let indices = input

	return { timer in
		for value in indices {
			guard indices.binarySearch_firstIndex(of: value) == value else { fatalError() }
		}
	}
}

benchmark.addTask(title: "binarySearchWithCount_firstIndex") { input in
	let indices = input

	return { timer in
		for value in indices {
			guard indices.binarySearch2_firstIndex(of: value) == value else { fatalError("binarySearchWithCount_firstIndex") }
		}
	}
}

benchmark.addTask(title: "forward_firstIndex") { input in
	let indices = input

	return { timer in
		for value in indices {
			guard indices.forward_firstIndex(of: value) == value else { fatalError() }
		}
	}
}

benchmark.addTask(title: "binarySearchNonRecursive_firstIndex") { input in
	let indices = input

	return { timer in
		for value in indices {
			guard indices.binarySearchNonRecursive_firstIndex(of: value) == value else { fatalError() }
		}
	}
}

benchmark.start()
