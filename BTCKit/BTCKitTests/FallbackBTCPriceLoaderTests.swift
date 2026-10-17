import XCTest
import BTCKit

final class FallbackBTCPriceLoaderTests: XCTestCase {

    func test_init_doesNotLoadFromPrimaryOrFallback() {
        let (_, primary, fallback) = makeSUT()

        XCTAssertEqual(primary.loadCallCount, 0)
        XCTAssertEqual(fallback.loadCallCount, 0)
    }
    
    func test_load_loadsFromPrimary() {
        let (sut, primary, _) = makeSUT()

        sut.load { _ in }

        XCTAssertEqual(primary.loadCallCount, 1)
    }
    
    func test_load_loadsFromFallbackOnPrimaryFailure() {
        let (sut, primary, fallback) = makeSUT()

        sut.load { _ in }
        primary.complete(with: .failure(anyNSError()))

        XCTAssertEqual(fallback.loadCallCount, 1)
    }

    func test_load_doesNotLoadFromFallbackOnPrimarySuccess() {
        let (sut, primary, fallback) = makeSUT()

        sut.load { _ in }
        primary.complete(with: .success(anyBTCPrice()))

        XCTAssertEqual(fallback.loadCallCount, 0)
    }
    
    func test_load_deliversPrimaryResultOnPrimarySuccess() {
        let (sut, primary, _) = makeSUT()
        let expectedPrice = anyBTCPrice()

        expect(sut, toCompleteWith: .success(expectedPrice)) {
            primary.complete(with: .success(expectedPrice))
        }
    }
    
    func test_load_deliversFallbackResultOnPrimaryFailure() {
        let (sut, primary, fallback) = makeSUT()
        let expectedPrice = anyBTCPrice()

        expect(sut, toCompleteWith: .success(expectedPrice)) {
            primary.complete(with: .failure(anyNSError()))
            fallback.complete(with: .success(expectedPrice))
        }
    }

    func test_load_deliversFallbackErrorOnBothFailure() {
        let (sut, primary, fallback) = makeSUT()

        expect(sut, toCompleteWith: .failure(anyNSError())) {
            primary.complete(with: .failure(anyNSError()))
            fallback.complete(with: .failure(anyNSError()))
        }
    }

    // MARK: - Helpers

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: FallbackBTCPriceLoader, primary: BTCPriceLoaderSpy, fallback: BTCPriceLoaderSpy) {
        let primary = BTCPriceLoaderSpy()
        let fallback = BTCPriceLoaderSpy()
        let sut = FallbackBTCPriceLoader(primary: primary, fallback: fallback)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(primary, file: file, line: line)
        trackForMemoryLeaks(fallback, file: file, line: line)
        return (sut, primary, fallback)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "Test", code: 0)
    }

    private func anyBTCPrice() -> BTCPrice {
        BTCPrice(usd: 1.0, timestamp: Date())
    }
    
    private func expect(
        _ sut: FallbackBTCPriceLoader,
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
}
