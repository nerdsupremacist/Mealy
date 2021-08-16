
import Foundation

public struct TupleAssertion<Tuple>: Assertion {
    public typealias Body = Never

    private let storage: Tuple

    init(_ storage: Tuple) {
        self.storage = storage
    }

    public var body: Never {
        fatalError()
    }
}

extension TupleAssertion: InternalAssertion {

    func assert(_ context: AssertionContext) {
        // TODO
    }

}
