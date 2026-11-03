import XCTest
#if SWIFT_PACKAGE
@testable import CityClockCore
#else
@testable import WorldTime
#endif

final class FavoritesTests: XCTestCase {
    func testInvalidAndDuplicateIDsAreCleaned() {
        let state = FavoritesState(cityIDs: ["gone", "taipei", "taipei", "london"], selectedID: "gone")
        XCTAssertEqual(state.cityIDs, ["taipei", "london"])
        XCTAssertEqual(state.selectedID, "taipei")
    }

    func testEmptyFavoritesRecoverDefaults() {
        XCTAssertEqual(FavoritesState(cityIDs: [], selectedID: "missing"), .initial)
    }

    func testBrokenStorageRecoversDefaults() {
        XCTAssertEqual(FavoritesState.restored(from: nil), .initial)
        XCTAssertEqual(FavoritesState.restored(from: Data("invalid".utf8)), .initial)
        XCTAssertEqual(FavoritesState.restored(from: Data("{}".utf8)), .initial)
    }

    func testOldStorageIsSanitizedOnRead() {
        let data = Data(#"{"cityIDs":["removed","taipei","taipei"],"selectedID":"removed"}"#.utf8)
        let restored = FavoritesState.restored(from: data)
        XCTAssertEqual(restored.cityIDs, ["taipei"])
        XCTAssertEqual(restored.selectedID, "taipei")
    }

    func testDuplicateAddIsIgnored() {
        var state = FavoritesState.initial
        state.add(CityCatalog.defaults[0])
        XCTAssertEqual(state.cityIDs.count, 3)
        state.add(CityCatalog.city(id: "tokyo")!)
        XCTAssertEqual(state.cityIDs.last, "tokyo")
    }

    func testRemovingSelectedCityPicksRemainingCity() {
        var state = FavoritesState.initial
        state.remove(ids: ["london"])
        XCTAssertEqual(state.cityIDs, ["taipei", "new-york"])
        XCTAssertEqual(state.selectedID, "taipei")
    }

    func testCannotRemoveLastCity() {
        var state = FavoritesState(cityIDs: ["taipei"], selectedID: "taipei")
        state.remove(ids: ["taipei"])
        XCTAssertEqual(state.cityIDs, ["taipei"])
        XCTAssertEqual(state.selectedID, "taipei")
    }

    func testBulkRemovalCannotLeaveEmptyState() {
        var state = FavoritesState.initial
        state.remove(ids: state.cityIDs)
        XCTAssertEqual(state, .initial)
    }

    func testReorderPreservesSelectedCity() {
        var state = FavoritesState.initial
        state.reorder(["new-york", "taipei", "london"])
        XCTAssertEqual(state.cityIDs, ["new-york", "taipei", "london"])
        XCTAssertEqual(state.selectedID, "london")
        state.reorder(["taipei", "taipei", "london"])
        XCTAssertEqual(state.cityIDs, ["new-york", "taipei", "london"])
    }

    func testSelectingUnsavedCityIsIgnored() {
        var state = FavoritesState.initial
        state.select(CityCatalog.city(id: "tokyo")!)
        XCTAssertEqual(state.selectedID, "london")
    }

    func testSelectionAndOrderSurviveRoundTrip() throws {
        var state = FavoritesState.initial
        state.select(CityCatalog.city(id: "taipei")!)
        state.reorder(["taipei", "new-york", "london"])
        let encoded = try JSONEncoder().encode(state)
        XCTAssertEqual(FavoritesState.restored(from: encoded), state)
    }
}
