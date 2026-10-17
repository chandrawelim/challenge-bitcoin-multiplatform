import Foundation

public final class FallbackBTCPriceLoader: BTCPriceLoader {
    private let primary: BTCPriceLoader
    private let fallback: BTCPriceLoader

    public init(primary: BTCPriceLoader, fallback: BTCPriceLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    public func load(completion: @escaping (Result<BTCPrice, Error>) -> Void) {
        primary.load { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}
