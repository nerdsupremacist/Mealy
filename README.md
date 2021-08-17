<p align="center">
    <img src="logo.png" width="400" max-width="90%" alt="Mealy" />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.3-orange.svg" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/swiftpm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
    <a href="https://twitter.com/nerdsupremacist">
        <img src="https://img.shields.io/badge/twitter-@nerdsupremacist-blue.svg?style=flat" alt="Twitter: @nerdsupremacist" />
    </a>
</p>

# Mealy

Mealy allows you to write tests for Object Oriented Software in a more intuitive way while covering the most ground possible. 
With Mealy, you define your tests by implementing a State Machine. 
The framework will then traverse all the possible iterations of your state machine and test your classes thoroughly.

## Installation
### Swift Package Manager

You can install Syntax via [Swift Package Manager](https://swift.org/package-manager/) by adding the following line to your `Package.swift`:

```swift
import PackageDescription

let package = Package(
    [...]
    dependencies: [
        .package(url: "https://github.com/nerdsupremacist/Mealy.git", from: "0.1.0")
    ]
)
```

## Usage

Let's say you're testing a Switch class. 
We of course don't know anything about the implementation, but we can imagine the class like a state machine:

<p align="center">
    <img src="https://www.itemis.com/hubfs/yakindu/statechart-tools/documentation/images/overview_simple_moore.jpg" width="400" max-width="90%" alt="Mealy" />
</p>

To implement your tests, you implement each state. A state is a class with:
- A `test(system:)` function, where you can run all your assertions. Verifying that the object is in the correct state
- A series of functions with a single argument (which is the system under test) and returns the next state

```swift
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
```

Then we can define the test cases, by adding a way to get to the initial state, and the initial system under test:

```swift
class TestCases: MealyTestDefinition {
    func initialState() -> OffState {
        return OffState()
    }

    func initialSystemUnderTest() -> Switch {
        return Switch(isOn: false)
    }
}
```

To run the tests, call `TestCases.test`:

```swift
final class Tests: XCTestCase {
    func testStateMachine() {
        let cases = TestCases()
        cases.test(desiredCoverage: .edge)
    }
}
```

## Contributions
Contributions are welcome and encouraged!

## License
Mealy is available under the MIT license. See the LICENSE file for more info.
