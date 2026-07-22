import Foundation

public struct BTCPrice: Equatable {
    public let usd: Decimal
    public let timestamp: Date

    public init(usd: Decimal, timestamp: Date) {
        self.usd = usd
        self.timestamp = timestamp
    }
}
