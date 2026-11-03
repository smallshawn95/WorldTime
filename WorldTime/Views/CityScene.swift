import SwiftUI

/// 透明城市插畫疊在六種天空上，光影由真正的當地時段決定。
struct CityScene: View {
    let city: City
    let period: DayPeriod

    private var theme: PeriodTheme { .forPeriod(period) }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(colors: theme.sky, startPoint: .top, endPoint: .bottom)

                if period == .night {
                    stars(in: geometry.size)
                }

                orb
                    .position(x: geometry.size.width * theme.orbPosition.x,
                              y: geometry.size.height * theme.orbPosition.y)

                if let artwork = city.artwork {
                    Image(artwork)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
                        .colorMultiply(theme.cityTint)
                        .brightness(theme.cityBrightness)
                } else {
                    // 額外城市使用中性城市剪影，不借用別座城市的地標。
                    GenericSkyline()
                        .fill(theme.cityTint.opacity(0.55))
                    GenericSkyline()
                        .fill(Color(hex: 0x182B3D).opacity(0.9))
                        .offset(x: -22, y: geometry.size.height * 0.15)
                }

                LinearGradient(stops: [
                    .init(color: .clear, location: 0.55),
                    .init(color: Color(hex: 0x0C1727).opacity(0.20), location: 0.70),
                    .init(color: Color(hex: 0x0C1727).opacity(0.90), location: 1)
                ], startPoint: .top, endPoint: .bottom)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }
        .accessibilityHidden(true)
    }

    private var orb: some View {
        ZStack {
            Circle()
                .fill(theme.accent.opacity(period == .night ? 0.12 : 0.22))
                .frame(width: 110, height: 110)
                .blur(radius: 22)
            if period == .night {
                Image(systemName: "moon.fill")
                    .font(.system(size: 30))
                    .rotationEffect(.degrees(-18))
                    .foregroundStyle(Color(hex: 0xF0E3BF))
            } else {
                Circle()
                    .fill(Color(hex: 0xFFF0C9).opacity(0.88))
                    .frame(width: 43, height: 43)
                    .blur(radius: 0.6)
            }
        }
    }

    private func stars(in size: CGSize) -> some View {
        Canvas { context, _ in
            for index in 0..<28 {
                let x = CGFloat((index * 73 + 19) % 100) / 100 * size.width
                let y = CGFloat((index * 37 + 11) % 46) / 100 * size.height
                let diameter: CGFloat = index.isMultiple(of: 5) ? 2 : 1
                context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: diameter, height: diameter)),
                             with: .color(.white.opacity(index.isMultiple(of: 3) ? 0.65 : 0.3)))
            }
        }
    }
}

private struct GenericSkyline: Shape {
    func path(in rect: CGRect) -> Path {
        let heights: [CGFloat] = [0.23, 0.31, 0.26, 0.40, 0.33, 0.48, 0.29, 0.35, 0.42, 0.27, 0.37, 0.30]
        let width = rect.width / CGFloat(heights.count)
        var path = Path()
        for (index, height) in heights.enumerated() {
            let building = CGRect(x: CGFloat(index) * width, y: rect.height * (1 - height),
                                  width: width + 1, height: rect.height * height)
            path.addRect(building)
        }
        return path
    }
}
