
import Foundation

public struct EmptyAssertion: Assertion {
    public typealias Body = Never

    public var body: Never {
        fatalError()
    }
}

extension EmptyAssertion: InternalAssertion {

    func assert(_ context: AssertionContext) {
        // no-op
    }

}
