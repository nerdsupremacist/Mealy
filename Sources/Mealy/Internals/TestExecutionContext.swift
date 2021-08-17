
import Assert
@_implementationOnly import Runtime
@_implementationOnly import ProtocolConformance
@_implementationOnly import ProtocolType
@_implementationOnly import ValuePointers
@_implementationOnly import CPointers

extension MealyTestDefinition {

    public func test(desiredCoverage: DesiredCoverage) {
        let results = testResults(desiredCoverage: desiredCoverage)
        results.xcTest()
    }

    public func testResults(desiredCoverage: DesiredCoverage) -> TestResults {
        var context = TestExecutionContext(desiredCoverage: desiredCoverage, type: SystemUnderTest.self)
        let initialState = initialState()
        context.addRemainingPaths(state: initialState, current: nil)
        var results: [TestResults] = []

        while let path = context.next() {
            var value = initialSystemUnderTest()
            let finalState = path.execute(systemUnderTest: &value, initialState: initialState)

            let transitions = path.transitions.map(\.info.methodName).joined(separator: " -> ")
            let message = path.transitions.isEmpty ? "Initial Setup" : "Transitions: \(transitions)"
            guard let pathResults = testAny(state: finalState, with: value, group: message) else {
                fatalError("Invalid final state \(finalState)")
            }

            results += [pathResults]
            context.addRemainingPaths(state: finalState, current: path)
        }

        let failures = results.flatMap { $0.failures }
        return try! createInstance { _ in
            return failures
        }
    }

}

private struct TestExecutionContext<SystemUnderTest> {
    private let desiredCoverage: DesiredCoverage
    private let systemUnderTestType: Any.Type
    private let systemUnderTestInOutType: Any.Type

    private var stateDefinitions: [Int : StateDefinition] = [:]

    private var includedStates: Set<Int> = []
    private var includedTransitions: Set<Int> = []
    private var includedPaths: Set<[Int]> = []

    private var remainingPaths: [ExecutionPath] = []

    init(desiredCoverage: DesiredCoverage, type: SystemUnderTest.Type) {
        self.desiredCoverage = desiredCoverage
        self.systemUnderTestType = SystemUnderTest.self
        self.systemUnderTestInOutType = UnsafeMutablePointer<SystemUnderTest>.self
    }

    mutating func next() -> ExecutionPath? {
        return remainingPaths.popLast()
    }

    mutating func definition(for type: Any.Type) -> StateDefinition {
        let typeAsInteger = unsafeBitCast(type, to: Int.self)
        if let definition = stateDefinitions[typeAsInteger] {
            return definition
        }

        let info = try! typeInfo(of: type, include: .methods)
        let transitions = info.methods.compactMap { method -> Transition? in
            guard method.arguments.count == 1 else { return nil }
            let argumentType = method.arguments[0].type
            guard argumentType == systemUnderTestType || argumentType == systemUnderTestInOutType else { return nil }
            let returnType = method.returnType
            guard ProtocolConformanceRecord(implementationType: returnType, protocolType: .state) != nil else { return nil }
            // TODO: Check for system under test constraint
            return Transition(id: Int(bitPattern: method.address),
                              from: typeAsInteger,
                              expectedTo: unsafeBitCast(returnType, to: Int.self),
                              isInOut: argumentType == systemUnderTestInOutType,
                              info: method)
        }

        let definition = StateDefinition(id: typeAsInteger, name: info.name, type: type, transitions: transitions)
        stateDefinitions[typeAsInteger] = definition
        return definition
    }

    mutating func addRemainingPaths(state: Any, current: ExecutionPath?) {
        let stateType = type(of: state)
        let definition = self.definition(for: stateType)
        if !includedStates.contains(definition.id) {
            includedStates.formUnion([definition.id])
        }

        let actualCurrent: ExecutionPath
        if let current = current {
            actualCurrent = current
        } else {
            actualCurrent = ExecutionPath(touchedStateIds: [definition.id], transitions: [])
            remainingPaths.append(actualCurrent)
        }

        for transition in definition.transitions {
            let path = ExecutionPath(touchedStateIds: actualCurrent.touchedStateIds + [transition.expectedTo], transitions: actualCurrent.transitions + [transition])
            if desiredCoverage.shouldTest(path: path,
                                          lastTransition: transition,
                                          includedStates: includedStates,
                                          includedTransitions: includedTransitions,
                                          includedPaths: includedPaths) {

                includedStates.formUnion([transition.expectedTo])
                includedTransitions.formUnion([transition.id])
                let pathId = path.transitions.map(\.id)
                includedPaths.formUnion([pathId])
                remainingPaths.append(path)
            }
        }
    }
}

extension DesiredCoverage {

    fileprivate func shouldTest(path: ExecutionPath,
                                lastTransition: Transition,
                                includedStates: Set<Int>,
                                includedTransitions: Set<Int>,
                                includedPaths: Set<[Int]>) -> Bool {

        switch self {
        case .state:
            return !includedStates.contains(lastTransition.expectedTo)
        case .edge:
            return !includedTransitions.contains(lastTransition.id)
        case .path(let limit):
            let pathId = path.transitions.map(\.id)
            if includedPaths.contains(pathId) {
                return false
            }

            let maxNumberOfOccurencesOfTransition = Dictionary(grouping: path.transitions.map(\.id)) { $0 }
                .map(\.value.count)
                .max() ?? 0

            if maxNumberOfOccurencesOfTransition > 1 {
                return false
            }

            switch limit {
            case .depth(let depth):
                if path.touchedStateIds.count > depth {
                    return false
                }
                break
            case .stateRepeats(let maxRepeats):
                let maxNumberOfOccurrencesPerState = Dictionary(grouping: path.touchedStateIds) { $0 }
                    .map(\.value.count)
                    .max() ?? 0

                if maxNumberOfOccurrencesPerState >= maxRepeats {
                    return false
                }
                break
            case .none:
                break
            }

            return true
        }
    }

}

extension ProtocolType {
    fileprivate static let state = ProtocolType(moduleName: "Mealy", protocolName: "State")!
}

private struct ExecutionPath {
    let touchedStateIds: [Int]
    let transitions: [Transition]
}

extension ExecutionPath {

    public func execute<SystemUnderTest>(systemUnderTest: inout SystemUnderTest, initialState: AnyObject) -> AnyObject {
        var state = initialState
        let transitions = self.transitions
        for transition in transitions {
            let unmanaged = Unmanaged.passUnretained(state)
            let pointer = unmanaged.toOpaque()
            let mutablePointer = UnsafeMutableRawPointer(mutating: pointer)
            if transition.isInOut {
                let function = unsafeBitCast(transition.info.address, to: (@convention(thin) (UnsafeMutablePointer<SystemUnderTest>) -> AnyObject).self)
                set_pointer_to_self_receiver(mutablePointer)
                state = function(&systemUnderTest)
            } else {
                let function = unsafeBitCast(transition.info.address, to: (@convention(thin) (SystemUnderTest) -> AnyObject).self)
                set_pointer_to_self_receiver(mutablePointer)
                state = function(systemUnderTest)
            }
        }
        return state
    }

}

private struct StateDefinition {
    let id: Int
    let name: String
    let type: Any.Type
    let transitions: [Transition]
}

private struct Transition {
    let id: Int
    let from: Int
    let expectedTo: Int
    let isInOut: Bool
    let info: MethodInfo
}

private let _testAnyPointer = testAnyPointer()

private func testAny<SystemUnderTest>(state: Any, with systemUnderTest: SystemUnderTest, group: String) -> TestResults? {
    let implementationType = type(of: state)
    guard let conformanceRecord = ProtocolConformanceRecord(implementationType: implementationType, protocolType: .state) else { return nil }

    let function = unsafeBitCast(_testAnyPointer, to: (@convention(thin) (UnsafeRawPointer, UnsafeRawPointer, String, ProtocolConformanceRecord) -> TestResults).self)
    let unmanaged = Unmanaged.passUnretained(state as AnyObject)
    let statePointer = unmanaged.toOpaque()

    return withUnsafePointer(to: systemUnderTest) { systemUnderTestPointer in
        return function(statePointer, systemUnderTestPointer, group, conformanceRecord)
    }
}

@_silgen_name("_mealy_testAny")
@available(*, unavailable)
public func _testAny<T : State>(state: T, with systemUnderTest: T.SystemUnderTest, group: String) -> TestResults {
    return test {
        Group(path: group) {
            state.test(system: systemUnderTest)
        }
    }
}
