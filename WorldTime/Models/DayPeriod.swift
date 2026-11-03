import Foundation

/// 第一版以當地「鐘面時間」分成六段，並非天文日出日落。
enum DayPeriod: String, CaseIterable, Identifiable {
    case dawn, morning, noon, afternoon, dusk, night

    var id: String { rawValue }

    static func at(_ date: Date, in timeZone: TimeZone) -> DayPeriod {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return at(hour: calendar.component(.hour, from: date))
    }

    static func at(hour: Int) -> DayPeriod {
        switch hour {
        case 5..<7: return .dawn
        case 7..<11: return .morning
        case 11..<14: return .noon
        case 14..<17: return .afternoon
        case 17..<19: return .dusk
        default: return .night
        }
    }

    var title: String {
        switch self {
        case .dawn: return "清晨"
        case .morning: return "早上"
        case .noon: return "中午"
        case .afternoon: return "下午"
        case .dusk: return "傍晚"
        case .night: return "晚上"
        }
    }

    var symbol: String {
        switch self {
        case .dawn: return "sunrise.fill"
        case .morning: return "sun.max.fill"
        case .noon: return "sun.max.fill"
        case .afternoon: return "sun.haze.fill"
        case .dusk: return "sunset.fill"
        case .night: return "moon.stars.fill"
        }
    }

    var caption: String {
        switch self {
        case .dawn: return "第一道光，喚醒城市。"
        case .morning: return "陽光正好，日常徐徐展開。"
        case .noon: return "日光盛滿，世界清晰明亮。"
        case .afternoon: return "讓時光，在光影裡慢一點。"
        case .dusk: return "日色漸柔，城市染上金光。"
        case .night: return "燈火亮起，收藏一夜靜謐。"
        }
    }

    var hours: String {
        switch self {
        case .dawn: return "05:00–06:59"
        case .morning: return "07:00–10:59"
        case .noon: return "11:00–13:59"
        case .afternoon: return "14:00–16:59"
        case .dusk: return "17:00–18:59"
        case .night: return "19:00–04:59"
        }
    }
}
