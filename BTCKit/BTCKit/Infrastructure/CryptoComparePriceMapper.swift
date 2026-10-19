import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum CryptoComparePriceMapper {
    private struct Response: Decodable {
        struct Raw: Decodable {
            let PRICE: Decimal
        }

        let RAW: Raw
    }

    public enum Error: Swift.Error {
        case non200HTTPResponse
        case invalidData
    }

    public static func map(_ data: Data, from response: HTTPURLResponse, currentDate: Date = Date()) throws -> BTCPrice {
        guard response.statusCode == 200 else {
            throw Error.non200HTTPResponse
        }

        guard let decoded = try? JSONDecoder().decode(Response.self, from: data) else {
            throw Error.invalidData
        }

        return BTCPrice(usd: decoded.RAW.PRICE, timestamp: currentDate)
    }
}
