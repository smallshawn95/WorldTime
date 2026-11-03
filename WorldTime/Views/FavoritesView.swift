import SwiftUI

@MainActor
struct FavoritesView: View {
    @EnvironmentObject private var store: CityStore
    @Environment(\.dismiss) private var dismiss
    @State private var showAddCity = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(store.cities) { city in
                        Button {
                            store.select(city)
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundStyle(Color(hex: 0xE5BC8B))
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(city.name).foregroundStyle(.primary)
                                    Text("\(city.englishName) · \(city.country)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if city.id == store.state.selectedID {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color(hex: 0xE5BC8B))
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .deleteDisabled(store.cities.count == 1)
                    }
                    .onDelete(perform: store.remove)
                    .onMove(perform: store.move)
                } header: {
                    Text("\(store.cities.count) 座收藏城市")
                } footer: {
                    Text("點選城市即可設為首頁。點「編輯」可刪除或拖曳排序；至少保留一座城市。")
                }

                Section {
                    Button { showAddCity = true } label: {
                        Label("新增城市", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("收藏城市")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { EditButton() }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
            .sheet(isPresented: $showAddCity) { AddCityView() }
        }
        .preferredColorScheme(.dark)
    }
}
