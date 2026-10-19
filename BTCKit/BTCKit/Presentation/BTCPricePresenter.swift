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
    private var lastPrice: String?
    private var lastTimestamp: Date?

    public init(view: BTCPriceView) {
        self.view = view
    }

    public func didStartLoading() {
        view?.display(BTCPriceDisplayModel(price: lastPrice ?? "--", errorMessage: nil, isLoading: true))
    }

    public func didFinishLoading(with price: BTCPrice) {
        let formatted = NumberFormatter.currency.string(
            from: price.usd as NSDecimalNumber
        ) ?? "\(price.usd)"
        lastPrice = formatted
        lastTimestamp = price.timestamp
        view?.display(BTCPriceDisplayModel(price: formatted, errorMessage: nil, isLoading: false))
    }

    public func didFinishLoading(with error: Error) {
        let price = lastPrice ?? "--"
        let errorMessage: String

        if let lastTimestamp {
            let formatted = DateFormatter.lastUpdated.string(from: lastTimestamp)
            errorMessage = "Failed to update value. Displaying last updated value from \(formatted)"
        } else {
            errorMessage = "Failed to load data"
        }

        view?.display(BTCPriceDisplayModel(price: price, errorMessage: errorMessage, isLoading: false))
    }
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

private extension DateFormatter {
    static let lastUpdated: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d'th', HH:mm"
        return f
    }()
}
