import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("跟隨城市的時間") {
                    Text("時間來自裝置時鐘，依城市時區自動轉換。夏令時間與日期由系統時區資料處理，無須手動調整。")
                    Text("所有城市共用同一個當下；下方列表的時差與日期比較，皆以首頁選定城市為基準。")
                }
                Section("一天，六種光影") {
                    ForEach(DayPeriod.allCases) { period in
                        HStack {
                            Label(period.title, systemImage: period.symbol)
                            Spacer()
                            Text(period.hours).font(.subheadline.monospacedDigit()).foregroundStyle(.secondary)
                        }
                    }
                    Text("光影依固定的當地時間區間切換，是感受時間的插畫主題，不是即時天氣或當地日出日落預報。")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                Section("光影中的城市時光") {
                    Text("城市插畫由 AI 製作，天空、日月與光影由 SwiftUI 呈現。收藏只保存在這台裝置；第一版不需要帳號、網路或定位權限。")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("關於光影")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("完成") { dismiss() } }
            }
        }
        .preferredColorScheme(.dark)
    }
}
