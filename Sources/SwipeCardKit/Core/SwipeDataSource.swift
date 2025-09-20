//
//  SwipeDataSource.swift
//  SwipeCardKit
//
//  Created by 游哲維 on 2025/9/18.
//

import Foundation

// 之後 UI 會呼叫這三種動作
public enum SwipeAction {
    case like
    case nope
    case rewind
}

// 套件只依賴這個協議；實作放在 App 端（Firebase/AWS/mock 都可以）
@MainActor
public protocol SwipeDataSource {
    /// 首次載入卡片（例如啟動或手動刷新）
    func fetchInitialCards() async throws -> [User]

    /// 需要即時更新就用（沒有即時需求可回傳一個不會產生事件的 stream）
    func observeCards() -> AsyncStream<[User]>

    /// 把使用者的操作送出去（like/nope/rewind）
    func send(action: SwipeAction, userID: String) async throws
}
