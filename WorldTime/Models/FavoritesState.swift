import Foundation

/// 純資料模型，與畫面分開，方便測試收藏及重開 App 後的恢復行為。
struct FavoritesState: Codable, Equatable {
    private(set) var cityIDs: [String]
    private(set) var selectedID: String

    static let initial = FavoritesState(
        cityIDs: CityCatalog.defaults.map(\.id), selectedID: "london"
    )

    init(cityIDs: [String], selectedID: String) {
        var seen = Set<String>()
        let validIDs = cityIDs.filter { CityCatalog.city(id: $0) != nil && seen.insert($0).inserted }
        self.cityIDs = validIDs.isEmpty ? CityCatalog.defaults.map(\.id) : validIDs
        self.selectedID = self.cityIDs.contains(selectedID) ? selectedID : self.cityIDs[0]
    }

    static func restored(from data: Data?) -> FavoritesState {
        guard let data, let decoded = try? JSONDecoder().decode(FavoritesState.self, from: data) else {
            return .initial
        }
        // Codable 解碼後再清理舊版、重複或已移除的城市。
        return FavoritesState(cityIDs: decoded.cityIDs, selectedID: decoded.selectedID)
    }

    mutating func select(_ city: City) {
        guard cityIDs.contains(city.id) else { return }
        selectedID = city.id
    }

    mutating func add(_ city: City) {
        guard CityCatalog.city(id: city.id) != nil, !cityIDs.contains(city.id) else { return }
        cityIDs.append(city.id)
    }

    mutating func remove(ids: [String]) {
        let remaining = cityIDs.filter { !ids.contains($0) }
        guard !remaining.isEmpty else { return }
        self = FavoritesState(cityIDs: remaining, selectedID: selectedID)
    }

    mutating func reorder(_ ids: [String]) {
        guard ids.count == cityIDs.count, Set(ids) == Set(cityIDs) else { return }
        cityIDs = ids
    }
}
