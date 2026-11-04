import SwiftUI

@MainActor
struct AddCityView: View {
    @EnvironmentObject private var store: CityStore
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private var results: [City] { CityCatalog.searchRepresentatives(query) }

    var body: some View {
        NavigationStack {
            List {
                if results.isEmpty {
                    ContentUnavailableView.search(text: query)
                } else {
                    ForEach(CityRegion.allCases) { region in
                        let cities = results.filter { $0.region == region }
                        if !cities.isEmpty {
                            Section {
                                ForEach(cities) { city in
                                    let savedCity = store.cities.first { $0.id == city.id }
                                        ?? store.cities.first {
                                            CityCatalog.representativeID(forCityID: $0.id) == city.id
                                        }
                                    let savedStatus: String? = savedCity.map { saved in
                                        saved.id == city.id ? "已收藏" : "同時區已收藏：\(saved.name)"
                                    }
                                    Button {
                                        store.add(city)
                                        dismiss()
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 5) {
                                                Text(city.name).font(.headline).foregroundStyle(.primary)
                                                Text("\(city.englishName) · \(city.country)")
                                                    .font(.caption).foregroundStyle(.secondary)
                                                if let savedStatus {
                                                    Text(savedStatus)
                                                        .font(.caption)
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
                                            Spacer()
                                            Image(systemName: savedCity != nil ? "checkmark.circle.fill" : "plus.circle")
                                                .font(.title3)
                                                .foregroundStyle(savedCity != nil ? Color.secondary : Color(hex: 0xE5BC8B))
                                        }
                                        .padding(.vertical, 5)
                                    }
                                    .disabled(savedCity != nil)
                                    .accessibilityLabel("\(city.name)，\(city.country)，\(savedStatus ?? "加入收藏")")
                                    .accessibilityIdentifier("add-\(city.id)")
                                }
                            } header: {
                                Text("\(region.rawValue) · \(cities.count) 座城市")
                            }
                        }
                    }
                    Section {
                        Text("新增清單收錄精選代表城市；搜尋其他城市時，若同時區的代表已收錄，也會顯示該代表。")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("新增城市")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "搜尋城市、國家或英文名稱")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
