
import Foundation

public struct Fail: Assertion {
    public typealias Body = Never

    private let message: String?
    private let file: StaticString
    private let function: StaticString
    private let line: Int

    public var body: Never {
        fatalError()
    }

    public init(message: String? = nil,
                file: StaticString = #file,
                function: StaticString = #function,
                line: Int = #line) {
        
        self.message = message
        self.file = file
        self.function = function
        self.line = line
    }
}

extension Fail: InternalAssertion {

    func assert(_ context: AssertionContext) {
        context.fail(message: message, file: file, function: function, line: line)
    }

}
