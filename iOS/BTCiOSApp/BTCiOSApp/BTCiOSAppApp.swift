import SwiftUI
import BTCKit

@main
struct BTCiOSAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(loader: makeLoader())
        }
    }

    private func makeLoader() -> BTCPriceLoader {
        let client = URLSessionHTTPClient()
        return FallbackBTCPriceLoader(
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
    }
}
