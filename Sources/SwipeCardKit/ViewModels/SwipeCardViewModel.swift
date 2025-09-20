//
//  SwipeCardViewModel.swift
//  SwipeCardUI
//
//  Created by 游哲維 on 2025/3/16.
//

import Foundation
import SwiftUI

@available(iOS 13.0, *)
@MainActor
public class SwipeCardViewModel: ObservableObject {
    private let currentUserID = "abc123"
    
    @Published public var users: [User] = []
    @Published public var currentIndex: Int = 0
    @Published public var showCircleAnimation: Bool = false
    @Published public var offset: CGSize = .zero
    // 觸點相對卡片中心的 y（正規化到 [-1, 1]），可為 nil 表示未知
    @Published var touchAnchorY: CGFloat? = nil
    @Published public var isAnimating: Bool = false // 添加動畫狀態

//    @Published public var swipedIDs: Set<String> = []
    @Published public var lastSwipedData: (user: User, index: Int, isRightSwipe: Bool)?
    @Published public var lastSwipedOffset: CGSize?
    @Published public var likeCount: Int = 0
    
    private let dataSource: SwipeDataSource
    private var observeTask: Task<Void, Never>?
    
    // 供外部注入；預設用內建 Mock（見下方）
    public init(dataSource: SwipeDataSource = MockSwipeDataSource()) {
        self.dataSource = dataSource
    }
    
    deinit { observeTask?.cancel() }

    // 在畫面出現時呼叫
    public func load() {
        observeTask?.cancel()

        observeTask = Task { [weak self] in
            guard let self else { return }
            do {
                let initial = try await dataSource.fetchInitialCards()
                self.users = initial
            } catch {
                // 這裡可加錯誤 UI；先簡單印出
                print("[SwipeCardVM] fetchInitialCards error:", error)
            }

            // 即時更新
            for await batch in dataSource.observeCards() {
                self.users = batch
                // 如果要保留 currentIndex 的相對位置，可在這裡做對齊邏輯
            }
        }
    }

    // 將既有的 swipe 行為串到資料來源
    public func likeCurrent() {
        guard let user = users[safe: currentIndex] else { return }
        Task { try? await dataSource.send(action: .like, userID: user.id) }
        advance()
    }
    public func nopeCurrent() {
        guard let user = users[safe: currentIndex] else { return }
        Task { try? await dataSource.send(action: .nope, userID: user.id) }
        advance()
    }
    // MARK: - 統一的移動到下一張卡片方法
    public func moveToNextCard() {
        print("➡️ moveToNextCard called - current: \(currentIndex)")
        
        if currentIndex < users.count - 1 {
            currentIndex += 1
            print("   ✅ Moved to index: \(currentIndex)")
        } else {
            print("   🎉 Reached end of cards - showing animation")
            withAnimation(.easeInOut(duration: 0.5)) {
                showCircleAnimation = true
            }
        }
        
        // 重置 offset
        offset = .zero
    }

    public func rewind() {
        // 視需求而定：這裡只示範呼叫
        if let user = users[safe: max(currentIndex - 1, 0)] {
            Task { try? await dataSource.send(action: .rewind, userID: user.id) }
        }
        currentIndex = max(currentIndex - 1, 0)
    }

    private func advance() {
        currentIndex = min(currentIndex + 1, max(users.count - 1, 0))
        offset = .zero
    }



    public func swipeOffScreen(toRight: Bool, predictedX: CGFloat, predictedY: CGFloat) {
        guard !isAnimating else { return } // 防止重複觸發
        
        isAnimating = true
        
        let screenWidth = UIScreen.main.bounds.width
        let flyDistance: CGFloat = screenWidth * 1.2
        let verticalOffset = predictedY * 0.3
        let finalX = toRight ? flyDistance : -flyDistance

        // 第一階段：滑出動畫
        withAnimation(.easeOut(duration: 5)) {
            self.offset = CGSize(width: finalX, height: verticalOffset)
        }
        
        // 保存最後的偏移量供撤銷使用
        self.lastSwipedOffset = CGSize(width: finalX, height: verticalOffset)
        
        // 等待滑出動畫完成後再處理下一張卡片
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // 記錄滑動數據
            self.handleSwipe(rightSwipe: toRight)
            self.isAnimating = false // 添加這行
        }
    }
    
    public func handleSwipe(rightSwipe: Bool) {
        guard currentIndex < users.count else {
            print("Error: currentIndex out of range")
            return
        }
        
        let screenWidth = UIScreen.main.bounds.width
        let flyDistance: CGFloat = screenWidth * 1.4
        let finalX = rightSwipe ? flyDistance : -flyDistance
        
        print("🎬 handleSwipe triggered, rightSwipe=\(rightSwipe)")
        
        // 1️⃣ 播放飛出動畫
        withAnimation(.easeOut(duration: 5)) {
            self.offset = CGSize(width: finalX, height: 0)
        }
        
        // 2️⃣ 等動畫結束後再更新狀態
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            let data: [String: Any] = [
                "userID": "<current user ID>",
                "targetID": self.users[self.currentIndex].id,
                "isLike": rightSwipe,
            ]
                
            // 假設寫入成功，記錄最後滑卡資料
            self.lastSwipedData = (user: self.users[self.currentIndex], index: self.currentIndex, isRightSwipe: rightSwipe)

            if rightSwipe {
                self.likeCount += 1
            }
            
            if self.currentIndex < self.users.count - 1 {
                self.currentIndex += 1
            } else {
                withAnimation {
                    self.showCircleAnimation = true
                }
            }
        }
        self.offset = .zero
    }
    
    public func undoSwipe() {
        guard let data = lastSwipedData else {
            print("No swipe to undo")
            return
        }
        print("Undoing swipe:", data)
        
        if data.isRightSwipe {
            self.likeCount -= 1
        }
        self.currentIndex = data.index
        if let oldOffset = self.lastSwipedOffset {
            self.offset = oldOffset
        } else {
            self.offset = CGSize(width: 1000, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 5.0)) {
                self.offset = .zero
            }
        }
        withAnimation {
            self.showCircleAnimation = false
        }
        self.lastSwipedData = nil
    }
}

extension Notification.Name {
    static let undoSwipeNotification = Notification.Name("undoSwipeNotification")
}

// 小工具：安全取 index
private extension Array {
    subscript(safe idx: Int) -> Element? { (0..<count).contains(idx) ? self[idx] : nil }
}
