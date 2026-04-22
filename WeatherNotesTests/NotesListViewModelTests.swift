import XCTest
@testable import WeatherNotes

@MainActor
final class NotesListViewModelTests: XCTestCase {
    func testNoteCountSubtitleIncludesCount() {
        let s0 = NotesListViewModel.noteCountSubtitle(forCount: 0)
        XCTAssertTrue(s0.contains("0"))

        let s1 = NotesListViewModel.noteCountSubtitle(forCount: 1)
        XCTAssertTrue(s1.contains("1"))

        let s5 = NotesListViewModel.noteCountSubtitle(forCount: 5)
        XCTAssertTrue(s5.contains("5"))
    }

    func testListConditionLineMatchesWeatherConditionDisplay() throws {
        let ctx = try TestDataSupport.inMemoryViewContext()
        let note = try TestDataSupport.insertSampleNote(context: ctx, weatherDescription: "  drizzle  ")
        let vm = NotesListViewModel(viewContext: ctx)
        let expected = WeatherConditionDisplay.phrase(
            apiDescription: note.weatherDescription ?? "",
            weatherMain: note.weatherMain ?? ""
        )
        XCTAssertEqual(vm.listConditionLine(for: note), expected)
    }

    func testDeleteRemovesNote() throws {
        let ctx = try TestDataSupport.inMemoryViewContext()
        let note = try TestDataSupport.insertSampleNote(context: ctx)
        let vm = NotesListViewModel(viewContext: ctx)
        XCTAssertEqual(vm.notes.count, 1)
        vm.delete(note)
        XCTAssertTrue(vm.notes.isEmpty)
    }
}
