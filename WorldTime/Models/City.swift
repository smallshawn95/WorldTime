import Foundation

/// 用時區地區來分類，方便在較長的城市清單中瀏覽。
enum CityRegion: String, CaseIterable, Identifiable {
    case asia = "亞洲"
    case europe = "歐洲"
    case americas = "美洲"
    case oceania = "大洋洲與太平洋"
    case africa = "非洲"
    case other = "其他"

    var id: String { rawValue }
}

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

    var region: CityRegion {
        let area = String(timeZoneIdentifier.split(separator: "/").first ?? "")
        switch area {
        case "Asia": return .asia
        case "Europe", "Atlantic": return .europe
        case "America": return .americas
        case "Australia", "Pacific": return .oceania
        case "Africa": return .africa
        case "Indian": return country == "馬爾地夫" ? .asia : .africa
        default: return .other
        }
    }

    func matches(_ query: String) -> Bool {
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "台", with: "臺")
            .folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: Locale(identifier: "zh_TW"))
        return text.isEmpty || [name, englishName, country, timeZoneIdentifier]
            .contains {
                $0.replacingOccurrences(of: "台", with: "臺")
                    .folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: Locale(identifier: "zh_TW"))
                    .contains(text)
            }
    }
}

enum CityCatalog {
    // 分成較短的清單，方便維護，也避免單一大型陣列增加編譯器負擔。
    private static let originalCities: [City] = [
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

    // 亞洲及中東
    private static let moreAsianCities: [City] = [
        City(id: "taichung", name: "臺中", englishName: "Taichung", country: "臺灣", timeZoneIdentifier: "Asia/Taipei", artwork: nil),
        City(id: "tainan", name: "臺南", englishName: "Tainan", country: "臺灣", timeZoneIdentifier: "Asia/Taipei", artwork: nil),
        City(id: "kaohsiung", name: "高雄", englishName: "Kaohsiung", country: "臺灣", timeZoneIdentifier: "Asia/Taipei", artwork: nil),
        City(id: "hsinchu", name: "新竹", englishName: "Hsinchu", country: "臺灣", timeZoneIdentifier: "Asia/Taipei", artwork: nil),
        City(id: "sapporo", name: "札幌", englishName: "Sapporo", country: "日本", timeZoneIdentifier: "Asia/Tokyo", artwork: nil),
        City(id: "osaka", name: "大阪", englishName: "Osaka", country: "日本", timeZoneIdentifier: "Asia/Tokyo", artwork: nil),
        City(id: "kyoto", name: "京都", englishName: "Kyoto", country: "日本", timeZoneIdentifier: "Asia/Tokyo", artwork: nil),
        City(id: "fukuoka", name: "福岡", englishName: "Fukuoka", country: "日本", timeZoneIdentifier: "Asia/Tokyo", artwork: nil),
        City(id: "naha", name: "那霸", englishName: "Naha", country: "日本", timeZoneIdentifier: "Asia/Tokyo", artwork: nil),
        City(id: "busan", name: "釜山", englishName: "Busan", country: "韓國", timeZoneIdentifier: "Asia/Seoul", artwork: nil),
        City(id: "incheon", name: "仁川", englishName: "Incheon", country: "韓國", timeZoneIdentifier: "Asia/Seoul", artwork: nil),
        City(id: "beijing", name: "北京", englishName: "Beijing", country: "中國", timeZoneIdentifier: "Asia/Shanghai", artwork: nil),
        City(id: "guangzhou", name: "廣州", englishName: "Guangzhou", country: "中國", timeZoneIdentifier: "Asia/Shanghai", artwork: nil),
        City(id: "shenzhen", name: "深圳", englishName: "Shenzhen", country: "中國", timeZoneIdentifier: "Asia/Shanghai", artwork: nil),
        City(id: "chengdu", name: "成都", englishName: "Chengdu", country: "中國", timeZoneIdentifier: "Asia/Shanghai", artwork: nil),
        City(id: "chongqing", name: "重慶", englishName: "Chongqing", country: "中國", timeZoneIdentifier: "Asia/Shanghai", artwork: nil),
        City(id: "macau", name: "澳門", englishName: "Macau", country: "澳門", timeZoneIdentifier: "Asia/Macau", artwork: nil),
        City(id: "manila", name: "馬尼拉", englishName: "Manila", country: "菲律賓", timeZoneIdentifier: "Asia/Manila", artwork: nil),
        City(id: "hanoi", name: "河內", englishName: "Hanoi", country: "越南", timeZoneIdentifier: "Asia/Ho_Chi_Minh", artwork: nil),
        City(id: "ho-chi-minh-city", name: "胡志明市", englishName: "Ho Chi Minh City", country: "越南", timeZoneIdentifier: "Asia/Ho_Chi_Minh", artwork: nil),
        City(id: "kuala-lumpur", name: "吉隆坡", englishName: "Kuala Lumpur", country: "馬來西亞", timeZoneIdentifier: "Asia/Kuala_Lumpur", artwork: nil),
        City(id: "jakarta", name: "雅加達", englishName: "Jakarta", country: "印尼", timeZoneIdentifier: "Asia/Jakarta", artwork: nil),
        City(id: "denpasar", name: "登巴薩", englishName: "Denpasar (Bali)", country: "印尼", timeZoneIdentifier: "Asia/Makassar", artwork: nil),
        City(id: "phnom-penh", name: "金邊", englishName: "Phnom Penh", country: "柬埔寨", timeZoneIdentifier: "Asia/Phnom_Penh", artwork: nil),
        City(id: "vientiane", name: "永珍", englishName: "Vientiane", country: "寮國", timeZoneIdentifier: "Asia/Vientiane", artwork: nil),
        City(id: "yangon", name: "仰光", englishName: "Yangon", country: "緬甸", timeZoneIdentifier: "Asia/Yangon", artwork: nil),
        City(id: "mumbai", name: "孟買", englishName: "Mumbai", country: "印度", timeZoneIdentifier: "Asia/Kolkata", artwork: nil),
        City(id: "kolkata", name: "加爾各答", englishName: "Kolkata", country: "印度", timeZoneIdentifier: "Asia/Kolkata", artwork: nil),
        City(id: "dhaka", name: "達卡", englishName: "Dhaka", country: "孟加拉", timeZoneIdentifier: "Asia/Dhaka", artwork: nil),
        City(id: "colombo", name: "可倫坡", englishName: "Colombo", country: "斯里蘭卡", timeZoneIdentifier: "Asia/Colombo", artwork: nil),
        City(id: "karachi", name: "喀拉蚩", englishName: "Karachi", country: "巴基斯坦", timeZoneIdentifier: "Asia/Karachi", artwork: nil),
        City(id: "male", name: "馬累", englishName: "Malé", country: "馬爾地夫", timeZoneIdentifier: "Indian/Maldives", artwork: nil),
        City(id: "thimphu", name: "廷布", englishName: "Thimphu", country: "不丹", timeZoneIdentifier: "Asia/Thimphu", artwork: nil),
        City(id: "ulaanbaatar", name: "烏蘭巴托", englishName: "Ulaanbaatar", country: "蒙古", timeZoneIdentifier: "Asia/Ulaanbaatar", artwork: nil),
        City(id: "almaty", name: "阿拉木圖", englishName: "Almaty", country: "哈薩克", timeZoneIdentifier: "Asia/Almaty", artwork: nil),
        City(id: "tashkent", name: "塔什干", englishName: "Tashkent", country: "烏茲別克", timeZoneIdentifier: "Asia/Tashkent", artwork: nil),
        City(id: "samarkand", name: "撒馬爾罕", englishName: "Samarkand", country: "烏茲別克", timeZoneIdentifier: "Asia/Samarkand", artwork: nil),
        City(id: "tbilisi", name: "提比里斯", englishName: "Tbilisi", country: "喬治亞", timeZoneIdentifier: "Asia/Tbilisi", artwork: nil),
        City(id: "yerevan", name: "葉里溫", englishName: "Yerevan", country: "亞美尼亞", timeZoneIdentifier: "Asia/Yerevan", artwork: nil),
        City(id: "jerusalem", name: "耶路撒冷", englishName: "Jerusalem", country: "以色列", timeZoneIdentifier: "Asia/Jerusalem", artwork: nil),
        City(id: "riyadh", name: "利雅德", englishName: "Riyadh", country: "沙烏地阿拉伯", timeZoneIdentifier: "Asia/Riyadh", artwork: nil),
        City(id: "doha", name: "多哈", englishName: "Doha", country: "卡達", timeZoneIdentifier: "Asia/Qatar", artwork: nil),
        City(id: "abu-dhabi", name: "阿布達比", englishName: "Abu Dhabi", country: "阿拉伯聯合大公國", timeZoneIdentifier: "Asia/Dubai", artwork: nil),
        City(id: "muscat", name: "馬斯喀特", englishName: "Muscat", country: "阿曼", timeZoneIdentifier: "Asia/Muscat", artwork: nil),
        City(id: "tehran", name: "德黑蘭", englishName: "Tehran", country: "伊朗", timeZoneIdentifier: "Asia/Tehran", artwork: nil),
        City(id: "baghdad", name: "巴格達", englishName: "Baghdad", country: "伊拉克", timeZoneIdentifier: "Asia/Baghdad", artwork: nil),
        City(id: "amman", name: "安曼", englishName: "Amman", country: "約旦", timeZoneIdentifier: "Asia/Amman", artwork: nil)
    ]

    // 歐洲
    private static let moreEuropeanCities: [City] = [
        City(id: "dublin", name: "都柏林", englishName: "Dublin", country: "愛爾蘭", timeZoneIdentifier: "Europe/Dublin", artwork: nil),
        City(id: "edinburgh", name: "愛丁堡", englishName: "Edinburgh", country: "英國", timeZoneIdentifier: "Europe/London", artwork: nil),
        City(id: "manchester", name: "曼徹斯特", englishName: "Manchester", country: "英國", timeZoneIdentifier: "Europe/London", artwork: nil),
        City(id: "madrid", name: "馬德里", englishName: "Madrid", country: "西班牙", timeZoneIdentifier: "Europe/Madrid", artwork: nil),
        City(id: "barcelona", name: "巴塞隆納", englishName: "Barcelona", country: "西班牙", timeZoneIdentifier: "Europe/Madrid", artwork: nil),
        City(id: "lisbon", name: "里斯本", englishName: "Lisbon", country: "葡萄牙", timeZoneIdentifier: "Europe/Lisbon", artwork: nil),
        City(id: "amsterdam", name: "阿姆斯特丹", englishName: "Amsterdam", country: "荷蘭", timeZoneIdentifier: "Europe/Amsterdam", artwork: nil),
        City(id: "brussels", name: "布魯塞爾", englishName: "Brussels", country: "比利時", timeZoneIdentifier: "Europe/Brussels", artwork: nil),
        City(id: "zurich", name: "蘇黎世", englishName: "Zurich", country: "瑞士", timeZoneIdentifier: "Europe/Zurich", artwork: nil),
        City(id: "vienna", name: "維也納", englishName: "Vienna", country: "奧地利", timeZoneIdentifier: "Europe/Vienna", artwork: nil),
        City(id: "prague", name: "布拉格", englishName: "Prague", country: "捷克", timeZoneIdentifier: "Europe/Prague", artwork: nil),
        City(id: "warsaw", name: "華沙", englishName: "Warsaw", country: "波蘭", timeZoneIdentifier: "Europe/Warsaw", artwork: nil),
        City(id: "budapest", name: "布達佩斯", englishName: "Budapest", country: "匈牙利", timeZoneIdentifier: "Europe/Budapest", artwork: nil),
        City(id: "athens", name: "雅典", englishName: "Athens", country: "希臘", timeZoneIdentifier: "Europe/Athens", artwork: nil),
        City(id: "helsinki", name: "赫爾辛基", englishName: "Helsinki", country: "芬蘭", timeZoneIdentifier: "Europe/Helsinki", artwork: nil),
        City(id: "stockholm", name: "斯德哥爾摩", englishName: "Stockholm", country: "瑞典", timeZoneIdentifier: "Europe/Stockholm", artwork: nil),
        City(id: "oslo", name: "奧斯陸", englishName: "Oslo", country: "挪威", timeZoneIdentifier: "Europe/Oslo", artwork: nil),
        City(id: "copenhagen", name: "哥本哈根", englishName: "Copenhagen", country: "丹麥", timeZoneIdentifier: "Europe/Copenhagen", artwork: nil),
        City(id: "reykjavik", name: "雷克雅維克", englishName: "Reykjavik", country: "冰島", timeZoneIdentifier: "Atlantic/Reykjavik", artwork: nil),
        City(id: "kyiv", name: "基輔", englishName: "Kyiv", country: "烏克蘭", timeZoneIdentifier: "Europe/Kyiv", artwork: nil),
        City(id: "bucharest", name: "布加勒斯特", englishName: "Bucharest", country: "羅馬尼亞", timeZoneIdentifier: "Europe/Bucharest", artwork: nil),
        City(id: "sofia", name: "索菲亞", englishName: "Sofia", country: "保加利亞", timeZoneIdentifier: "Europe/Sofia", artwork: nil),
        City(id: "belgrade", name: "貝爾格勒", englishName: "Belgrade", country: "塞爾維亞", timeZoneIdentifier: "Europe/Belgrade", artwork: nil),
        City(id: "zagreb", name: "札格瑞布", englishName: "Zagreb", country: "克羅埃西亞", timeZoneIdentifier: "Europe/Zagreb", artwork: nil),
        City(id: "moscow", name: "莫斯科", englishName: "Moscow", country: "俄羅斯", timeZoneIdentifier: "Europe/Moscow", artwork: nil),
        City(id: "st-petersburg", name: "聖彼得堡", englishName: "Saint Petersburg", country: "俄羅斯", timeZoneIdentifier: "Europe/Moscow", artwork: nil),
        City(id: "tallinn", name: "塔林", englishName: "Tallinn", country: "愛沙尼亞", timeZoneIdentifier: "Europe/Tallinn", artwork: nil),
        City(id: "riga", name: "里加", englishName: "Riga", country: "拉脫維亞", timeZoneIdentifier: "Europe/Riga", artwork: nil),
        City(id: "vilnius", name: "維爾紐斯", englishName: "Vilnius", country: "立陶宛", timeZoneIdentifier: "Europe/Vilnius", artwork: nil),
        City(id: "monaco", name: "摩納哥", englishName: "Monaco", country: "摩納哥", timeZoneIdentifier: "Europe/Monaco", artwork: nil),
        City(id: "luxembourg", name: "盧森堡", englishName: "Luxembourg", country: "盧森堡", timeZoneIdentifier: "Europe/Luxembourg", artwork: nil)
    ]

    // 北美洲、中美洲、南美洲與加勒比海
    private static let moreAmericanCities: [City] = [
        City(id: "san-francisco", name: "舊金山", englishName: "San Francisco", country: "美國", timeZoneIdentifier: "America/Los_Angeles", artwork: nil),
        City(id: "seattle", name: "西雅圖", englishName: "Seattle", country: "美國", timeZoneIdentifier: "America/Los_Angeles", artwork: nil),
        City(id: "las-vegas", name: "拉斯維加斯", englishName: "Las Vegas", country: "美國", timeZoneIdentifier: "America/Los_Angeles", artwork: nil),
        City(id: "denver", name: "丹佛", englishName: "Denver", country: "美國", timeZoneIdentifier: "America/Denver", artwork: nil),
        City(id: "phoenix", name: "鳳凰城", englishName: "Phoenix", country: "美國", timeZoneIdentifier: "America/Phoenix", artwork: nil),
        City(id: "houston", name: "休士頓", englishName: "Houston", country: "美國", timeZoneIdentifier: "America/Chicago", artwork: nil),
        City(id: "dallas", name: "達拉斯", englishName: "Dallas", country: "美國", timeZoneIdentifier: "America/Chicago", artwork: nil),
        City(id: "miami", name: "邁阿密", englishName: "Miami", country: "美國", timeZoneIdentifier: "America/New_York", artwork: nil),
        City(id: "washington-dc", name: "華盛頓特區", englishName: "Washington, D.C.", country: "美國", timeZoneIdentifier: "America/New_York", artwork: nil),
        City(id: "boston", name: "波士頓", englishName: "Boston", country: "美國", timeZoneIdentifier: "America/New_York", artwork: nil),
        City(id: "atlanta", name: "亞特蘭大", englishName: "Atlanta", country: "美國", timeZoneIdentifier: "America/New_York", artwork: nil),
        City(id: "detroit", name: "底特律", englishName: "Detroit", country: "美國", timeZoneIdentifier: "America/Detroit", artwork: nil),
        City(id: "new-orleans", name: "紐奧良", englishName: "New Orleans", country: "美國", timeZoneIdentifier: "America/Chicago", artwork: nil),
        City(id: "anchorage", name: "安克拉治", englishName: "Anchorage", country: "美國", timeZoneIdentifier: "America/Anchorage", artwork: nil),
        City(id: "montreal", name: "蒙特婁", englishName: "Montréal", country: "加拿大", timeZoneIdentifier: "America/Toronto", artwork: nil),
        City(id: "ottawa", name: "渥太華", englishName: "Ottawa", country: "加拿大", timeZoneIdentifier: "America/Toronto", artwork: nil),
        City(id: "calgary", name: "卡加利", englishName: "Calgary", country: "加拿大", timeZoneIdentifier: "America/Edmonton", artwork: nil),
        City(id: "edmonton", name: "艾德蒙頓", englishName: "Edmonton", country: "加拿大", timeZoneIdentifier: "America/Edmonton", artwork: nil),
        City(id: "winnipeg", name: "溫尼伯", englishName: "Winnipeg", country: "加拿大", timeZoneIdentifier: "America/Winnipeg", artwork: nil),
        City(id: "halifax", name: "哈利法克斯", englishName: "Halifax", country: "加拿大", timeZoneIdentifier: "America/Halifax", artwork: nil),
        City(id: "st-johns", name: "聖約翰斯", englishName: "St. John's", country: "加拿大", timeZoneIdentifier: "America/St_Johns", artwork: nil),
        City(id: "mexico-city", name: "墨西哥城", englishName: "Mexico City", country: "墨西哥", timeZoneIdentifier: "America/Mexico_City", artwork: nil),
        City(id: "cancun", name: "坎昆", englishName: "Cancún", country: "墨西哥", timeZoneIdentifier: "America/Cancun", artwork: nil),
        City(id: "tijuana", name: "提華納", englishName: "Tijuana", country: "墨西哥", timeZoneIdentifier: "America/Tijuana", artwork: nil),
        City(id: "guatemala-city", name: "瓜地馬拉市", englishName: "Guatemala City", country: "瓜地馬拉", timeZoneIdentifier: "America/Guatemala", artwork: nil),
        City(id: "san-jose-cr", name: "聖荷西", englishName: "San José", country: "哥斯大黎加", timeZoneIdentifier: "America/Costa_Rica", artwork: nil),
        City(id: "panama-city", name: "巴拿馬市", englishName: "Panama City", country: "巴拿馬", timeZoneIdentifier: "America/Panama", artwork: nil),
        City(id: "havana", name: "哈瓦那", englishName: "Havana", country: "古巴", timeZoneIdentifier: "America/Havana", artwork: nil),
        City(id: "santo-domingo", name: "聖多明哥", englishName: "Santo Domingo", country: "多明尼加", timeZoneIdentifier: "America/Santo_Domingo", artwork: nil),
        City(id: "san-juan", name: "聖胡安", englishName: "San Juan", country: "波多黎各", timeZoneIdentifier: "America/Puerto_Rico", artwork: nil),
        City(id: "bogota", name: "波哥大", englishName: "Bogotá", country: "哥倫比亞", timeZoneIdentifier: "America/Bogota", artwork: nil),
        City(id: "lima", name: "利馬", englishName: "Lima", country: "秘魯", timeZoneIdentifier: "America/Lima", artwork: nil),
        City(id: "quito", name: "基多", englishName: "Quito", country: "厄瓜多", timeZoneIdentifier: "America/Guayaquil", artwork: nil),
        City(id: "caracas", name: "卡拉卡斯", englishName: "Caracas", country: "委內瑞拉", timeZoneIdentifier: "America/Caracas", artwork: nil),
        City(id: "santiago", name: "聖地牙哥", englishName: "Santiago", country: "智利", timeZoneIdentifier: "America/Santiago", artwork: nil),
        City(id: "buenos-aires", name: "布宜諾斯艾利斯", englishName: "Buenos Aires", country: "阿根廷", timeZoneIdentifier: "America/Argentina/Buenos_Aires", artwork: nil),
        City(id: "montevideo", name: "蒙特維多", englishName: "Montevideo", country: "烏拉圭", timeZoneIdentifier: "America/Montevideo", artwork: nil),
        City(id: "rio-de-janeiro", name: "里約熱內盧", englishName: "Rio de Janeiro", country: "巴西", timeZoneIdentifier: "America/Sao_Paulo", artwork: nil),
        City(id: "brasilia", name: "巴西利亞", englishName: "Brasília", country: "巴西", timeZoneIdentifier: "America/Sao_Paulo", artwork: nil),
        City(id: "manaus", name: "瑪瑙斯", englishName: "Manaus", country: "巴西", timeZoneIdentifier: "America/Manaus", artwork: nil),
        City(id: "la-paz", name: "拉巴斯", englishName: "La Paz", country: "玻利維亞", timeZoneIdentifier: "America/La_Paz", artwork: nil),
        City(id: "asuncion", name: "亞松森", englishName: "Asunción", country: "巴拉圭", timeZoneIdentifier: "America/Asuncion", artwork: nil),
        City(id: "georgetown", name: "喬治城", englishName: "Georgetown", country: "蓋亞那", timeZoneIdentifier: "America/Guyana", artwork: nil)
    ]

    // 大洋洲與太平洋
    private static let moreOceanianCities: [City] = [
        City(id: "melbourne", name: "墨爾本", englishName: "Melbourne", country: "澳洲", timeZoneIdentifier: "Australia/Melbourne", artwork: nil),
        City(id: "brisbane", name: "布里斯本", englishName: "Brisbane", country: "澳洲", timeZoneIdentifier: "Australia/Brisbane", artwork: nil),
        City(id: "perth", name: "伯斯", englishName: "Perth", country: "澳洲", timeZoneIdentifier: "Australia/Perth", artwork: nil),
        City(id: "darwin", name: "達爾文", englishName: "Darwin", country: "澳洲", timeZoneIdentifier: "Australia/Darwin", artwork: nil),
        City(id: "hobart", name: "荷巴特", englishName: "Hobart", country: "澳洲", timeZoneIdentifier: "Australia/Hobart", artwork: nil),
        City(id: "canberra", name: "坎培拉", englishName: "Canberra", country: "澳洲", timeZoneIdentifier: "Australia/Sydney", artwork: nil),
        City(id: "wellington", name: "威靈頓", englishName: "Wellington", country: "紐西蘭", timeZoneIdentifier: "Pacific/Auckland", artwork: nil),
        City(id: "christchurch", name: "基督城", englishName: "Christchurch", country: "紐西蘭", timeZoneIdentifier: "Pacific/Auckland", artwork: nil),
        City(id: "suva", name: "蘇瓦", englishName: "Suva", country: "斐濟", timeZoneIdentifier: "Pacific/Fiji", artwork: nil),
        City(id: "port-moresby", name: "莫士比港", englishName: "Port Moresby", country: "巴布亞紐幾內亞", timeZoneIdentifier: "Pacific/Port_Moresby", artwork: nil),
        City(id: "hagatna", name: "阿加尼亞", englishName: "Hagåtña", country: "關島", timeZoneIdentifier: "Pacific/Guam", artwork: nil),
        City(id: "noumea", name: "努美阿", englishName: "Nouméa", country: "新喀里多尼亞", timeZoneIdentifier: "Pacific/Noumea", artwork: nil),
        City(id: "papeete", name: "帕皮提", englishName: "Papeete", country: "法屬玻里尼西亞", timeZoneIdentifier: "Pacific/Tahiti", artwork: nil),
        City(id: "avarua", name: "阿瓦魯阿", englishName: "Avarua", country: "庫克群島", timeZoneIdentifier: "Pacific/Rarotonga", artwork: nil),
        City(id: "apia", name: "阿皮亞", englishName: "Apia", country: "薩摩亞", timeZoneIdentifier: "Pacific/Apia", artwork: nil)
    ]

    // 非洲與印度洋
    private static let moreAfricanCities: [City] = [
        City(id: "casablanca", name: "卡薩布蘭加", englishName: "Casablanca", country: "摩洛哥", timeZoneIdentifier: "Africa/Casablanca", artwork: nil),
        City(id: "marrakesh", name: "馬拉喀什", englishName: "Marrakesh", country: "摩洛哥", timeZoneIdentifier: "Africa/Casablanca", artwork: nil),
        City(id: "algiers", name: "阿爾及爾", englishName: "Algiers", country: "阿爾及利亞", timeZoneIdentifier: "Africa/Algiers", artwork: nil),
        City(id: "tunis", name: "突尼斯市", englishName: "Tunis", country: "突尼西亞", timeZoneIdentifier: "Africa/Tunis", artwork: nil),
        City(id: "tripoli", name: "的黎波里", englishName: "Tripoli", country: "利比亞", timeZoneIdentifier: "Africa/Tripoli", artwork: nil),
        City(id: "addis-ababa", name: "阿迪斯阿貝巴", englishName: "Addis Ababa", country: "衣索比亞", timeZoneIdentifier: "Africa/Addis_Ababa", artwork: nil),
        City(id: "nairobi", name: "奈洛比", englishName: "Nairobi", country: "肯亞", timeZoneIdentifier: "Africa/Nairobi", artwork: nil),
        City(id: "dar-es-salaam", name: "三蘭港", englishName: "Dar es Salaam", country: "坦尚尼亞", timeZoneIdentifier: "Africa/Dar_es_Salaam", artwork: nil),
        City(id: "kampala", name: "坎帕拉", englishName: "Kampala", country: "烏干達", timeZoneIdentifier: "Africa/Kampala", artwork: nil),
        City(id: "kigali", name: "吉佳利", englishName: "Kigali", country: "盧安達", timeZoneIdentifier: "Africa/Kigali", artwork: nil),
        City(id: "lagos", name: "拉哥斯", englishName: "Lagos", country: "奈及利亞", timeZoneIdentifier: "Africa/Lagos", artwork: nil),
        City(id: "accra", name: "阿克拉", englishName: "Accra", country: "迦納", timeZoneIdentifier: "Africa/Accra", artwork: nil),
        City(id: "abidjan", name: "阿必尚", englishName: "Abidjan", country: "象牙海岸", timeZoneIdentifier: "Africa/Abidjan", artwork: nil),
        City(id: "dakar", name: "達卡", englishName: "Dakar", country: "塞內加爾", timeZoneIdentifier: "Africa/Dakar", artwork: nil),
        City(id: "johannesburg", name: "約翰尼斯堡", englishName: "Johannesburg", country: "南非", timeZoneIdentifier: "Africa/Johannesburg", artwork: nil),
        City(id: "pretoria", name: "普利托利亞", englishName: "Pretoria", country: "南非", timeZoneIdentifier: "Africa/Johannesburg", artwork: nil),
        City(id: "windhoek", name: "溫荷克", englishName: "Windhoek", country: "納米比亞", timeZoneIdentifier: "Africa/Windhoek", artwork: nil),
        City(id: "gaborone", name: "嘉柏隆里", englishName: "Gaborone", country: "波札那", timeZoneIdentifier: "Africa/Gaborone", artwork: nil),
        City(id: "harare", name: "哈拉雷", englishName: "Harare", country: "辛巴威", timeZoneIdentifier: "Africa/Harare", artwork: nil),
        City(id: "lusaka", name: "路沙卡", englishName: "Lusaka", country: "尚比亞", timeZoneIdentifier: "Africa/Lusaka", artwork: nil),
        City(id: "maputo", name: "馬布多", englishName: "Maputo", country: "莫三比克", timeZoneIdentifier: "Africa/Maputo", artwork: nil),
        City(id: "antananarivo", name: "安塔那那利佛", englishName: "Antananarivo", country: "馬達加斯加", timeZoneIdentifier: "Indian/Antananarivo", artwork: nil),
        City(id: "port-louis", name: "路易港", englishName: "Port Louis", country: "模里西斯", timeZoneIdentifier: "Indian/Mauritius", artwork: nil)
    ]

    static let all: [City] = [originalCities, moreAsianCities, moreEuropeanCities,
                              moreAmericanCities, moreOceanianCities, moreAfricanCities]
        .flatMap { $0 }
    static let defaults = Array(all.prefix(3))

    static func city(id: String) -> City? {
        all.first { $0.id == id }
    }
}
