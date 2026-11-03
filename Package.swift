// swift-tools-version: 5.9
import PackageDescription

// 不依賴 SwiftUI 的時間與收藏邏輯，可在有 Swift 的 Mac / Linux 上獨立測試。
let package = Package(
    name: "CityClockCore",
    platforms: [.iOS(.v17), .macOS(.v13)],
    products: [.library(name: "CityClockCore", targets: ["CityClockCore"])],
    targets: [
        .target(name: "CityClockCore", path: "WorldTime/Models"),
        .testTarget(name: "CityClockCoreTests", dependencies: ["CityClockCore"], path: "WorldTimeTests")
    ]
)
