
import Foundation

class AssertionContext {
    private class _State {
        let path: [String]
        private let previous: _State?

        convenience init() {
            self.init(path: [], previous: nil)
        }

        private init(path: [String], previous: _State?) {
            self.path = path
            self.previous = previous
        }

        func next(path: [String]) -> _State {
            return _State(path: self.path + path, previous: self)
        }

        func pop() -> _State? {
            return previous
        }
    }

    private var state: _State = _State()
    private(set) var failures: [Failure] = []

    func beginGroup(path: [String]) {
        self.state = state.next(path: path)
    }

    func endGroup() {
        self.state = state.pop() ?? self.state
    }

    func fail(message: String?,
              file: StaticString,
              function: StaticString,
              line: Int) {

        let failure = Failure(path: state.path, message: message, file: file, function: function, line: line)
        failures.append(failure)
    }

    func assert<Content : Assertion>(_ assertion: Content) {
        if let internalAssertion = assertion as? InternalAssertion {
            internalAssertion.assert(self)
            return
        }

        let body = assertion.body
        assert(body)
    }
}
