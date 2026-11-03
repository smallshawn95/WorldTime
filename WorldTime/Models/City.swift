import Foundation

/// 儲存 IANA 時區名稱，讓系統依日期決定夏令時間，避免寫死 UTC 時差。
struct City: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let englishName: String
    let country: String
    let timeZoneIdentifier: String
    let artwork: String?

    var timeZone: TimeZone {
        // 內建資料皆有測試；保留 UTC 作為舊系統不認得識別碼時的安全退路。
        TimeZone(identifier: timeZoneIdentifier) ?? TimeZone(secondsFromGMT: 0)!
    }

    func matches(_ query: String) -> Bool {
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "台", with: "臺")
        return text.isEmpty || [name, englishName, country, timeZoneIdentifier]
            .contains { $0.replacingOccurrences(of: "台", with: "臺").localizedCaseInsensitiveContains(text) }
    }
}

enum CityCatalog {
    static let all: [City] = [
        City(id: "london", name: "倫敦", englishName: "London", country: "英國", timeZoneIdentifier: "Europe/London", artwork: "London"),
        City(id: "taipei", name: "臺北", englishName: "Taipei", country: "臺灣", timeZoneIdentifier: "Asia/Taipei", artwork: "Taipei"),
        City(id: "new-york", name: "紐約", englishName: "New York", country: "美國", timeZoneIdentifier: "America/New_York", artwork: "NewYork"),
        City(id: "tokyo", name: "東京", englishName: "Tokyo", country: "日本", timeZoneIdentifier: "Asia/Tokyo", artwork: nil),
        City(id: "seoul", name: "首爾", englishName: "Seoul", country: "韓國", timeZoneIdentifier: "Asia/Seoul", artwork: nil),
        City(id: "hong-kong", name: "香港", englishName: "Hong Kong", country: "香港", timeZoneIdentifier: "Asia/Hong_Kong", artwork: nil),
        City(id: "singapore", name: "新加坡", englishName: "Singapore", country: "新加坡", timeZoneIdentifier: "Asia/Singapore", artwork: nil),
        City(id: "bangkok", name: "曼谷", englishName: "Bangkok", country: "泰國", timeZoneIdentifier: "Asia/Bangkok", artwork: nil),
        City(id: "shanghai", name: "上海", englishName: "Shanghai", country: "中國", timeZoneIdentifier: "Asia/Shanghai", artwork: nil),
        City(id: "dubai", name: "杜拜", englishName: "Dubai", country: "阿拉伯聯合大公國", timeZoneIdentifier: "Asia/Dubai", artwork: nil),
        City(id: "delhi", name: "新德里", englishName: "New Delhi", country: "印度", timeZoneIdentifier: "Asia/Kolkata", artwork: nil),
        City(id: "kathmandu", name: "加德滿都", englishName: "Kathmandu", country: "尼泊爾", timeZoneIdentifier: "Asia/Kathmandu", artwork: nil),
        City(id: "paris", name: "巴黎", englishName: "Paris", country: "法國", timeZoneIdentifier: "Europe/Paris", artwork: nil),
        City(id: "berlin", name: "柏林", englishName: "Berlin", country: "德國", timeZoneIdentifier: "Europe/Berlin", artwork: nil),
        City(id: "rome", name: "羅馬", englishName: "Rome", country: "義大利", timeZoneIdentifier: "Europe/Rome", artwork: nil),
        City(id: "istanbul", name: "伊斯坦堡", englishName: "Istanbul", country: "土耳其", timeZoneIdentifier: "Europe/Istanbul", artwork: nil),
        City(id: "los-angeles", name: "洛杉磯", englishName: "Los Angeles", country: "美國", timeZoneIdentifier: "America/Los_Angeles", artwork: nil),
        City(id: "chicago", name: "芝加哥", englishName: "Chicago", country: "美國", timeZoneIdentifier: "America/Chicago", artwork: nil),
        City(id: "vancouver", name: "溫哥華", englishName: "Vancouver", country: "加拿大", timeZoneIdentifier: "America/Vancouver", artwork: nil),
        City(id: "toronto", name: "多倫多", englishName: "Toronto", country: "加拿大", timeZoneIdentifier: "America/Toronto", artwork: nil),
        City(id: "sao-paulo", name: "聖保羅", englishName: "São Paulo", country: "巴西", timeZoneIdentifier: "America/Sao_Paulo", artwork: nil),
        City(id: "sydney", name: "雪梨", englishName: "Sydney", country: "澳洲", timeZoneIdentifier: "Australia/Sydney", artwork: nil),
        City(id: "adelaide", name: "阿德雷德", englishName: "Adelaide", country: "澳洲", timeZoneIdentifier: "Australia/Adelaide", artwork: nil),
        City(id: "auckland", name: "奧克蘭", englishName: "Auckland", country: "紐西蘭", timeZoneIdentifier: "Pacific/Auckland", artwork: nil),
        City(id: "honolulu", name: "檀香山", englishName: "Honolulu", country: "美國", timeZoneIdentifier: "Pacific/Honolulu", artwork: nil),
        City(id: "cairo", name: "開羅", englishName: "Cairo", country: "埃及", timeZoneIdentifier: "Africa/Cairo", artwork: nil),
        City(id: "cape-town", name: "開普敦", englishName: "Cape Town", country: "南非", timeZoneIdentifier: "Africa/Johannesburg", artwork: nil)
    ]

    static let defaults = Array(all.prefix(3))

    static func city(id: String) -> City? {
        all.first { $0.id == id }
    }
}
