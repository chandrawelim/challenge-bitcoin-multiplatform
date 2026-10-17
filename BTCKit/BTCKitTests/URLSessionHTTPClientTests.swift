import XCTest
import BTCKit

final class URLSessionHTTPClientTests: XCTestCase {

    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(URLProtocolStub.self)
    }

    override func tearDown() {
        super.tearDown()
        URLProtocol.unregisterClass(URLProtocolStub.self)
        URLProtocolStub.removeStub()
    }

    func test_getFromURL_doesNotPerformAnyURLRequestOnInit() {
        let exp = expectation(description: "No request should be made on init")
        exp.isInverted = true

        URLProtocolStub.observeRequests { _ in exp.fulfill() }
        _ = makeSUT()

        wait(for: [exp], timeout: 0.1)
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")

        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }

        makeSUT().get(from: url) { _ in }

        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helpers

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> URLSessionHTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }
}
