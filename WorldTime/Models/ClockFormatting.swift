import Foundation

enum ClockFormatting {
    // 固定 24 小時格式；時區一律跟隨城市，不使用裝置的預設時區。
    private static func string(_ date: Date, in city: City, format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = city.timeZone
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    static func time(_ date: Date, in city: City) -> String {
        string(date, in: city, format: "HH:mm")
    }

    static func seconds(_ date: Date, in city: City) -> String {
        string(date, in: city, format: "ss")
    }

    static func date(_ date: Date, in city: City) -> String {
        string(date, in: city, format: "M月d日 EEEE")
    }

    static func utcOffset(_ date: Date, in city: City) -> String {
        let minutes = city.timeZone.secondsFromGMT(for: date) / 60
        let sign = minutes >= 0 ? "+" : "−"
        return String(format: "UTC%@%02d:%02d", sign, abs(minutes) / 60, abs(minutes) % 60)
    }

    static func zoneDetail(_ date: Date, in city: City) -> String {
        let offset = utcOffset(date, in: city)
        return city.timeZone.isDaylightSavingTime(for: date) ? "\(offset) · 夏令時間" : offset
    }

    static func difference(_ date: Date, city: City, relativeTo reference: City) -> String {
        let minutes = (city.timeZone.secondsFromGMT(for: date)
            - reference.timeZone.secondsFromGMT(for: date)) / 60
        guard minutes != 0 else { return "相同時間" }
        let hours = abs(minutes) / 60
        let remainder = abs(minutes) % 60
        let duration = [hours > 0 ? "\(hours) 小時" : nil,
                        remainder > 0 ? "\(remainder) 分鐘" : nil]
            .compactMap { $0 }.joined(separator: " ")
        return (minutes > 0 ? "快 " : "慢 ") + duration
    }

    /// 比較當地曆日，不把「一天」寫成 86400 秒，避免夏令時間切換的陷阱。
    static func dayDifference(_ date: Date, city: City, relativeTo reference: City) -> Int {
        func localDay(_ city: City) -> Date {
            var local = Calendar(identifier: .gregorian)
            local.timeZone = city.timeZone
            let components = local.dateComponents([.year, .month, .day], from: date)
            var utc = Calendar(identifier: .gregorian)
            utc.timeZone = TimeZone(secondsFromGMT: 0)!
            return utc.date(from: components)!
        }
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(secondsFromGMT: 0)!
        return utc.dateComponents([.day], from: localDay(reference), to: localDay(city)).day ?? 0
    }

    static func relativeDay(_ date: Date, city: City, relativeTo reference: City) -> String {
        switch dayDifference(date, city: city, relativeTo: reference) {
        case -1: return "前一天"
        case 0: return "同一天"
        case 1: return "後一天"
        case let value where value < 0: return "前 \(abs(value)) 天"
        case let value: return "後 \(value) 天"
        }
    }
}
