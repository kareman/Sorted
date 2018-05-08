// Copyright © 2017 Károly Lőrentey.
// This file is part of Attabench: https://github.com/attaswift/Attabench
// For licensing information, see the file LICENSE.md in the Git repository above.

import Benchmarking

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

benchmark.addTask(title: "DefaultIndices.contains(valid index)") { input in
	let indices = input.indices
	let s = indices.enumerated().filter { (nr,_) in (nr % textCount) == 0 }.map { $0.1 }
	print("DefaultIndices.contains(valid index)","input.count:",input.count, "checks:", s.count)
	return { timer in
		for value in s {
			guard indices.contains(value) else { fatalError() }
		}
	}
}

extension DefaultBidirectionalIndices {
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

benchmark.addTask(title: "newContains(valid index)") { input in
	let indices = input.indices
	let s = indices.enumerated().filter { (nr,_) in (nr % textCount) == 0 }.map { $0.1 }
	print("newContains(valid index)", "input.count:",input.count, "checks:", s.count)
	return { timer in
		for value in s {
			guard indices.new_contains(value) else { fatalError() }
		}
	}
}

benchmark.addTask(title: "DefaultIndices.contains(invalid index)") { input in
	var input = input
	let suns = input.indices.filter { input[$0] == "☀️" }
	input.removeFirst()
	let indices = input.indices
	print("DefaultIndices.contains(invalid index)","input.count:",input.count, "checks:", suns.count)
	return { timer in
		for value in suns {
			guard !indices.contains(value) else { fatalError() }
		}
	}
}

benchmark.addTask(title: "newContains(invalid index)") { input in
	var input = input
	let suns = input.indices.filter { input[$0] == "☀️" }
	input.removeFirst()
	let indices = input.indices
	print("newContains(invalid index)","input.count:",input.count, "checks:", suns.count)
	return { timer in
		for value in suns {
			guard !indices.new_contains(value) else { fatalError() }
		}
	}
}

benchmark.addTask(title: "badContains(invalid index)") { input in
	var input = input
	let suns = input.indices.filter { input[$0] == "☀️" }
	input.removeFirst()
	let indices = input.indices
	return { timer in
		for value in suns {
			guard !indices.new_bad_contains(value) else { fatalError() }
		}
	}
}


benchmark.start()
