import SwiftUI

@MainActor
struct AddCityView: View {
    @EnvironmentObject private var store: CityStore
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private var results: [City] { CityCatalog.all.filter { $0.matches(query) } }

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
                                    let isSaved = store.state.cityIDs.contains(city.id)
                                    Button {
                                        store.add(city)
                                        dismiss()
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 5) {
                                                Text(city.name).font(.headline).foregroundStyle(.primary)
                                                Text("\(city.englishName) · \(city.country)")
                                                    .font(.caption).foregroundStyle(.secondary)
                                            }
                                            Spacer()
                                            Image(systemName: isSaved ? "checkmark.circle.fill" : "plus.circle")
                                                .font(.title3)
                                                .foregroundStyle(isSaved ? Color.secondary : Color(hex: 0xE5BC8B))
                                        }
                                        .padding(.vertical, 5)
                                    }
                                    .disabled(isSaved)
                                    .accessibilityLabel("\(city.name)，\(city.country)，\(isSaved ? "已收藏" : "加入收藏")")
                                    .accessibilityIdentifier("add-\(city.id)")
                                }
                            } header: {
                                Text("\(region.rawValue) · \(cities.count) 座城市")
                            }
                        }
                    }
                    Section {
                        Text("倫敦、臺北與紐約配有專屬景色，其他城市使用光影城市剪影。")
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
