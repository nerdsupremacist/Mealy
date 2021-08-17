
@_exported import Assert

public protocol State: AnyObject {
    associatedtype SystemUnderTest
    associatedtype Assertions: Assertion

    @AssertionBuilder
    func test(system: SystemUnderTest) -> Assertions
}
