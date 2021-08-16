
import Foundation

public protocol Assertion {
    associatedtype Body: Assertion

    @AssertionBuilder
    var body: Body { get }
}
