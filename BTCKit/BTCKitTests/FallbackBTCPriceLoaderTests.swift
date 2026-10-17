import XCTest
import BTCKit

final class FallbackBTCPriceLoaderTests: XCTestCase {

    func test_init_doesNotLoadFromPrimaryOrFallback() {
        let (_, primary, fallback) = makeSUT()

        XCTAssertEqual(primary.loadCallCount, 0)
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
}
