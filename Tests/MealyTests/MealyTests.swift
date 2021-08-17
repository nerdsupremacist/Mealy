import XCTest
@testable import Mealy
import Assert

final class MealyTests: XCTestCase {
    func testExample() {
        let definition = TestCases()
        definition.test(desiredCoverage: .edge)
    }
}

protocol Switch {
    var isOn: Bool { get }
    func toggle()
}

class SwitchImplementation: Switch {
    private(set) var isOn: Bool

    init(isOn: Bool) {
        self.isOn = isOn
    }

    func toggle() {
        isOn.toggle()
    }
}

class TestCases: MealyTestDefinition {
    func initialState() -> OffState {
        return OffState()
    }

    func initialSystemUnderTest() -> Switch {
        return SwitchImplementation(isOn: false)
    }
}

class OffState: State {
    func test(system: Switch) -> some Assertion {
        Assert(!system.isOn, message: "Expected Switch to be Off")
    }

    func pressButton(system: Switch) -> OnState {
        system.toggle()
        return OnState()
    }
}

class OnState: State {
    func test(system: Switch) -> some Assertion {
        Assert(system.isOn, message: "Expected Switch to be On")
    }

    func pressButton(system: Switch) -> OffState {
        system.toggle()
        return OffState()
    }
}
