# 第一版驗證報告

檢查日期：2026-11-03（臺灣時間）。環境：Windows。

## 已執行並通過

| 檢查 | 結果 |
| --- | --- |
| Swift 語法解析 | 18 個 Swift 檔案無語法解析錯誤，含 App、測試與 Package.swift |
| 專案靜態驗證 | 76 項檢查通過，69 個 Xcode 專案物件參照皆可解析 |
| Xcode 目標及建置輸入 | App 與 XCTest 目標、測試相依、所有 Swift 檔案與資源皆列入，無重複編譯輸入 |
| 配置及資源 | Info.plist、PrivacyInfo.xcprivacy、共用 scheme、workspace 及 Asset Catalog JSON 可解析 |
| 圖片 | 三張 1024×1536 PNG 與透明天空保留；1024×1024 AppIcon 沒有透明通道 |
| 城市資料 | 186 個城市 ID 無重複，時區識別碼均獲 Node / ICU 接受；前三個仍為倫敦、臺北、紐約 |
| 獨立時區測資核對 | 24 組參考值通過 Node / ICU 的 IANA 時區資料核對，包括夏令時間開始／結束、南北半球的季節差異、半小時／45 分鐘時區與跨年跨日 |
| HTML 視覺預覽 | 18 次時段選擇、9 次城市切換、即時模式、圖片載入、390px 窄螢幕無水平溢出，且沒有 JavaScript 執行錯誤 |
| 視覺檢閱 | 已查看三城市完整預覽圖，確認城市景色、時間、時段與下方比較列表可讀 |

時間測資核對使用的是獨立 JavaScript 參考實作，**不代表 Swift 程式已執行**。HTML 預覽的檢查也**不代表 iOS UI 測試已執行**。

## 已提供、尚未執行

`WorldTimeTests` 共有 **28 個 XCTest 測試方法**，涵蓋：

- 倫敦／紐約春季跳時與秋季重複時段，以及英美不同週切換的時差。
- 六個時段的全部 24 小時與邊界。
- 臺北、新德里、加德滿都的時差與時間格式。
- 跨年、跨日及國際換日線兩個曆日的差異。
- 城市時區識別碼、搜尋及初始資料。
- 城市地區分類、南半球夏令時間與加拿大紐芬蘭半小時時區。
- 收藏去重、移除選中城市、保留最後一座城市、排序、損壞資料與儲存還原。

此環境沒有 `swift`、`xcodebuild`、iOS SDK 或 iOS Simulator，所以沒有執行以下操作：

- Swift 型別檢查、連結及完整 iOS 編譯。
- `swift test` 或 Xcode XCTest。
- iPhone 模擬器／實機的互動、VoiceOver、動態文字大小及前背景測試。
- 簽章、打包 `.ipa` 或 App Store 上傳。

靜態語法解析無法保證 SwiftUI 的所有 API 型別與執行時行為都正確。完整可執行性仍須以下 Mac 驗證。

## Mac 上的下一步

1. Xcode 15+ 開啟 `WorldTime.xcodeproj`，選擇 iOS 17+ iPhone 模擬器，按 ⌘R。
2. 按 ⌘U 執行測試，或在專案目錄執行 `bash Scripts/verify-macos.sh`。
3. 實際切換三個初始城市，檢查主頁日期、時段與其他城市的相對日期。
4. 新增城市、刪除當前城市、排序、重開 App，確認收藏狀態恢復。
5. 以較大字級、VoiceOver 及前後景切換確認使用情況。

模擬器建置不需要開發者簽章；安裝到 iPhone 時才需選擇自己的 Team 與唯一 Bundle Identifier。

## 檢查工具

- `Tools/validate_project.py`：靜態 Swift / Xcode / plist / 圖片檢查。需要 `tree-sitter`、`tree-sitter-swift`、`openstep-parser` 與 Pillow，僅供維護使用。
- `Tools/check-timezone-fixtures.cjs`：用 Node 的 ICU 資料獨立核對測資。
- `Tools/check-city-catalog.cjs`：檢查城市 ID、初始順序與時區識別碼。
- `Scripts/verify-macos.sh`：使用真正的 Swift 與 Xcode 工具測試及建置，任何失敗立即停止。

App 本身沒有第三方套件，使用者開啟 Xcode 專案不必安裝上述 Python / Node 工具。

實作參照 Apple 文件：[TimelineView](https://developer.apple.com/documentation/swiftui/timelineview)、[依日期計算時區偏移](https://developer.apple.com/documentation/foundation/timezone/secondsfromgmt(for:))、[UserDefaults 隱私原因宣告](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitypereasons)。
