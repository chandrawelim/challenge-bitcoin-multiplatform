import Foundation
import SwiftUI
import Combine
import BTCKit

@MainActor
final class BTCPriceViewModel: ObservableObject {
    @Published private(set) var price: String = "--"
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let loader: BTCPriceLoader

    init(loader: BTCPriceLoader) {
        self.loader = loader
    }

    func load() {
        isLoading = true
        errorMessage = nil

        loader.load { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case let .success(btcPrice):
                    let formatted = NumberFormatter.currency.string(
                        from: btcPrice.usd as NSDecimalNumber
                    ) ?? "$\(btcPrice.usd)"
                    self?.price = formatted
                case let .failure(error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
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
