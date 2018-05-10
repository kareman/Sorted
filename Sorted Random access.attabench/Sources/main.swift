
import Benchmarking

let benchmark = Benchmark<(SortedArray<Int>)>(title: "SortedArray.firstIndex") { size in
	return SortedArray(sorted: 0..<size-1)
}

benchmark.descriptiveTitle = "Time spent on all elements"
benchmark.descriptiveAmortizedTitle = "Average time spent on a single element"

benchmark.addTask(title: "Collection.firstIndex") { input in
	return { timer in
		for value in input {
			guard input.firstIndex(of: value) == value else { fatalError() }
		}
	}
}

benchmark.addTask(title: "forward_firstIndex") { input in
	return { timer in
		for value in input {
			guard input.forward_firstIndex(of: value) == value else { fatalError() }
		}
	}
}

benchmark.addTask(title: "binarySearch_firstIndex") { input in
	return { timer in
		for value in input {
			guard input.binarySearch_firstIndex(of: value) == value else { fatalError() }
		}
	}
}

benchmark.addTask(title: "binarySearchCacheCount_firstIndex") { input in
	return { timer in
		for value in input {
			guard input.binarySearchCacheCount_firstIndex(of: value) == value
				else { fatalError("binarySearchCacheCount_firstIndex") }
		}
	}
}

benchmark.addTask(title: "binarySearchNonRecursive_firstIndex") { input in
	return { timer in
		for value in input {
			guard input.binarySearchNonRecursive_firstIndex(of: value) == value else { fatalError() }
		}
	}
}

benchmark.start()
