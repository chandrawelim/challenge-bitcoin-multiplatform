import XCTest
import BTCKit

final class BTCPricePresenterTests: XCTestCase {

    func test_init_doesNotRenderToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty)
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

    private final class BTCPriceViewSpy: BTCPriceView {
        private(set) var messages = [BTCPriceDisplayModel]()

        func display(_ viewModel: BTCPriceDisplayModel) {
            messages.append(viewModel)
        }
    }
}
