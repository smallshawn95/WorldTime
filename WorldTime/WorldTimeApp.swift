import SwiftUI

@main
@MainActor
struct WorldTimeApp: App {
    @StateObject private var store = CityStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
                .tint(Color(hex: 0xE5BC8B))
        }
    }
}
