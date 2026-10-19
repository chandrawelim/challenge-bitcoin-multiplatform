import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import BTCKit

final class HTTPClientSpy: HTTPClient {
    private var messages: [(url: URL, completion: (HTTPClient.Result) -> Void)] = []
    private(set) var cancelledURLs = [URL]()

    var requestedURLs: [URL] { messages.map(\.url) }

    private struct Task: HTTPClientTask {
        let callback: () -> Void
        func cancel() { callback() }
    }

    @discardableResult
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        messages.append((url, completion))
        return Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
    }

    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }

    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(
            url: messages[index].url,
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
        messages[index].completion(.success((data, response)))
    }
}
