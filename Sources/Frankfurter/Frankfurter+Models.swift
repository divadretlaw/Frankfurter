//
//  Frankfurter+Models.swift
//  Frankfurter
//
//  Created by David Walter on 10.04.23.
//

import Foundation

extension Frankfurter {
    /// Response data from the API
    public struct Data: Codable, Sendable {
        /// The amount of the base ``Currency`` that the rates compare to
        public let amount: Double
        /// The base currency
        public let base: Currency
        /// The date the data is from
        public let date: Date
        /// The exchange rates
        public let rates: [Currency: Double]
        
        enum CodingKeys: CodingKey {
            case amount
            case base
            case date
            case rates
        }
        
        /// Creates a new instance by decoding from the given decoder.
        ///
        /// This initializer throws an error if reading from the decoder fails, or
        /// if the data read is corrupted or otherwise invalid.
        ///
        /// - Parameter decoder: The decoder to read data from.
        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            
            self.amount = try container.decode(Double.self, forKey: .amount)
            self.base = try container.decode(Currency.self, forKey: .base)
            self.date = try container.decode(Date.self, forKey: .date)
            self.rates = try container.decode(Double.self, keyedBy: Currency.self, forKey: .rates)
        }
    }
    
    /// Response data representing a time series from the API
    public struct TimeSeries: Codable, Sendable {
        /// The amount of the base ``Currency`` that the rates compare to
        public let amount: Double
        /// The base currency
        public let base: Currency
        /// The start date the data is from
        public let startDate: Date
        /// The end date the data is from
        public let endDate: Date
        /// The exchange rates for a date between ``startDate`` and ``endDate``
        public let rates: [Date: [Currency: Double]]
        
        enum CodingKeys: CodingKey {
            case amount
            case base
            case startDate
            case endDate
            case rates
        }
        
        /// Creates a new instance by decoding from the given decoder.
        ///
        /// This initializer throws an error if reading from the decoder fails, or
        /// if the data read is corrupted or otherwise invalid.
        ///
        /// - Parameter decoder: The decoder to read data from.
        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            
            self.amount = try container.decode(Double.self, forKey: .amount)
            self.base = try container.decode(Currency.self, forKey: .base)
            self.startDate = try container.decode(Date.self, forKey: .startDate)
            self.endDate = try container.decode(Date.self, forKey: .endDate)
            let dateRatesContainer = try container.nestedContainer(keyedBy: DateKey.self, forKey: .rates)
            var dateRates: [Date: [Currency: Double]] = [:]
            for key in dateRatesContainer.allKeys {
                guard let key = DateKey(stringValue: key.stringValue) else {
                    continue
                }
                
                dateRates[key.date] = try dateRatesContainer.decode(Double.self, keyedBy: Currency.self, forKey: key)
            }
            self.rates = dateRates
        }
    }
    
    /// Supported currencies
    public enum Currency: String, Hashable, Equatable, Codable, CaseIterable, CodingKey, CodingKeyRepresentable, Sendable {
        /// Australian Dollar
        case aud = "AUD"
        /// Bulgarian Lev
        case bgn = "BGN"
        /// Brazilian Real
        case brl = "BRL"
        /// Candadian Dollar
        case cad = "CAD"
        /// Swiss Franc
        case chf = "CHF"
        /// Chinese Renminbi Yuan
        case cny = "CNY"
        /// Czech Koruna
        case czk = "CZK"
        /// Danish Krone
        case dkk = "DKK"
        /// Euro
        case eur = "EUR"
        /// British Pound
        case gbp = "GBP"
        /// Hong Kong Dollar
        case hkd = "HKD"
        /// Hungarian Forint
        case huf = "HUF"
        /// Indonesian Rupiah
        case idr = "IDR"
        /// Israeli New Sheqel
        case ils = "ILS"
        /// Indian Rupee
        case inr = "INR"
        /// Icelandic Króna
        case isk = "ISK"
        /// Japanese Yen
        case jpy = "JPY"
        /// South Korean Won
        case krw = "KRW"
        /// Mexican Peso
        case mxn = "MXN"
        /// Malaysian Ringgit
        case myr = "MYR"
        /// Norwegian Krone
        case nok = "NOK"
        /// New Zealand Dollar
        case nzd = "NZD"
        /// Philippine Peso
        case php = "PHP"
        /// Polish Złoty
        case pln = "PLN"
        /// Romanian Leu
        case ron = "RON"
        /// Swedish Krona
        case sek = "SEK"
        /// Singapore Dollar
        case sgd = "SGD"
        /// Thai Baht
        case thb = "THB"
        /// Turkish Lira
        case `try` = "TRY"
        /// United States Dollar
        case usd = "USD"
        /// South African Rand
        case zar = "ZAR"
        
        /// Localized description of the ``Currency``
        public var localizedDescription: String {
            Locale.current.localizedString(forCurrencyCode: rawValue) ?? rawValue
        }
        
        /// Currency symbol of the ``Currency`` if applicable
        public var currencySymbol: String {
            switch self {
            case .aud:
                return "$"
            case .bgn:
                return "лв."
            case .brl:
                return "$"
            case .cad:
                return "$"
            case .cny:
                return "¥"
            case .czk:
                return "Kč"
            case .dkk:
                return "kr."
            case .eur:
                return "€"
            case .gbp:
                return "£"
            case .hkd:
                return "$"
            case .huf:
                return "Ft"
            case .idr:
                return "Rp"
            case .ils:
                return "₪"
            case .inr:
                return "₹"
            case .isk:
                return "kr"
            case .jpy:
                return "¥"
            case .krw:
                return "₩"
            case .mxn:
                return "$"
            case .myr:
                return "RM"
            case .nok:
                return "kr"
            case .nzd:
                return "$"
            case .php:
                return "₱"
            case .pln:
                return "zł"
            case .sek:
                return "kr"
            case .sgd:
                return "$"
            case .thb:
                return "฿"
            case .try:
                return "₺"
            case .usd:
                return "$"
            case .zar:
                return "R"
            default:
                return rawValue
            }
        }
        
        /// The country emoji of the ``Currency``
        public var emoji: String {
            switch self {
            case .aud:
                return "🇦🇺"
            case .bgn:
                return "🇧🇬"
            case .brl:
                return "🇧🇷"
            case .cad:
                return "🇨🇦"
            case .chf:
                return "🇨🇭"
            case .cny:
                return "🇨🇳"
            case .czk:
                return "🇨🇿"
            case .dkk:
                return "🇩🇰"
            case .eur:
                return "🇪🇺"
            case .gbp:
                return "🇬🇧"
            case .hkd:
                return "🇭🇰"
            case .huf:
                return "🇭🇺"
            case .idr:
                return "🇮🇩"
            case .ils:
                return "🇮🇱"
            case .inr:
                return "🇮🇳"
            case .isk:
                return "🇮🇸"
            case .jpy:
                return "🇯🇵"
            case .krw:
                return "🇰🇷"
            case .mxn:
                return "🇲🇽"
            case .myr:
                return "🇲🇾"
            case .nok:
                return "🇳🇴"
            case .nzd:
                return "🇳🇿"
            case .php:
                return "🇵🇭"
            case .pln:
                return "🇵🇱"
            case .ron:
                return "🇷🇴"
            case .sek:
                return "🇸🇪"
            case .sgd:
                return "🇸🇬"
            case .thb:
                return "🇹🇭"
            case .try:
                return "🇹🇷"
            case .usd:
                return "🇺🇸"
            case .zar:
                return "🇿🇦"
            }
        }
    }
    
    struct DateKey: CodingKey {
        let date: Date
        
        init?(stringValue: String) {
            guard let date = Frankfurter.dateFormatter.date(from: stringValue) else { return nil }
            self.date = date
        }
        
        init?(intValue: Int) { nil }
        
        var stringValue: String { Frankfurter.dateFormatter.string(from: date) }
        var intValue: Int? { nil }
    }
}

extension KeyedDecodingContainer {
    public func decode<T, D>(_ value: T.Type, keyedBy: D.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> [D: T] where D: CodingKey, T: Decodable {
        let container = try self.nestedContainer(keyedBy: D.self, forKey: key)
        var dictionary: [D: T] = [:]
        for key in container.allKeys {
            dictionary[key] = try container.decodeIfPresent(T.self, forKey: key)
        }
        return dictionary
    }
}
