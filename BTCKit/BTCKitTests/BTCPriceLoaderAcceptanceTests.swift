#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest
import BTCKit

final class BTCPriceLoaderAcceptanceTests: XCTestCase {

    func test_load_deliversBTCPriceOnPrimarySuccess() {
        let price = makePrimaryLoader(client: .online(binanceResponse)).load()

        XCTAssertEqual(price?.usd, Decimal(string: "45000.50"))
    }

    func test_load_deliversBTCPriceOnFallbackSuccessWhenPrimaryFails() {
        let price = makeFallbackLoader(
            primaryClient: .offline(),
            fallbackClient: .online(cryptoCompareResponse)
        ).load()

        XCTAssertEqual(price?.usd, Decimal(string: "45000.5"))
    }

    func test_load_deliversNoDataWhenBothFail() {
        let price = makeFallbackLoader(
            primaryClient: .offline(),
            fallbackClient: .offline()
        ).load()

        XCTAssertNil(price)
    }

    // MARK: - Helpers

    private func makePrimaryLoader(client: HTTPClientStub) -> BTCPriceLoader {
        RemoteBTCPriceLoader(
            url: URL(string: "https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT")!,
            client: client,
            mapper: { data, response in try BinancePriceMapper.map(data, from: response) }
        )
    }

    private func makeFallbackLoader(primaryClient: HTTPClientStub, fallbackClient: HTTPClientStub) -> BTCPriceLoader {
        FallbackBTCPriceLoader(
            primary: makePrimaryLoader(client: primaryClient),
            fallback: RemoteBTCPriceLoader(
                url: URL(string: "https://min-api.cryptocompare.com/data/generateAvg?fsym=BTC&tsym=USD&e=coinbase")!,
                client: fallbackClient,
                mapper: { data, response in try CryptoComparePriceMapper.map(data, from: response) }
            )
        )
    }

    private func binanceResponse(for url: URL) -> (Data, HTTPURLResponse) {
        let data = Data("{\"symbol\":\"BTCUSDT\",\"price\":\"45000.50\"}".utf8)
        return (data, HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!)
    }

    private func cryptoCompareResponse(for url: URL) -> (Data, HTTPURLResponse) {
        let data = Data("{\"RAW\":{\"MARKET\":\"CUSTOMAGG\",\"FROMSYMBOL\":\"BTC\",\"TOSYMBOL\":\"USD\",\"PRICE\":45000.5}}".utf8)
        return (data, HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!)
    }
}

private extension BTCPriceLoader {
    func load() -> BTCPrice? {
        var result: BTCPrice?
        let exp = XCTestExpectation(description: "Wait for load")
        load { outcome in
            result = try? outcome.get()
            exp.fulfill()
        }
        XCTWaiter().wait(for: [exp], timeout: 1.0)
        return result
    }
}
