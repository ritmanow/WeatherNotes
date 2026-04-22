import XCTest
@testable import WeatherNotes

final class WindDirectionTests: XCTestCase {
    func testCardinalNorthMatchesFullRotation() {
        let a = WindDirection.cardinalSymbol(degrees: 0)
        let b = WindDirection.cardinalSymbol(degrees: 360)
        XCTAssertEqual(a, b)
        XCTAssertFalse(a.isEmpty)
    }

    func testCardinalEast() {
        let east = WindDirection.cardinalSymbol(degrees: 90)
        XCTAssertFalse(east.isEmpty)
    }
}
