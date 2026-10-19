import XCTest
import BTCKit

final class BTCPriceRefreshSchedulerTests: XCTestCase {

    func test_init_doesNotLoadFromLoader() {
        let (_, loader) = makeSUT()

        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_startRefreshing_loadsImmediately() {
        let (sut, loader) = makeSUT()

        sut.startRefreshing { _ in }

        XCTAssertEqual(loader.loadCallCount, 1)
    }

    // MARK: - Helpers

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: BTCPriceRefreshScheduler, loader: BTCPriceLoaderSpy) {
        let loader = BTCPriceLoaderSpy()
        let sut = BTCPriceRefreshScheduler(loader: loader, scheduler: { _, _ in })
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }
}
