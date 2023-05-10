//
//  Frankfurter.swift
//  Frankfurter
//
//  Created by David Walter on 10.04.23.
//

import Foundation

/// The Frankfurter API tracks foreign exchange references rates published by the European Central Bank. The data refreshes around 16:00 CET every working day.
public struct Frankfurter {
    private let session: URLSession
    private let host: URLComponents
    
    /// Initialize a new Frankfurter API
    ///
    /// - Parameters:
    ///     - host: The API host to call. Defaults to https://api.frankfurter.app
    ///     - session: The `URLSession` to use. Defaults to `URLSession.shared`.
    public init(host: URL? = nil, session: URLSession = .shared) {
        self.session = session
        if let host {
            self.host = URLComponents(url: host, resolvingAgainstBaseURL: false) ?? URLComponents(string: "https://api.frankfurter.app")!
        } else {
            self.host = URLComponents(string: "https://api.frankfurter.app")!
        }
    }
    
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }()
    
    public static var jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()
    
    public static var jsonEncoder: JSONEncoder = {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .formatted(dateFormatter)
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        return jsonEncoder
    }()
    
    /// This endpoint returns the latest rates.
    ///
    /// - Parameters:
    ///     - amount: The amount to convert from. Defaults to `1`.
    ///     - currency: The currency to quote from. Defaults to ``Currency/eur``
    ///     - currency: Limit the returned rates. Empty returns all available currencies.
    /// - Returns: The current currency exchange rates
    public func latest(
        amount: Double = 1,
        from currency: Currency? = nil,
        to currencies: [Currency] = []
    ) async throws -> Data {
        var components = host
        components.queryItems = [
            URLQueryItem(name: "amount", amount: amount),
            URLQueryItem(name: "from", currency: currency),
            URLQueryItem(name: "to", currencies: currencies)
        ]
        .compactMap { $0 }
        components.path = "/latest"
        
        guard let url = components.url else { throw Frankfurter.Error.invalidQuery }
        
        let request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)
        return try decode(Data.self, from: data, with: response)
    }
    
    /// This endpoint returns historical rates.
    ///
    ///  - Parameters:
    ///     - date: The date to get historical exchange rates from. Earliest date is 4 January 1999.
    ///     - amount: The amount to convert from. Defaults to `1`.
    ///     - currency: The currency to quote from. Defaults to ``Currency/eur``
    ///     - currencies: Limit the returned rates. Empty returns all available currencies.
    /// - Returns: The currency exchange rates on the given date.
    public func historical(
        date: Date,
        amount: Double = 1,
        from currency: Currency? = nil,
        to currencies: [Currency] = []
    ) async throws -> Data {
        var components = host
        components.queryItems = [
            URLQueryItem(name: "amount", amount: amount),
            URLQueryItem(name: "from", currency: currency),
            URLQueryItem(name: "to", currencies: currencies)
        ]
        .compactMap { $0 }
        components.path = "/\(Frankfurter.dateFormatter.string(from: date))"
        
        guard let url = components.url else { throw Frankfurter.Error.invalidQuery }
        
        let request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)
        return try decode(Data.self, from: data, with: response)
    }
    
    /// This endpoint returns a time series of rates.
    ///
    ///  - Parameters:
    ///     - range: The date range to get historical exchange rates from. Earliest date is 4 January 1999.
    ///     - amount: The amount to convert from. Defaults to `1`.
    ///     - currency: The currency to quote from. Defaults to ``Currency/eur``
    ///     - currencies: Limit the returned rates. Empty returns all available currencies.
    /// - Returns: The currency exchange rates on the given date.
    public func timeSeries(
        range: ClosedRange<Date>,
        amount: Double = 1,
        from currency: Currency? = nil,
        to currencies: [Currency] = []
    ) async throws -> TimeSeries {
        var components = host
        components.queryItems = [
            URLQueryItem(name: "amount", amount: amount),
            URLQueryItem(name: "from", currency: currency),
            URLQueryItem(name: "to", currencies: currencies)
        ]
        .compactMap { $0 }
        components.path = "/\(Frankfurter.dateFormatter.string(from: range.lowerBound))..\(Frankfurter.dateFormatter.string(from: range.upperBound))"
        
        guard let url = components.url else { throw Frankfurter.Error.invalidQuery }
        
        let request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)
        return try decode(TimeSeries.self, from: data, with: response)
    }
    
    /// This endpoint returns a time series of rates.
    ///
    ///  - Parameters:
    ///     - range: The date range to get historical exchange rates from. Earliest date is 4 January 1999.
    ///     - amount: The amount to convert from. Defaults to `1`.
    ///     - currency: The currency to quote from. Defaults to ``Currency/eur``
    ///     - currencies: Limit the returned rates. Empty returns all available currencies.
    /// - Returns: The currency exchange rates on the given date.
    public func timeSeries(
        range: PartialRangeFrom<Date>,
        amount: Double = 1,
        from currency: Currency? = nil,
        to currencies: [Currency] = []
    ) async throws -> TimeSeries {
        var components = host
        components.queryItems = [
            URLQueryItem(name: "amount", amount: amount),
            URLQueryItem(name: "from", currency: currency),
            URLQueryItem(name: "to", currencies: currencies)
        ]
        .compactMap { $0 }
        components.path = "/\(Frankfurter.dateFormatter.string(from: range.lowerBound)).."
        
        guard let url = components.url else { throw Frankfurter.Error.invalidQuery }
        
        let request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)
        return try decode(TimeSeries.self, from: data, with: response)
    }
    
    private func decode<T>(_ type: T.Type, from data: Foundation.Data, with response: URLResponse) throws -> T where T: Decodable {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw Frankfurter.Error.invalidResponse
        }
        
        switch httpResponse.statusCode / 100 {
        case 4:
            do {
                let errorResponse = try Frankfurter.jsonDecoder.decode(ErrorResponse.self, from: data)
                throw Frankfurter.Error.clientError(httpResponse.statusCode, message: errorResponse.message)
            } catch {
                throw Frankfurter.Error.clientError(httpResponse.statusCode)
            }
        case 5:
            throw Frankfurter.Error.serverError(httpResponse.statusCode)
        default:
            return try Frankfurter.jsonDecoder.decode(T.self, from: data)
        }
    }
}

extension URLQueryItem {
    init?(name: String, currency: Frankfurter.Currency?) {
        guard let currency else { return nil }
        self.init(name: name, value: currency.rawValue)
    }
    
    init?(name: String, currencies: [Frankfurter.Currency]) {
        guard !currencies.isEmpty else { return nil }
        self.init(name: name, value: currencies.map { $0.rawValue }.joined(separator: ","))
    }
    
    init?(name: String, amount: Double) {
        guard amount != 1 else { return nil }
        self.init(name: name, value: amount.description)
    }
}
