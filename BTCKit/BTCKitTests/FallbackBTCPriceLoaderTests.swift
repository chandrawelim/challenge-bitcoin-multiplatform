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
}
