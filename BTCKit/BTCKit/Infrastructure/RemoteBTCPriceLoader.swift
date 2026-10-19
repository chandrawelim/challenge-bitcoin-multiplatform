import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

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
        client.get(from: url) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success((data, response)):
                completion(Result { try self.mapper(data, response) })
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
