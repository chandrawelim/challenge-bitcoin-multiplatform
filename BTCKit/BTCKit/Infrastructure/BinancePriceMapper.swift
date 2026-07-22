import Foundation

public enum BinancePriceMapper {
    private struct Response: Decodable {
        let price: String
    }

    public enum Error: Swift.Error {
        case non200HTTPResponse
        case invalidData
    }

    public static func map(_ data: Data, from response: HTTPURLResponse, currentDate: Date = Date()) throws -> BTCPrice {
        guard response.statusCode == 200 else {
            throw Error.non200HTTPResponse
        }

        guard let decoded = try? JSONDecoder().decode(Response.self, from: data),
              let usd = Decimal(string: decoded.price) else {
            throw Error.invalidData
        }

        return BTCPrice(usd: usd, timestamp: currentDate)
    }
}
