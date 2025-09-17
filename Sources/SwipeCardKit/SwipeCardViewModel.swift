//
//  SwipeCardViewModel.swift
//  SwipeCardUI
//
//  Created by 游哲維 on 2025/3/16.
//

import Foundation
import SwiftUI

@MainActor
public class SwipeCardViewModel: ObservableObject {
    private let currentUserID = "abc123"
    
    @Published public var currentIndex: Int = 0
    @Published public var offset: CGSize = .zero
    @Published public var showCircleAnimation: Bool = false
    @Published public var swipedIDs: Set<String> = []
    @Published public var lastSwipedData: (user: User, index: Int, isRightSwipe: Bool)?
    @Published public var lastSwipedOffset: CGSize?
    @Published public var likeCount: Int = 0
    @Published public var users: [User] = []
    
    public init() {
        // For demo,使用靜態資料
        self.users = [
            User(id: "userID_2", name: "後照鏡被偷", age: 20, zodiac: "雙魚座", location: "桃園市", height: 172, photos: ["userID_2_photo1", "userID_2_photo2"]),
            User(id: "userID_3", name: "小明", age: 22, zodiac: "天秤座", location: "台北市", height: 180, photos: ["userID_3_photo1", "userID_3_photo2", "userID_3_photo3"]),
            User(id: "userID_4", name: "小花", age: 25, zodiac: "獅子座", location: "新竹市", height: 165, photos: ["userID_4_photo1", "userID_4_photo2"])
        ]
    }
    
    public func swipeOffScreen(toRight: Bool, predictedX: CGFloat, predictedY: CGFloat) {
        let flyDistance: CGFloat = 1000
        let ratio = predictedY / predictedX
        let finalY = ratio * flyDistance
        let finalX = toRight ? flyDistance : -flyDistance
        
        withAnimation(.easeOut(duration: 0.4)) {
            self.offset = CGSize(width: finalX, height: finalY)
        }
        
        self.lastSwipedOffset = CGSize(width: finalX, height: finalY)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.handleSwipe(rightSwipe: toRight)
        }
    }
    
    public func handleSwipe(rightSwipe: Bool) {
        guard currentIndex < users.count else {
            print("Error: currentIndex out of range")
            return
        }
        
        let data: [String: Any] = [
            "userID": "<current user ID>",
            "targetID": users[currentIndex].id,
            "isLike": rightSwipe,
        ]
            
        // 假設寫入成功，記錄最後滑卡資料
        self.lastSwipedData = (user: self.users[self.currentIndex], index: self.currentIndex, isRightSwipe: rightSwipe)

        if rightSwipe {
            self.likeCount += 1
        }
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.currentIndex < self.users.count - 1 {
                self.currentIndex += 1
            } else {
                withAnimation {
                    self.showCircleAnimation = true
                }
            }
            self.offset = .zero
        }
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
