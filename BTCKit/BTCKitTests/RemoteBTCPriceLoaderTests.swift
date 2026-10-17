import XCTest
import BTCKit

final class RemoteBTCPriceLoaderTests: XCTestCase {

    func test_init_doesNotRequestData() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
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
            mapper: { data, response in try BinancePriceMapper.map(data, from: response) }
        )
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
}
