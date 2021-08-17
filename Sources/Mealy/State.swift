
@_exported import Assert

public protocol State: AnyObject {
    associatedtype SystemUnderTest
    associatedtype StateTest: Test

    @TestBuilder
    func test(system: SystemUnderTest) -> StateTest
}
