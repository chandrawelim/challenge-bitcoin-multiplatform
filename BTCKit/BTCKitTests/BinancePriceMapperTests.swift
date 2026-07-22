import XCTest
import BTCKit

final class BinancePriceMapperTests: XCTestCase {
    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let samples = [199, 201, 300, 400, 500]

        try samples.forEach { code in
            XCTAssertThrowsError(
                try BinancePriceMapper.map(validPriceJSON(), from: HTTPURLResponse(statusCode: code))
            )
        }
    }

    private func validPriceJSON() -> Data {
        Data("{\"symbol\":\"BTCUSDT\",\"price\":\"45000.50\"}".utf8)
    }
}
