
import Foundation

extension Never: Assertion {
    public typealias Body = Never

    public var body: Never {
        fatalError()
    }
}
