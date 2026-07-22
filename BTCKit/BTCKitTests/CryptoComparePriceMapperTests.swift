import XCTest
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

    private func validAverageJSON() -> Data {
        Data("{\"RAW\":{\"MARKET\":\"CUSTOMAGG\",\"FROMSYMBOL\":\"BTC\",\"TOSYMBOL\":\"USD\",\"PRICE\":45000.5}}".utf8)
    }
}
