import SwiftUI
import UIKit

@MainActor
struct HomeView: View {
    @EnvironmentObject private var store: CityStore
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showFavorites = false
    @State private var showAddCity = false
    @State private var showAbout = false
    @State private var clockID = UUID()

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            content(at: context.date)
        }
        .id(clockID)
        .background(PeriodTheme.background.ignoresSafeArea())
        .sheet(isPresented: $showFavorites) { FavoritesView() }
        .sheet(isPresented: $showAddCity) { AddCityView() }
        .sheet(isPresented: $showAbout) { AboutView() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { clockID = UUID() }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            clockID = UUID()
        }
    }

    private func content(at date: Date) -> some View {
        let city = store.selectedCity
        let period = DayPeriod.at(date, in: city.timeZone)

        return ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header

                VStack(spacing: 18) {
                    CityHeroCard(city: city, date: date)
                    PeriodStrip(current: period)
                }

                cityPicker

                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("世界的此刻")
                            .font(.system(size: 20, weight: .semibold, design: .serif))
                        Text("與\(city.name)一起，看見世界的時間")
                            .font(.caption)
                            .foregroundStyle(PeriodTheme.muted)
                    }
                    Spacer()
                    Button { showAddCity = true } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .medium))
                            .frame(width: 44, height: 44)
                            .background(.white.opacity(0.06), in: Circle())
                    }
                    .accessibilityLabel("新增城市")
                    .accessibilityIdentifier("addCityButton")
                }
                .padding(.top, 8)

                VStack(spacing: 10) {
                    ForEach(store.cities.filter { $0.id != city.id }) { other in
                        Button { select(other) } label: {
                            CityTimeRow(city: other, reference: city, date: date)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("cityRow-\(other.id)")
                    }

                    if store.cities.count == 1 {
                        Button { showAddCity = true } label: {
                            Label("收藏下一座城市，讓世界靠近一點", systemImage: "globe.asia.australia")
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, minHeight: 90)
                                .background(PeriodTheme.surface, in: RoundedRectangle(cornerRadius: 20))
                        }
                    }
                }

                Button { showAbout = true } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("\(ClockFormatting.zoneDetail(date, in: city)) · 自動同步")
                        Image(systemName: "info.circle")
                    }
                    .font(.system(size: 11))
                    .foregroundStyle(PeriodTheme.muted)
                    .frame(maxWidth: .infinity, minHeight: 44)
                }
                .accessibilityLabel("時區與光影說明，\(ClockFormatting.zoneDetail(date, in: city))")
            }
            .padding(.horizontal, 22)
            .padding(.top, 16)
            .padding(.bottom, 20)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .foregroundStyle(.white)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 9) {
                    Image(systemName: "circle.lefthalf.filled")
                        .font(.system(size: 19))
                        .foregroundStyle(Color(hex: 0xE5BC8B))
                    Text("光影時鐘")
                        .font(.system(size: 22, weight: .semibold, design: .serif))
                }
                Text("在光影裡，遇見此刻。")
                    .font(.caption)
                    .foregroundStyle(PeriodTheme.muted)
            }
            Spacer()
            Button { showFavorites = true } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 17))
                    .foregroundStyle(.white.opacity(0.85))
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.06), in: Circle())
            }
            .accessibilityLabel("編輯收藏城市")
            .accessibilityIdentifier("editFavoritesButton")
        }
    }

    private var cityPicker: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 9) {
                    ForEach(store.cities) { city in
                        Button { select(city) } label: {
                            HStack(spacing: 6) {
                                if city.id == store.state.selectedID {
                                    Circle().fill(Color(hex: 0xE5BC8B)).frame(width: 5, height: 5)
                                }
                                Text(city.name).font(.system(size: 13, weight: .medium))
                            }
                            .foregroundStyle(city.id == store.state.selectedID ? .white : PeriodTheme.muted)
                            .padding(.horizontal, 17)
                            .frame(minHeight: 44)
                            .background(city.id == store.state.selectedID ? Color.white.opacity(0.12) : Color.white.opacity(0.04), in: Capsule())
                            .overlay(Capsule().strokeBorder(.white.opacity(city.id == store.state.selectedID ? 0.15 : 0.04)))
                        }
                        .buttonStyle(.plain)
                        .id(city.id)
                        .accessibilityIdentifier("cityChip-\(city.id)")
                        .accessibilityAddTraits(city.id == store.state.selectedID ? [.isSelected] : [])
                    }
                }
            }
            .onChange(of: store.state.selectedID) { _, id in
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                    proxy.scrollTo(id, anchor: .center)
                }
            }
            .onAppear {
                proxy.scrollTo(store.state.selectedID, anchor: .center)
            }
        }
    }

    private func select(_ city: City) {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) {
            store.select(city)
        }
    }
}

#Preview { HomeView().environmentObject(CityStore(defaults: .preview)) }

extension UserDefaults {
    static var preview: UserDefaults {
        let defaults = UserDefaults(suiteName: "lightAndTime.preview")!
        defaults.removePersistentDomain(forName: "lightAndTime.preview")
        return defaults
    }
}
