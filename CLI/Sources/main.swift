import Foundation
import BTCKit

let client = URLSessionHTTPClient()

let loader = FallbackBTCPriceLoader(
    primary: RemoteBTCPriceLoader(
        url: URL(string: "https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT")!,
        client: client,
        mapper: { data, response in try BinancePriceMapper.map(data, from: response) }
    ),
    fallback: RemoteBTCPriceLoader(
        url: URL(string: "https://min-api.cryptocompare.com/data/generateAvg?fsym=BTC&tsym=USD&e=coinbase")!,
        client: client,
        mapper: { data, response in try CryptoComparePriceMapper.map(data, from: response) }
    )
)

final class CLIView: BTCPriceView {
    func display(_ viewModel: BTCPriceDisplayModel) {
        if let error = viewModel.errorMessage {
            print(error)
        } else if !viewModel.isLoading {
            print("BTC/USD: \(viewModel.price)")
        }
    }
}

let view = CLIView()
let presenter = BTCPricePresenter(view: view)

let scheduler = BTCPriceRefreshScheduler(loader: loader) { interval, block in
    DispatchQueue.global().asyncAfter(deadline: .now() + interval, execute: block)
}

scheduler.startRefreshing { result in
    switch result {
    case let .success(price):
        DispatchQueue.main.async { presenter.didStartLoading() }
        DispatchQueue.main.async { presenter.didFinishLoading(with: price) }
    case let .failure(error):
        DispatchQueue.main.async { presenter.didFinishLoading(with: error) }
    }
}

signal(SIGINT) { _ in
    print("\nStopped.")
    exit(0)
}

RunLoop.main.run()