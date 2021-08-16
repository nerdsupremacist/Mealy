
import Foundation

public struct Assert {
    private let condition: () -> Bool
    private let message: String?

    private let file: StaticString
    private let function: StaticString
    private let line: Int

    public init(message: String? = nil,
                file: StaticString = #file,
                function: StaticString = #function,
                line: Int = #line,
                _ condition: @escaping () -> Bool) {
        
        self.condition = condition
        self.message = message
        self.file = file
        self.function = function
        self.line = line
    }

    public init(_ condition: @autoclosure @escaping () -> Bool,
                message: String? = nil,
                file: StaticString = #file,
                function: StaticString = #function,
                line: Int = #line) {

        self.condition = condition
        self.message = message
        self.file = file
        self.function = function
        self.line = line
    }
}

extension Assert: Assertion {

    public var body: some Assertion {
        if condition() {
            Fail(message: message, file: file, function: function, line: line)
        }
    }

}

extension Assert {

    public init<T : Equatable>(_ lhs: @escaping @autoclosure () -> T,
                               equals rhs: @escaping @autoclosure () -> T,
                               message: String? = nil,
                               file: StaticString = #file,
                               function: StaticString = #function,
                               line: Int = #line) {

        self.init(message: message,
                  file: file,
                  function: function,
                  line: line) {

            return lhs() == rhs()
        }
    }

}
