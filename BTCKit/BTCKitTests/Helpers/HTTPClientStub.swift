import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import BTCKit

final class HTTPClientStub: HTTPClient {
    private let stub: (URL) -> HTTPClient.Result

    static func offline() -> HTTPClientStub {
        HTTPClientStub { _ in .failure(NSError(domain: "offline", code: 0)) }
    }

    static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
        HTTPClientStub { url in .success(stub(url)) }
    }

    private init(stub: @escaping (URL) -> HTTPClient.Result) {
        self.stub = stub
    }

    private struct Task: HTTPClientTask {
        func cancel() {}
    }

    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        completion(stub(url))
        return Task()
    }
}
