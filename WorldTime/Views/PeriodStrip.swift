import SwiftUI

struct PeriodStrip: View {
    let current: DayPeriod

    var body: some View {
        HStack(spacing: 7) {
            ForEach(DayPeriod.allCases) { period in
                VStack(spacing: 8) {
                    Capsule()
                        .fill(period == current ? PeriodTheme.forPeriod(period).accent : .white.opacity(0.12))
                        .frame(height: 3)
                    Text(period.title)
                        .font(.system(size: 11, weight: period == current ? .semibold : .regular))
                        .foregroundStyle(period == current ? .white : PeriodTheme.muted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 10)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("當地時段：\(current.title)，\(current.hours)")
    }
}
