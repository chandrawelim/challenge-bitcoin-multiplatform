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
    
    func test_didFinishLoadingWithError_rendersErrorWithLastValue() {
        let (sut, view) = makeSUT()
        let price = BTCPrice(usd: Decimal(string: "45000.50")!, timestamp: Jan24_2107)

        sut.didFinishLoading(with: price)
        sut.didFinishLoading(with: anyNSError())

        XCTAssertEqual(view.messages.last, BTCPriceDisplayModel(
            price: "$45,000.50",
            errorMessage: "Failed to update value. Displaying last updated value from Jan 24th, 21:07",
            isLoading: false
        ))
    }

    func test_didFinishLoadingWithError_rendersErrorWithPlaceholderWhenNoLastValue() {
        let (sut, view) = makeSUT()

        sut.didFinishLoading(with: anyNSError())

        XCTAssertEqual(view.messages.last, BTCPriceDisplayModel(
            price: "--",
            errorMessage: "Failed to load data",
            isLoading: false
        ))
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
    
    private var Jan24_2107: Date {
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 24
        components.hour = 21
        components.minute = 7
        return Calendar(identifier: .gregorian).date(from: components)!
    }

    private final class BTCPriceViewSpy: BTCPriceView {
        private(set) var messages = [BTCPriceDisplayModel]()

        func display(_ viewModel: BTCPriceDisplayModel) {
            messages.append(viewModel)
        }
    }
}
