import XCTest
@testable import WeatherNotes

@MainActor
final class NoteDetailViewModelTests: XCTestCase {
    func testHeroWeatherDescriptionMatchesWeatherConditionDisplay() throws {
        let ctx = try TestDataSupport.inMemoryViewContext()
        let note = try TestDataSupport.insertSampleNote(context: ctx, weatherDescription: "overcast clouds")
        let vm = NoteDetailViewModel(note: note)
        let expected = WeatherConditionDisplay.phrase(
            apiDescription: note.weatherDescription ?? "",
            weatherMain: note.weatherMain ?? ""
        )
        XCTAssertEqual(vm.heroWeatherDescription, expected)
    }

    func testWindDirectionDegreesRoundedNormalized() throws {
        let ctx = try TestDataSupport.inMemoryViewContext()
        let note = try TestDataSupport.insertSampleNote(
            context: ctx,
            weatherDescription: "clear sky",
            weatherMain: "clear",
            windDirection: 180
        )
        let vm = NoteDetailViewModel(note: note)
        XCTAssertEqual(vm.windDirectionDegreesText(), "180°")
    }

    func testWindDirectionNonFiniteShowsDash() throws {
        let ctx = try TestDataSupport.inMemoryViewContext()
        let note = try TestDataSupport.insertSampleNote(context: ctx, windDirection: 45)
        note.windDirection = .nan
        let vm = NoteDetailViewModel(note: note)
        XCTAssertEqual(vm.windDirectionDegreesText(), "—")
    }
}
