import SwiftUI

struct CityTimeRow: View {
    let city: City
    let reference: City
    let date: Date

    private var period: DayPeriod { .at(date, in: city.timeZone) }

    var body: some View {
        HStack(spacing: 14) {
            CityScene(city: city, period: period)
                .frame(width: 54, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 6) {
                Text(city.name).font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white)
                Text("\(period.title) · \(ClockFormatting.difference(date, city: city, relativeTo: reference))")
                    .font(.caption)
                    .foregroundStyle(PeriodTheme.muted)
            }

            Spacer(minLength: 5)

            VStack(alignment: .trailing, spacing: 5) {
                Text(ClockFormatting.time(date, in: city))
                    .font(.system(size: 28, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                Text(ClockFormatting.relativeDay(date, city: city, relativeTo: reference))
                    .font(.caption2)
                    .foregroundStyle(PeriodTheme.muted)
            }
        }
        .padding(16)
        .background(PeriodTheme.surface, in: RoundedRectangle(cornerRadius: 21))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(city.name)，\(ClockFormatting.time(date, in: city))，\(period.title)，比\(reference.name)\(ClockFormatting.difference(date, city: city, relativeTo: reference))，\(ClockFormatting.relativeDay(date, city: city, relativeTo: reference))")
        .accessibilityHint("切換為首頁城市")
    }
}
