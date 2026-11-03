import SwiftUI

@MainActor
final class CityStore: ObservableObject {
    @Published private(set) var state: FavoritesState
    private let defaults: UserDefaults
    private let key = "lightAndTime.favorites.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        state = FavoritesState.restored(from: defaults.data(forKey: key))
    }

    var cities: [City] { state.cityIDs.compactMap { CityCatalog.city(id: $0) } }
    var selectedCity: City { CityCatalog.city(id: state.selectedID) ?? CityCatalog.defaults[0] }

    func select(_ city: City) {
        state.select(city)
        save()
    }

    func add(_ city: City) {
        state.add(city)
        save()
    }

    func remove(at offsets: IndexSet) {
        let ids = offsets.compactMap { state.cityIDs.indices.contains($0) ? state.cityIDs[$0] : nil }
        state.remove(ids: ids)
        save()
    }

    func move(from source: IndexSet, to destination: Int) {
        var ids = state.cityIDs
        ids.move(fromOffsets: source, toOffset: destination)
        state.reorder(ids)
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: key)
    }
}
