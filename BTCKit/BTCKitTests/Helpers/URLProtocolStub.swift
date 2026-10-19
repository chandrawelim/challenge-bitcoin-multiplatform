import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class URLProtocolStub: URLProtocol {
    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }

    private static var stub: Stub?
    private(set) static var cancelledRequests = [URLRequest]()
    static var requestObserver: ((URLRequest) -> Void)?

    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        stub = Stub(data: data, response: response, error: error)
    }

    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
        requestObserver = observer
    }

    static func removeStub() {
        stub = nil
        requestObserver = nil
        cancelledRequests = []
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        if let observer = URLProtocolStub.requestObserver {
            client?.urlProtocolDidFinishLoading(self)
            return observer(request)
        }

        if let data = URLProtocolStub.stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }
        if let response = URLProtocolStub.stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        if let error = URLProtocolStub.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
        if URLProtocolStub.requestObserver != nil {
            URLProtocolStub.cancelledRequests.append(request)
        }
    }
}
