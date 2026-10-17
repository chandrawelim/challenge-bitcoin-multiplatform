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
        url: URL(string: "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC&tsyms=USD")!,
        client: client,
        mapper: { data, response in try CryptoComparePriceMapper.map(data, from: response) }
    )
)

print("Fetching BTC price...")

let semaphore = DispatchSemaphore(value: 0)

loader.load { result in
    switch result {
    case let .success(price):
        print("BTC/USD: $\(price.usd)")
    case let .failure(error):
        print("Failed: \(error.localizedDescription)")
    }
    semaphore.signal()
}

semaphore.wait()