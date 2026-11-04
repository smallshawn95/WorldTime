import XCTest
#if SWIFT_PACKAGE
@testable import CityClockCore
#else
@testable import WorldTime
#endif

final class ClockTests: XCTestCase {
    private let london = CityCatalog.city(id: "london")!
    private let taipei = CityCatalog.city(id: "taipei")!
    private let newYork = CityCatalog.city(id: "new-york")!

    private func instant(_ string: String) -> Date {
        ISO8601DateFormatter().date(from: string)!
    }

    func testCatalogHasValidUniqueIdentifiers() {
        XCTAssertGreaterThanOrEqual(CityCatalog.all.count, 150)
        XCTAssertEqual(Set(CityCatalog.all.map(\.id)).count, CityCatalog.all.count)
        for city in CityCatalog.all {
            XCTAssertNotNil(TimeZone(identifier: city.timeZoneIdentifier), city.name)
        }
        XCTAssertEqual(CityCatalog.defaults.map(\.id), ["london", "taipei", "new-york"])
    }

    func testRepresentativeCitiesGroupSameCountryAndZone() {
        XCTAssertEqual(CityCatalog.representativeID(forCityID: "taichung"), "taipei")
        XCTAssertEqual(CityCatalog.representativeID(forCityID: "detroit"), "new-york")
        XCTAssertEqual(CityCatalog.representativeID(forCityID: "melbourne"), "sydney")
        XCTAssertEqual(CityCatalog.representativeID(forCityID: "samarkand"), "tashkent")
        XCTAssertEqual(CityCatalog.representativeID(forCityID: "phoenix"), "phoenix")
        XCTAssertEqual(CityCatalog.representativeID(forCityID: "denver"), "denver")
        XCTAssertEqual(CityCatalog.representativeID(forCityID: "toronto"), "toronto")
        XCTAssertEqual(Set(CityCatalog.representativeCities.map(\.id)).count,
                       CityCatalog.representativeCities.count)
        XCTAssertTrue(CityCatalog.all.allSatisfy { CityCatalog.representativeID(forCityID: $0.id) != nil })
    }

    func testSearchingLegacyCityFindsItsRepresentative() {
        XCTAssertEqual(CityCatalog.searchRepresentatives("台中").map(\.id), ["taipei"])
        XCTAssertEqual(CityCatalog.searchRepresentatives("Detroit").map(\.id), ["new-york"])
        XCTAssertEqual(CityCatalog.searchRepresentatives("Melbourne").map(\.id), ["sydney"])
        XCTAssertTrue(CityCatalog.searchRepresentatives("Phoenix").isEmpty)
        XCTAssertTrue(CityCatalog.searchRepresentatives("Dublin").isEmpty)
        XCTAssertEqual(CityCatalog.searchRepresentatives("Moscow").map(\.id), ["moscow"])
        XCTAssertEqual(Set(CityCatalog.searchRepresentatives("美國").map(\.id)),
                       Set(["new-york", "los-angeles", "chicago", "honolulu"]))
    }

    func testOnlyFeaturedCitiesAppearInAddList() {
        let expected: Set<String> = [
            "london", "taipei", "new-york", "tokyo", "seoul", "hong-kong",
            "singapore", "bangkok", "shanghai", "dubai", "delhi", "paris",
            "berlin", "rome", "istanbul", "los-angeles", "chicago", "toronto",
            "sao-paulo", "sydney", "cairo", "cape-town", "vancouver", "honolulu",
            "auckland", "madrid", "amsterdam", "moscow", "mexico-city", "jakarta"
        ]
        XCTAssertEqual(Set(CityCatalog.searchRepresentatives("").map(\.id)), expected)
        XCTAssertNotNil(CityCatalog.city(id: "dublin"), "Existing favorites remain available")
    }

    func testOneInstantShowsDifferentLocalTimes() {
        let date = instant("2026-11-03T10:30:00Z")
        XCTAssertEqual(ClockFormatting.time(date, in: london), "10:30")
        XCTAssertEqual(ClockFormatting.time(date, in: taipei), "18:30")
        XCTAssertEqual(ClockFormatting.time(date, in: newYork), "05:30")
        XCTAssertEqual(DayPeriod.at(date, in: london.timeZone), .morning)
        XCTAssertEqual(DayPeriod.at(date, in: taipei.timeZone), .dusk)
        XCTAssertEqual(DayPeriod.at(date, in: newYork.timeZone), .dawn)
    }

    func testAll24HoursHaveExpectedPeriod() {
        let expected: [DayPeriod] = [
            .night, .night, .night, .night, .night, .dawn, .dawn,
            .morning, .morning, .morning, .morning, .noon, .noon, .noon,
            .afternoon, .afternoon, .afternoon, .dusk, .dusk,
            .night, .night, .night, .night, .night
        ]
        for hour in 0..<24 {
            XCTAssertEqual(DayPeriod.at(hour: hour), expected[hour], "hour \(hour)")
        }
    }

    func testPeriodChangesAtLocalBoundary() {
        XCTAssertEqual(DayPeriod.at(instant("2026-01-01T20:59:59Z"), in: taipei.timeZone), .night)
        XCTAssertEqual(DayPeriod.at(instant("2026-01-01T21:00:00Z"), in: taipei.timeZone), .dawn)
    }

    func testLondonSpringForwardSkipsOneOClockHour() {
        // 倫敦 2026-03-29：00:59 GMT 的下一分鐘是 02:00 BST。
        let before = instant("2026-03-29T00:59:00Z")
        let after = instant("2026-03-29T01:00:00Z")
        XCTAssertEqual(ClockFormatting.time(before, in: london), "00:59")
        XCTAssertEqual(ClockFormatting.time(after, in: london), "02:00")
        XCTAssertEqual(ClockFormatting.utcOffset(before, in: london), "UTC+00:00")
        XCTAssertEqual(ClockFormatting.utcOffset(after, in: london), "UTC+01:00")
        XCTAssertFalse(london.timeZone.isDaylightSavingTime(for: before))
        XCTAssertTrue(london.timeZone.isDaylightSavingTime(for: after))
    }

    func testLondonAutumnRepeatsOneOClockHour() {
        let before = instant("2026-10-25T00:59:00Z")
        let after = instant("2026-10-25T01:00:00Z")
        XCTAssertEqual(ClockFormatting.time(before, in: london), "01:59")
        XCTAssertEqual(ClockFormatting.time(after, in: london), "01:00")
        XCTAssertEqual(ClockFormatting.utcOffset(after, in: london), "UTC+00:00")
    }

    func testNewYorkSpringForward() {
        XCTAssertEqual(ClockFormatting.time(instant("2026-03-08T06:59:00Z"), in: newYork), "01:59")
        let after = instant("2026-03-08T07:00:00Z")
        XCTAssertEqual(ClockFormatting.time(after, in: newYork), "03:00")
        XCTAssertEqual(ClockFormatting.utcOffset(after, in: newYork), "UTC−04:00")
    }

    func testNewYorkAutumnRepeatsOneOClockHour() {
        let before = instant("2026-11-01T05:59:00Z")
        let after = instant("2026-11-01T06:00:00Z")
        XCTAssertEqual(ClockFormatting.time(before, in: newYork), "01:59")
        XCTAssertEqual(ClockFormatting.time(after, in: newYork), "01:00")
        XCTAssertEqual(ClockFormatting.utcOffset(before, in: newYork), "UTC−04:00")
        XCTAssertEqual(ClockFormatting.utcOffset(after, in: newYork), "UTC−05:00")
    }

    func testLondonAndNewYorkSwitchDSTOnDifferentWeeks() {
        XCTAssertEqual(ClockFormatting.difference(instant("2026-03-15T12:00:00Z"), city: newYork, relativeTo: london), "慢 4 小時")
        XCTAssertEqual(ClockFormatting.difference(instant("2026-04-15T12:00:00Z"), city: newYork, relativeTo: london), "慢 5 小時")
    }

    func testTaipeiHasNoSeasonalOffsetChange() {
        for stamp in ["2026-01-01T12:00:00Z", "2026-07-01T12:00:00Z"] {
            let date = instant(stamp)
            XCTAssertEqual(ClockFormatting.utcOffset(date, in: taipei), "UTC+08:00")
            XCTAssertFalse(taipei.timeZone.isDaylightSavingTime(for: date))
        }
    }

    func testHalfAndQuarterHourZones() {
        let date = instant("2026-01-01T00:00:00Z")
        let delhi = CityCatalog.city(id: "delhi")!
        let kathmandu = CityCatalog.city(id: "kathmandu")!
        XCTAssertEqual(ClockFormatting.time(date, in: delhi), "05:30")
        XCTAssertEqual(ClockFormatting.utcOffset(date, in: kathmandu), "UTC+05:45")
        XCTAssertEqual(ClockFormatting.difference(date, city: kathmandu, relativeTo: delhi), "快 15 分鐘")
        XCTAssertEqual(ClockFormatting.difference(date, city: kathmandu, relativeTo: london), "快 5 小時 45 分鐘")
    }

    func testCalendarDayAcrossYearBoundary() {
        let date = instant("2026-12-31T20:30:00Z")
        XCTAssertEqual(ClockFormatting.dayDifference(date, city: taipei, relativeTo: newYork), 1)
        XCTAssertEqual(ClockFormatting.relativeDay(date, city: newYork, relativeTo: taipei), "前一天")
        XCTAssertTrue(ClockFormatting.date(date, in: taipei).hasPrefix("1月1日"))
    }

    func testDateLineCanSpanTwoCalendarDays() {
        let date = instant("2026-01-01T11:30:00Z")
        let auckland = CityCatalog.city(id: "auckland")!
        let honolulu = CityCatalog.city(id: "honolulu")!
        XCTAssertEqual(ClockFormatting.dayDifference(date, city: auckland, relativeTo: honolulu), 1)
        // 同時刻的民用時區最多可跨兩個曆日；用 UTC+14 與 UTC−12 驗證。
        let east = City(id: "east", name: "東", englishName: "East", country: "", timeZoneIdentifier: "Pacific/Kiritimati", artwork: nil)
        let west = City(id: "west", name: "西", englishName: "West", country: "", timeZoneIdentifier: "Etc/GMT+12", artwork: nil)
        XCTAssertEqual(ClockFormatting.dayDifference(date, city: east, relativeTo: west), 2)
        XCTAssertEqual(ClockFormatting.relativeDay(date, city: east, relativeTo: west), "後 2 天")
    }

    func testSecondsAndSameZone() {
        let date = instant("2026-02-01T12:34:56Z")
        XCTAssertEqual(ClockFormatting.seconds(date, in: taipei), "56")
        XCTAssertEqual(ClockFormatting.difference(date, city: taipei, relativeTo: taipei), "相同時間")
        XCTAssertEqual(ClockFormatting.relativeDay(date, city: taipei, relativeTo: taipei), "同一天")
    }

    func testSearchSupportsChineseEnglishAndCountry() {
        XCTAssertTrue(taipei.matches("臺北"))
        XCTAssertTrue(taipei.matches("台北"))
        XCTAssertTrue(CityCatalog.city(id: "taichung")!.matches("台中"))
        XCTAssertTrue(taipei.matches(" TAIPEI "))
        XCTAssertTrue(newYork.matches("美國"))
        XCTAssertTrue(london.matches("Europe/London"))
        XCTAssertTrue(CityCatalog.city(id: "montreal")!.matches("Montreal"))
        XCTAssertTrue(CityCatalog.city(id: "sao-paulo")!.matches("sao paulo"))
        XCTAssertFalse(london.matches("巴黎"))
    }

    func testCatalogRegionsIncludeAllContinentsAndIndianOcean() {
        let cases: [(String, CityRegion)] = [
            ("taipei", .asia), ("male", .asia), ("reykjavik", .europe),
            ("mexico-city", .americas), ("melbourne", .oceania),
            ("nairobi", .africa), ("port-louis", .africa)
        ]
        for (id, region) in cases {
            XCTAssertEqual(CityCatalog.city(id: id)?.region, region, id)
        }
    }

    func testNewSouthernAndHalfHourTimeZonesFollowSeasonalRules() {
        let melbourne = CityCatalog.city(id: "melbourne")!
        let stJohns = CityCatalog.city(id: "st-johns")!
        let january = instant("2026-01-15T12:00:00Z")
        let july = instant("2026-07-15T12:00:00Z")
        XCTAssertEqual(ClockFormatting.utcOffset(january, in: melbourne), "UTC+11:00")
        XCTAssertEqual(ClockFormatting.utcOffset(july, in: melbourne), "UTC+10:00")
        XCTAssertEqual(ClockFormatting.utcOffset(january, in: stJohns), "UTC−03:30")
        XCTAssertEqual(ClockFormatting.utcOffset(july, in: stJohns), "UTC−02:30")
    }
}
