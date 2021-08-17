import XCTest
@testable import Mealy
import Assert

final class MealyTests: XCTestCase {
    func testExample() {
        let definition = ArrayTests()
        let tests = definition.test()
        print(tests)
    }
}

struct ArrayTests: MealyTestDefinition {
    func initialSystemUnderTest() -> [String] {
        return []
    }

    func initialState() -> EmptyState {
        return EmptyState()
    }
}

class EmptyState: State {
    func test(system: [String]) -> some Assertion {
        Assert(system.count, equals: 0)
        Assert(system.first, equals: nil)
    }

    func addString(systemUnderTest: inout [String]) -> OneItemState {
        systemUnderTest += ["test"]
        return OneItemState(value: "test")
    }
}

class OneItemState: State {
    let value: String

    init(value: String) {
        self.value = value
    }

    func test(system: [String]) -> some Assertion {
        Assert(system.count, equals: 1)
    }

    func empty(systemUnderTest: inout [String]) -> EmptyState {
        systemUnderTest = []
        return EmptyState()
    }
}
