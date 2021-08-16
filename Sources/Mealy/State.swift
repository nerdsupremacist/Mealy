
public protocol State {
    associatedtype SystemUnderTest
    associatedtype Assertions: Assertion

    @AssertionBuilder
    func test(system: SystemUnderTest) -> Assertions
}
