import Foundation
import Combine
import BTCKit

@MainActor
final class BTCPriceViewModel: ObservableObject, BTCPriceView {
    @Published private(set) var price: String = "--"
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let scheduler: BTCPriceRefreshScheduler
    private lazy var presenter = BTCPricePresenter(view: self)

    init(loader: BTCPriceLoader) {
        self.scheduler = BTCPriceRefreshScheduler(loader: loader) { interval, block in
            DispatchQueue.global().asyncAfter(deadline: .now() + interval, execute: block)
        }
    }

    func start() {
        presenter.didStartLoading()
        scheduler.startRefreshing { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case let .success(price):
                    self.presenter.didFinishLoading(with: price)
                case let .failure(error):
                    self.presenter.didFinishLoading(with: error)
                }
            }
        }
    }

    func stop() {
        scheduler.stopRefreshing()
    }

    nonisolated func display(_ viewModel: BTCPriceDisplayModel) {
        Task { @MainActor [weak self] in
            self?.price = viewModel.price
            self?.isLoading = viewModel.isLoading
            self?.errorMessage = viewModel.errorMessage
        }
    }
}
