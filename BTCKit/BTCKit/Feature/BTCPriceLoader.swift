public protocol BTCPriceLoader {
    func load(completion: @escaping (Result<BTCPrice, Error>) -> Void)
}
