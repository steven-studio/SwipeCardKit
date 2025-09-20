//
//  MockSwipeDataSource.swift
//  SwipeCardKit
//
//  Created by 游哲維 on 2025/9/18.
//

#if DEBUG
import Foundation

@MainActor
public final class MockSwipeDataSource: SwipeDataSource {
    private var users: [User] = SwipeCardDemo.sampleUsers

    public init(users: [User] = SwipeCardDemo.sampleUsers) {
        self.users = users
    }

    public func fetchInitialCards() async throws -> [User] {
        print("🔵 MockSwipeDataSource.fetchInitialCards called")
        print("🔵 Users in dataSource: \(users.count)")
        for (index, user) in users.enumerated() {
            print("   \(index): \(user.name)")
        }
        
        // 模擬 API 延遲
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 秒
        
        print("🔵 Returning \(users.count) users")
        return users
    }

    public func observeCards() -> AsyncStream<[User]> {
        let snapshot = users  // 先取快照再進 stream
        // 模擬單次更新，真實情境可能是持續更新
        return AsyncStream { continuation in
            continuation.yield(users)
            continuation.finish()
        }
    }

    public func send(action: SwipeAction, userID: String) async throws {
        // 模擬 swipe 動作：直接刪掉該使用者
        users.removeAll { $0.id == userID }
    }
}
#endif
