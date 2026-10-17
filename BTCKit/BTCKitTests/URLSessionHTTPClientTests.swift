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
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = anyNSError()

        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)

        XCTAssertEqual((receivedError as NSError?)?.domain, requestError.domain)
        XCTAssertEqual((receivedError as NSError?)?.code, requestError.code)
    }
    
    func test_getFromURL_deliversDataAndResponseOnSuccess() {
        let expectedData = anyData()
        let expectedResponse = anyHTTPURLResponse()

        let result = resultFor(data: expectedData, response: expectedResponse, error: nil)

        switch result {
        case let .success((receivedData, receivedResponse)):
            XCTAssertEqual(receivedData, expectedData)
            XCTAssertEqual(receivedResponse.url, expectedResponse.url)
            XCTAssertEqual(receivedResponse.statusCode, expectedResponse.statusCode)
        default:
            XCTFail("Expected success, got \(result) instead")
        }
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil,      response: nil,                    error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil,                    error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil,      response: nonHTTPURLResponse(),    error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(),    error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(),    error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil,      response: anyHTTPURLResponse(),    error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(),    error: anyNSError()))
    }
    
    func test_cancelGetFromURLTask_cancelsURLRequest() {
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observeRequests { _ in exp.fulfill() }

        let task = makeSUT().get(from: anyURL()) { _ in }
        wait(for: [exp], timeout: 1.0)

        task.cancel()

        XCTAssertEqual(URLProtocolStub.cancelledRequests.count, 1)
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
    
    private func anyNSError() -> NSError {
        NSError(domain: "Test", code: 0)
    }
    
    private func anyData() -> Data {
        Data("any data".utf8)
    }

    private func anyHTTPURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func resultErrorFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Error? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
    }

    private func resultFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HTTPClient.Result {
        URLProtocolStub.stub(data: data, response: response, error: error)

        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")

        var receivedResult: HTTPClient.Result!
        sut.get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
}
