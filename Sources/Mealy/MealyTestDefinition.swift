
import Foundation

public protocol MealyTestDefinition {
    associatedtype SystemUnderTest
    associatedtype InitialState: State where InitialState.SystemUnderTest == SystemUnderTest

    func initialSystemUnderTest() -> SystemUnderTest
    func initialState() -> InitialState
}
