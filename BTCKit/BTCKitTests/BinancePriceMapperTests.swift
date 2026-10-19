import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
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
    
    func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() throws {
        let samples = [
            Data("invalid json".utf8),
            Data("{\"symbol\":\"BTCUSDT\",\"price\":\"not a number\"}".utf8)
        ]
        
        try samples.forEach { data in
            XCTAssertThrowsError(
                try BinancePriceMapper.map(data, from: HTTPURLResponse(statusCode: 200))
            )
        }
    }
    
    func test_map_deliversPriceOn200HTTPResponseWithValidJSON() throws {
        let currentDate = Date(timeIntervalSince1970: 1706130420)
        
        let price = try BinancePriceMapper.map(validPriceJSON(), from: HTTPURLResponse(statusCode: 200), currentDate: currentDate)
        
        XCTAssertEqual(price, BTCPrice(usd: Decimal(string: "45000.50")!, timestamp: currentDate))
    }
    
    private func validPriceJSON() -> Data {
        Data("{\"symbol\":\"BTCUSDT\",\"price\":\"45000.50\"}".utf8)
    }
}
