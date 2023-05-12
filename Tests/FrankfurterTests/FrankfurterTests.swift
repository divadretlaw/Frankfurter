import XCTest
@testable import Frankfurter

final class FrankfurterTests: XCTestCase {
    var frankfurter: Frankfurter!
    override func setUp() async throws {
        try await super.setUp()
        
        self.frankfurter = Frankfurter()
    }
    
    func testDecodable() async throws {
        let json = #"{"amount":1.0,"base":"EUR","date":"2023-04-06","rates":{"AUD":1.6312,"BGN":1.9558,"BRL":5.5096,"CAD":1.4704,"CHF":0.9878,"CNY":7.5014,"CZK":23.409,"DKK":7.451,"GBP":0.87495,"HKD":8.5682,"HUF":376.1,"IDR":16291,"ILS":3.9261,"INR":89.37,"ISK":149.7,"JPY":143.49,"KRW":1438.81,"MXN":19.9624,"MYR":4.8015,"NOK":11.3855,"NZD":1.7387,"PHP":59.562,"PLN":4.6863,"RON":4.9369,"SEK":11.3875,"SGD":1.4507,"THB":37.171,"TRY":21.02,"USD":1.0915,"ZAR":19.8929}}"#
        _ = try Frankfurter.jsonDecoder.decode(Frankfurter.Data.self, from: Data(json.utf8))
    }
    
    func testCodable() async throws {
        let json = #"{"amount":1.0,"base":"EUR","date":"2023-04-06","rates":{"AUD":1.6312,"BGN":1.9558,"BRL":5.5096,"CAD":1.4704,"CHF":0.9878,"CNY":7.5014,"CZK":23.409,"DKK":7.451,"GBP":0.87495,"HKD":8.5682,"HUF":376.1,"IDR":16291,"ILS":3.9261,"INR":89.37,"ISK":149.7,"JPY":143.49,"KRW":1438.81,"MXN":19.9624,"MYR":4.8015,"NOK":11.3855,"NZD":1.7387,"PHP":59.562,"PLN":4.6863,"RON":4.9369,"SEK":11.3875,"SGD":1.4507,"THB":37.171,"TRY":21.02,"USD":1.0915,"ZAR":19.8929}}"#
        let data = try Frankfurter.jsonDecoder.decode(Frankfurter.Data.self, from: Data(json.utf8))
        let encoded = try JSONEncoder().encode(data)
        if let encodedJson = String(data: encoded, encoding: .utf8) {
            print(encodedJson)
        }
        _ = try JSONDecoder().decode(Frankfurter.Data.self, from: encoded)
    }
    
    func testLatest() async throws {
        let data = try await frankfurter.latest()
        XCTAssertEqual(data.amount, 1)
        XCTAssertEqual(data.base, .eur)
        XCTAssertNotNil(data.rates[.usd])
        XCTAssertNil(data.rates[.eur])
    }
    
    func testLatest_Amount() async throws {
        let data = try await frankfurter.latest(amount: 2)
        XCTAssertEqual(data.amount, 2)
        XCTAssertEqual(data.base, .eur)
        XCTAssertNotNil(data.rates[.usd])
        XCTAssertNil(data.rates[.eur])
    }
    
    func testConversion() async throws {
        let data = try await frankfurter.latest()
        let conversion = try await frankfurter.latest(amount: 10, from: .usd, to: [.eur])
        
        guard let usd = data.rates[.usd], let eur = conversion.rates[.eur] else {
            return XCTFail()
        }
        XCTAssertEqual(1 / usd * 10, eur, accuracy: 0.01)
    }
    
    func testLatest_Limited() async throws {
        let data = try await frankfurter.latest(to: [.usd])
        XCTAssertEqual(data.amount, 1)
        XCTAssertEqual(data.base, .eur)
        XCTAssertNotNil(data.rates[.usd])
        XCTAssertNil(data.rates[.eur])
    }
    
    func testLatest_From() async throws {
        let data = try await frankfurter.latest(from: .usd)
        XCTAssertEqual(data.amount, 1)
        XCTAssertEqual(data.base, .usd)
        XCTAssertNotNil(data.rates[.eur])
        XCTAssertNil(data.rates[.usd])
    }
    
    func testHistorical_Invalid() async throws {
        do {
            _ = try await frankfurter.historical(date: .distantPast)
            XCTFail("Expected error")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func testHistorical() async throws {
        let data = try await frankfurter.historical(date: Date(timeIntervalSinceReferenceDate: 0))
        XCTAssertEqual(data.amount, 1)
        XCTAssertEqual(data.base, .eur)
        XCTAssertEqual(data.rates[.usd], 0.9305)
    }
    
    func testTimeSeries() async throws {
        let fromDate = Date(timeIntervalSinceReferenceDate: 0)
        let toDate = Date(timeIntervalSinceReferenceDate: 24 * 60 * 60 + 1)
        let data = try await frankfurter.timeSeries(range: fromDate...toDate)
        XCTAssertEqual(data.amount, 1)
        XCTAssertEqual(data.base, .eur)
        for (_, value) in data.rates {
            XCTAssertNotNil(value[.usd])
        }
    }
    
    func testInvalidHost() async throws {
        do {
            _ = try await Frankfurter(host: URL(string: "https://endpoint-does-not-exist.example.com")!).latest()
            XCTFail("Expected error")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func testCurrencies() async throws {
        for currency in Frankfurter.Currency.allCases {
            print("\(currency.rawValue) - \(currency.localizedDescription) (\(currency.currencySymbol))")
        }
    }
}
