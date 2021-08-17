import XCTest
@testable import Mealy
import Assert

final class MealyTests: XCTestCase {
    func testCorrect() {
        let definition = TestCases(type: SwitchCorrect.self)
        definition.test(desiredCoverage: .edge)
    }

    func testFindsFault() {
        let definition = TestCases(type: SwitchFaulty.self)
        let assertions = definition.testResults(desiredCoverage: .edge)

        xcTest {
            Assert(!assertions.failures.isEmpty, message: "Expected to find a failure")
        }
    }
}

protocol Switch {
    var isOn: Bool { get }
    func toggle()

    init(isOn: Bool)
}

class SwitchCorrect: Switch {
    private(set) var isOn: Bool

    required init(isOn: Bool) {
        self.isOn = isOn
    }

    func toggle() {
        isOn.toggle()
    }
}

class SwitchFaulty: Switch {
    private(set) var isOn: Bool

    required init(isOn: Bool) {
        self.isOn = isOn
    }

    func toggle() {
        isOn = true
    }
}

class TestCases: MealyTestDefinition {
    let type: Switch.Type

    init(type: Switch.Type) {
        self.type = type
    }

    func initialState() -> OffState {
        return OffState()
    }

    func initialSystemUnderTest() -> Switch {
        return type.init(isOn: false)
    }
}

class OffState: State {
    func test(system: Switch) -> some Test {
        Assert(!system.isOn, message: "Expected Switch to be Off")
    }

    func pressButton(system: Switch) -> OnState {
        system.toggle()
        return OnState()
    }
}

class OnState: State {
    func test(system: Switch) -> some Test {
        Assert(system.isOn, message: "Expected Switch to be On")
    }

    func pressButton(system: Switch) -> OffState {
        system.toggle()
        return OffState()
    }
}
