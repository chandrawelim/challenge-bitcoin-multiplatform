import XCTest
import BTCKit

final class BTCPricePresenterTests: XCTestCase {

    func test_init_doesNotRenderToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty)
    }
    
    func test_didStartLoading_rendersLoadingState() {
        let (sut, view) = makeSUT()

        sut.didStartLoading()

        XCTAssertEqual(view.messages, [
            BTCPriceDisplayModel(price: "--", errorMessage: nil, isLoading: true)
        ])
    }
    
    func test_didFinishLoadingWithPrice_rendersFormattedPrice() {
        let (sut, view) = makeSUT()
        let price = BTCPrice(usd: Decimal(string: "45000.50")!, timestamp: Date())

        sut.didFinishLoading(with: price)

        XCTAssertEqual(view.messages, [
            BTCPriceDisplayModel(price: "$45,000.50", errorMessage: nil, isLoading: false)
        ])
    }

    func test_didFinishLoadingWithPrice_hidesErrorMessage() {
        let (sut, view) = makeSUT()
        let price = BTCPrice(usd: Decimal(string: "45000.50")!, timestamp: Date())

        sut.didFinishLoading(with: anyNSError())
        sut.didFinishLoading(with: price)

        XCTAssertNil(view.messages.last?.errorMessage)
    }

    // MARK: - Helpers

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: BTCPricePresenter, view: BTCPriceViewSpy) {
        let view = BTCPriceViewSpy()
        let sut = BTCPricePresenter(view: view)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(view, file: file, line: line)
        return (sut, view)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "Test", code: 0)
    }

    private final class BTCPriceViewSpy: BTCPriceView {
        private(set) var messages = [BTCPriceDisplayModel]()

        func display(_ viewModel: BTCPriceDisplayModel) {
            messages.append(viewModel)
        }
    }
}
