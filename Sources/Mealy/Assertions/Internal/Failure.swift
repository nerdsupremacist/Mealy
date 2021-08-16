
import Foundation

struct Failure {
    let path: [String]
    let message: String?
    let file: StaticString
    let function: StaticString
    let line: Int
}
