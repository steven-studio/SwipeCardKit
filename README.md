# SwipeCardKit

一個使用 SwiftUI 開發的滑卡 (Swipe Card) UI 元件，讓你輕鬆在 iOS 專案中實作類似 Tinder 的卡片滑動互動。

### 功能特色

- **簡單易用**：以 SwiftUI 架構，輕鬆整合至既有專案。
- **自訂動畫**：可自訂卡片的飛出方向、距離與速度。
- **支援撤銷 (undo)**：一鍵回到上一張卡片狀態。
- **可擴充**：使用者可根據自身需求，擴充後端與資料邏輯。

### 安裝方式

**Swift Package Manager**

1.    在 Xcode 內開啟專案後，點選 File > Add Packages...
2.    在搜尋框輸入此套件的 GitHub 連結，例如：
```
https://github.com/steven-studio/SwipeCardKit
```

3.    選擇要安裝到的 Target，並完成安裝。

或在 Package.swift 中手動加入：
```swift
dependencies: [
    .package(url: "https://github.com/你的帳號/SwipeCardUI.git", from: "1.0.0")
]
```
### 快速上手

以下示範如何在 SwiftUI View 中使用 SwipeCardUI 提供的 SwipeCardView 或 SwipeCardViewModel：
```swift
import SwiftUI
import SwipeCardUI

struct ContentView: View {
    // 建立一個 ViewModel 實例
    @StateObject private var viewModel = SwipeCardViewModel()
    
    var body: some View {
        VStack {
            // 這裡放一個卡片視圖
            SwipeCardView(
                viewModel: viewModel
            )
            
            HStack {
                // 左滑按鈕
                Button(action: {
                    viewModel.swipeOffScreen(toRight: false,
                                             predictedX: -100,
                                             predictedY: 0)
                }) {
                    Text("👎")
                }
                
                // 右滑按鈕
                Button(action: {
                    viewModel.swipeOffScreen(toRight: true,
                                             predictedX: 100,
                                             predictedY: 0)
                }) {
                    Text("👍")
                }
                
                // 撤銷按鈕
                Button(action: {
                    viewModel.undoSwipe()
                }) {
                    Text("↩️")
                }
            }
        }
    }
}
```
### 主要類別與方法
- **SwipeCardViewModel**
  - currentIndex: 目前顯示卡片的索引
  - swipeOffScreen(toRight: Bool, predictedX: CGFloat, predictedY: CGFloat): 將卡片滑出螢幕
  - undoSwipe(): 撤銷上一次滑動
- **SwipeCardView**
  - 搭配 SwipeCardViewModel，呈現多張卡片重疊的 UI。

### 進階設定
1.    **自訂資料來源**：
- 你可以將自訂的 User 或其他資料模型注入到 SwipeCardViewModel，再配合專案需求改寫 handleSwipe 與 undoSwipe。
2.    **整合後端**：
- 若需將滑動行為上傳至 Firestore、Core Data 等，可在子類別中 override handleSwipe 與 undoSwipe，或自行擴充方法。
3.    **動畫效果調整**：
- 可調整 withAnimation(.easeOut(duration: 0.4)) 或使用其他 SwiftUI 動畫選項，達到不同的飛出速度與彈性。

### 範例專案

在 Examples 資料夾下可找到一個簡單的示例，展示如何整合 SwipeCardUI 與 SwiftUI App Life Cycle。你可以直接下載並執行，觀察並測試各種自訂參數。

### 貢獻方式

歡迎各路好手一同參與此專案的開發與改進：
1.    Fork 本專案
2.    建立新 branch (git checkout -b feature/你的功能)
3.    寫好程式後發送 Pull Request

如有任何建議或問題，也歡迎開 Issue 討論。

### 授權條款

本專案採用 MIT License 釋出。詳情請見 LICENSE 檔案。


# SwipeCardKit
