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

    public func didStartLoading() {
        view?.display(BTCPriceDisplayModel(price: "--", errorMessage: nil, isLoading: true))
    }
    
    public func didFinishLoading(with price: BTCPrice) {
        let formatted = NumberFormatter.currency.string(
            from: price.usd as NSDecimalNumber
        ) ?? "\(price.usd)"
        view?.display(BTCPriceDisplayModel(price: formatted, errorMessage: nil, isLoading: false))
    }
    
    public func didFinishLoading(with error: Error) {}
}

private extension NumberFormatter {
    static let currency: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        f.maximumFractionDigits = 2
        return f
    }()
}
