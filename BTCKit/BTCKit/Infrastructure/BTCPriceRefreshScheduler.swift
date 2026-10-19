import Foundation

public final class BTCPriceRefreshScheduler {
    public typealias Scheduler = (TimeInterval, @escaping () -> Void) -> Void

    private let loader: BTCPriceLoader
    private let scheduler: Scheduler
    private var isRefreshing = false

    public init(loader: BTCPriceLoader, scheduler: @escaping Scheduler) {
        self.loader = loader
        self.scheduler = scheduler
    }

    public func startRefreshing(completion: @escaping (Result<BTCPrice, Error>) -> Void) {
        isRefreshing = true
        load(completion: completion)
    }

    public func stopRefreshing() {
        isRefreshing = false
    }

    private func load(completion: @escaping (Result<BTCPrice, Error>) -> Void) {
        loader.load { [weak self] result in
            guard let self, self.isRefreshing else { return }
            completion(result)
            self.scheduler(1.0) { [weak self] in
                guard let self, self.isRefreshing else { return }
                self.load(completion: completion)
            }
        }
    }
}
