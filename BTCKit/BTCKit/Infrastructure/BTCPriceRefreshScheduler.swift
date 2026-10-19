import Foundation

public final class BTCPriceRefreshScheduler {
    public typealias Scheduler = (TimeInterval, @escaping () -> Void) -> Void

    private let loader: BTCPriceLoader
    private let scheduler: Scheduler

    public init(loader: BTCPriceLoader, scheduler: @escaping Scheduler) {
        self.loader = loader
        self.scheduler = scheduler
    }

    public func startRefreshing(completion: @escaping (Result<BTCPrice, Error>) -> Void) {}

    public func stopRefreshing() {}
}
