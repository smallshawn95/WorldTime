import SwiftUI

struct CityHeroCard: View {
    let city: City
    let date: Date
    @Environment(\.dynamicTypeSize) private var typeSize

    private var period: DayPeriod { .at(date, in: city.timeZone) }
    private var theme: PeriodTheme { .forPeriod(period) }

    var body: some View {
        ZStack {
            CityScene(city: city, period: period)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(city.englishName.uppercased())
                            .font(.system(size: 11, weight: .medium))
                            .tracking(3)
                            .foregroundStyle(.white.opacity(0.75))
                        Text(city.name)
                            .font(.system(size: 32, weight: .semibold, design: .serif))
                            .accessibilityIdentifier("heroCity")
                    }
                    Spacer(minLength: 8)
                    HStack(spacing: 5) {
                        Circle().fill(Color(hex: 0xBCE8C7)).frame(width: 5, height: 5)
                        Text("此刻").font(.caption2.weight(.medium))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(.white.opacity(0.12), in: Capsule())
                    .accessibilityLabel("即時當地時間")
                }

                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(ClockFormatting.time(date, in: city))
                        .font(.system(size: 76, weight: .ultraLight, design: .rounded))
                        .tracking(-3)
                        .monospacedDigit()
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                        .accessibilityIdentifier("heroTime")
                    Text(ClockFormatting.seconds(date, in: city))
                        .font(.system(size: 18, weight: .light, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white.opacity(0.65))
                        .accessibilityHidden(true)
                }
                .padding(.top, 20)

                Text(ClockFormatting.date(date, in: city))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.top, 3)

                Spacer(minLength: 100)

                HStack {
                    Label(period.title, systemImage: period.symbol)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(theme.accent)
                    Spacer()
                    Text(ClockFormatting.utcOffset(date, in: city))
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.75))
                }
                Text(period.caption)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.top, 8)
            }
            .padding(26)
            .foregroundStyle(.white)
        }
        .frame(height: typeSize.isAccessibilitySize ? 640 : 510)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
    }
}
