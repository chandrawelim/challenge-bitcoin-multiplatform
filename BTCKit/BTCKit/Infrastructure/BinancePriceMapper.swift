import Foundation

public enum BinancePriceMapper {
    public enum Error: Swift.Error {
        case non200HTTPResponse
    }

    public static func map(_ data: Data, from response: HTTPURLResponse, currentDate: Date = Date()) throws -> BTCPrice {
        guard response.statusCode == 200 else {
            throw Error.non200HTTPResponse
        }

        return BTCPrice(usd: 0, timestamp: currentDate)
    }
}
