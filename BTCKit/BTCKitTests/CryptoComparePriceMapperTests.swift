import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import BTCKit

final class CryptoComparePriceMapperTests: XCTestCase {

    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let samples = [199, 201, 300, 400, 500]

        try samples.forEach { code in
            XCTAssertThrowsError(
                try CryptoComparePriceMapper.map(validAverageJSON(), from: HTTPURLResponse(statusCode: code))
            )
        }
    }

    func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() throws {
        let samples = [
            Data("invalid json".utf8),
            Data("{\"Response\":\"Error\",\"Message\":\"market does not exist\"}".utf8)
        ]

        try samples.forEach { data in
            XCTAssertThrowsError(
                try CryptoComparePriceMapper.map(data, from: HTTPURLResponse(statusCode: 200))
            )
        }
    }

    func test_map_deliversPriceOn200HTTPResponseWithValidJSON() throws {
        let currentDate = Date(timeIntervalSince1970: 1706130420)

        let price = try CryptoComparePriceMapper.map(
            validAverageJSON(),
            from: HTTPURLResponse(statusCode: 200),
            currentDate: currentDate
        )

        XCTAssertEqual(price, BTCPrice(usd: Decimal(string: "45000.5")!, timestamp: currentDate))
    }

    private func validAverageJSON() -> Data {
        Data("{\"RAW\":{\"MARKET\":\"CUSTOMAGG\",\"FROMSYMBOL\":\"BTC\",\"TOSYMBOL\":\"USD\",\"PRICE\":45000.5}}".utf8)
    }
}
