import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
