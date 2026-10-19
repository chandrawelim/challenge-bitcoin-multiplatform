import Foundation

public protocol BTCPriceView: AnyObject {
    func display(_ viewModel: BTCPriceDisplayModel)
}

public struct BTCPriceDisplayModel: Equatable {
    public let price: String
    public let errorMessage: String?
    public let isLoading: Bool

    public init(price: String, errorMessage: String?, isLoading: Bool) {
        self.price = price
        self.errorMessage = errorMessage
        self.isLoading = isLoading
    }
}

public final class BTCPricePresenter {
    private weak var view: BTCPriceView?

    public init(view: BTCPriceView) {
        self.view = view
    }

    public func didStartLoading() {}
    public func didFinishLoading(with price: BTCPrice) {}
    public func didFinishLoading(with error: Error) {}
}
