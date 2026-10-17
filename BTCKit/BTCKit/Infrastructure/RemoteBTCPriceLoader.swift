import Foundation

public final class RemoteBTCPriceLoader: BTCPriceLoader {
    private let url: URL
    private let client: HTTPClient
    private let mapper: (Data, HTTPURLResponse) throws -> BTCPrice

    public init(url: URL, client: HTTPClient, mapper: @escaping (Data, HTTPURLResponse) throws -> BTCPrice) {
        self.url = url
        self.client = client
        self.mapper = mapper
    }
    
    public func load(completion: @escaping (Result<BTCPrice, Error>) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            default:
                break
            }
        }
    }
}
