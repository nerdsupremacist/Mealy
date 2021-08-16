
import Foundation

extension Optional: Assertion where Wrapped: Assertion {
    public typealias Body = Never

    public var body: Never {
        fatalError()
    }
}

extension Optional: InternalAssertion where Wrapped: Assertion {

    func assert(_ context: AssertionContext) {
        if let wrapped = self {
            context.assert(wrapped)
        }
    }

}
