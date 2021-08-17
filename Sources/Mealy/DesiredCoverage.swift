
import Foundation

public enum DesiredCoverage {
    public enum PathCoverageLimit {
        case depth(Int)
        case stateRepeats(Int)
    }

    case state
    case edge

    case path(limit: PathCoverageLimit?)
}

extension DesiredCoverage {

    static let path: DesiredCoverage = .path(limit: nil)

}
