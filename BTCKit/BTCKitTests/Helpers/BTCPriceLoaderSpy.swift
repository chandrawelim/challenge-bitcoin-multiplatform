import BTCKit

final class BTCPriceLoaderSpy: BTCPriceLoader {
    private(set) var loadCallCount = 0
    private var completions: [(Result<BTCPrice, Error>) -> Void] = []

    func load(completion: @escaping (Result<BTCPrice, Error>) -> Void) {
        loadCallCount += 1
        completions.append(completion)
    }

    func complete(with result: Result<BTCPrice, Error>, at index: Int = 0) {
        completions[index](result)
    }
}
