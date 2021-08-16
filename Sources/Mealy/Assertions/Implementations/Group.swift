
import Foundation

public struct Group<Content: Assertion>: Assertion {
    public typealias Body = Never

    private let path: [String]
    private let content: Content

    public var body: Never {
        fatalError()
    }

    public init(path: String, _ rest: String..., content: () -> Content) {
        self.path = [path] + rest
        self.content = content()
    }
}

extension Group: InternalAssertion {

    func assert(_ context: AssertionContext) {
        context.beginGroup(path: path)
        context.assert(content)
        context.endGroup()
    }

}
