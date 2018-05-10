
import Benchmarking

let text = """
	The ☀️ and 🌙 are in the sky,
	it pays not well to wonder why.
	"""

let textCount = text.count


let benchmark = Benchmark<(String)>(title: "DefaultIndices<String>.firstIndex") { size in
	let x = size.quotientAndRemainder(dividingBy: textCount)
	return String(repeating: text, count: x.quotient) + text.prefix(x.remainder)
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

benchmark.addTask(title: "forward_firstIndex") { input in
	let indices = input.indices

	return { timer in
		for value in indices {
			guard indices.forward_firstIndex(of: value) == value else { fatalError() }
		}
	}
}

benchmark.addTask(title: "binarySearch_firstIndex") { input in
	let indices = input.indices

	return { timer in
		for value in indices {
			guard indices.binarySearch_firstIndex(of: value) == value else { fatalError() }
		}
	}
}

benchmark.addTask(title: "binarySearchCacheCount_firstIndex") { input in
	let indices = input.indices

	return { timer in
		for value in indices {
			guard indices.binarySearchCacheCount_firstIndex(of: value) == value
				else { fatalError("binarySearchCacheCount_firstIndex") }
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
