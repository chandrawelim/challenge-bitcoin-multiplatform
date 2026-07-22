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
    
    private func validPriceJSON() -> Data {
        Data("{\"symbol\":\"BTCUSDT\",\"price\":\"45000.50\"}".utf8)
    }
}
