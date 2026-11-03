import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB, red: Double((hex >> 16) & 255) / 255,
                  green: Double((hex >> 8) & 255) / 255,
                  blue: Double(hex & 255) / 255, opacity: 1)
    }
}

struct PeriodTheme {
    let sky: [Color]
    let accent: Color
    let cityTint: Color
    let cityBrightness: Double
    let orbPosition: UnitPoint

    static let background = Color(hex: 0x0B111B)
    static let surface = Color(hex: 0x151E2B)
    static let muted = Color(hex: 0xAAB6C6)

    static func forPeriod(_ period: DayPeriod) -> PeriodTheme {
        switch period {
        case .dawn:
            return PeriodTheme(sky: [Color(hex: 0x343551), Color(hex: 0xA47C99), Color(hex: 0xECC5AF)],
                accent: Color(hex: 0xF2C4CD), cityTint: Color(hex: 0xC5BDDE), cityBrightness: -0.08,
                orbPosition: UnitPoint(x: 0.80, y: 0.57))
        case .morning:
            return PeriodTheme(sky: [Color(hex: 0x244D64), Color(hex: 0x7EB7C4), Color(hex: 0xE9DBC0)],
                accent: Color(hex: 0xE8D5A0), cityTint: Color(hex: 0xF3F5EB), cityBrightness: 0.03,
                orbPosition: UnitPoint(x: 0.79, y: 0.41))
        case .noon:
            return PeriodTheme(sky: [Color(hex: 0x23526D), Color(hex: 0x6DB2D3), Color(hex: 0xCEDEE0)],
                accent: Color(hex: 0xBFE5EF), cityTint: .white, cityBrightness: 0.08,
                orbPosition: UnitPoint(x: 0.81, y: 0.34))
        case .afternoon:
            return PeriodTheme(sky: [Color(hex: 0x465B68), Color(hex: 0xADBBB4), Color(hex: 0xEBD4A7)],
                accent: Color(hex: 0xE8CD9A), cityTint: Color(hex: 0xFFE4BC), cityBrightness: 0.02,
                orbPosition: UnitPoint(x: 0.80, y: 0.46))
        case .dusk:
            return PeriodTheme(sky: [Color(hex: 0x3B3653), Color(hex: 0xBA7B83), Color(hex: 0xE8B27F)],
                accent: Color(hex: 0xF5C49A), cityTint: Color(hex: 0xE6B8A2), cityBrightness: -0.12,
                orbPosition: UnitPoint(x: 0.80, y: 0.60))
        case .night:
            return PeriodTheme(sky: [Color(hex: 0x101C38), Color(hex: 0x283D5D), Color(hex: 0x60728B)],
                accent: Color(hex: 0xBCD0F2), cityTint: Color(hex: 0x869ABA), cityBrightness: -0.17,
                orbPosition: UnitPoint(x: 0.80, y: 0.37))
        }
    }
}
