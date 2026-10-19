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
    
    func test_startRefreshing_schedulesNextLoadAfterInterval() {
        let (sut, loader) = makeSUT()

        sut.startRefreshing { _ in }
        loader.complete(with: .failure(anyNSError()))

        XCTAssertEqual(loader.loadCallCount, 1)

        triggerScheduledBlock()

        XCTAssertEqual(loader.loadCallCount, 2)
    }

    func test_startRefreshing_doesNotScheduleNextLoadBeforeCompletion() {
        let (sut, loader) = makeSUT()

        sut.startRefreshing { _ in }

        triggerScheduledBlock()

        XCTAssertEqual(loader.loadCallCount, 1)
    }

    // MARK: - Helpers

    private var scheduledBlocks = [() -> Void]()

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: BTCPriceRefreshScheduler, loader: BTCPriceLoaderSpy) {
        let loader = BTCPriceLoaderSpy()
        let sut = BTCPriceRefreshScheduler(loader: loader) { [weak self] _, block in
            self?.scheduledBlocks.append(block)
        }
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }

    private func triggerScheduledBlock(at index: Int = 0) {
        guard scheduledBlocks.indices.contains(index) else { return }
        scheduledBlocks[index]()
    }

    private func anyNSError() -> NSError {
        NSError(domain: "Test", code: 0)
    }
}
