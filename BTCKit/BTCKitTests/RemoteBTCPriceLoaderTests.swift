import XCTest
import BTCKit

final class RemoteBTCPriceLoaderTests: XCTestCase {

    func test_init_doesNotRequestData() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }
        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let clientError = NSError(domain: "Test", code: 0)

        expect(sut, toCompleteWith: .failure(clientError)) {
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(anyNSError())) {
                client.complete(withStatusCode: code, data: anyData(), at: index)
            }
        }
    }
    
    func test_load_deliversBTCPriceOn200HTTPResponseWithValidJSON() {
        let (sut, client) = makeSUT()
        let expectedPrice = BTCPrice(usd: Decimal(string: "45000.50")!, timestamp: Date(timeIntervalSince1970: 0))
        let validJSON = Data("{\"symbol\":\"BTCUSDT\",\"price\":\"45000.50\"}".utf8)

        expect(sut, toCompleteWith: .success(expectedPrice)) {
            client.complete(withStatusCode: 200, data: validJSON)
        }
    }

    // MARK: - Helpers

    private func makeSUT(
        url: URL = URL(string: "https://a-url.com")!,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RemoteBTCPriceLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteBTCPriceLoader(
            url: url,
            client: client,
            mapper: { data, response in
                try BinancePriceMapper.map(data, from: response, currentDate: Date(timeIntervalSince1970: 0))
            }
        )
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func expect(
        _ sut: RemoteBTCPriceLoader,
        toCompleteWith expectedResult: Result<BTCPrice, Error>,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedPrice), .success(expectedPrice)):
                XCTAssertEqual(receivedPrice, expectedPrice, file: file, line: line)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func anyData() -> Data {
        Data("any data".utf8)
    }

    private func anyNSError() -> NSError {
        NSError(domain: "Test", code: 0)
    }
}
