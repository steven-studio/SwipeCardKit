//
//  SwipeCardView.swift
//  SwipeCardUI
//
//  Created by 游哲維 on 2025/3/16.
//

import SwiftUI

@available(iOS 14.0, *)
public struct SwipeCardView: View {
    @Environment(\.swipeDataSource) private var dataSource   // ← 讀取注入的資料源
    @StateObject public var viewModel: SwipeCardViewModel
    
    public init() {
        // 不能在這裡直接使用 @Environment，所以先用默認值
        self._viewModel = StateObject(wrappedValue: SwipeCardViewModel())
    }

    public var body: some View {
        VStack(spacing: 0) {
            mainSwipeCardView
                .padding(.horizontal, 10)
                .padding(.top, 8)
        }
        .accessibilityIdentifier("SwipeCardViewIdentifier")
        .onAppear {
            print("🟢 SwipeCardView onAppear called")
            print("🟢 DataSource type: \(type(of: dataSource))")

            // 關鍵：將環境中的數據源傳給 viewModel 並載入數據
            Task {
                do {
                    print("🟢 Calling fetchInitialCards...")
                    let users = try await dataSource.fetchInitialCards()
                    print("🟢 Fetched \(users.count) users:")
                    for (index, user) in users.enumerated() {
                        print("   \(index): \(user.name) - \(user.medias.first?.url ?? "no photo")")
                    }
                    
                    // 在主線程更新 UI
                    await MainActor.run {
                        print("🟢 Setting viewModel.users...")
                        // 將載入的數據複製到當前 viewModel
                        viewModel.users = users
                        print("🟢 ViewModel users count after update: \(viewModel.users.count)")
                    }
                } catch {
                    print("🔴 Error loading cards: \(error)")
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .undoSwipeNotification)) { _ in
            viewModel.undoSwipe()
        }
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Spacer()
            Button {
                // 開啟隱私/過濾設定
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.gray)
                    .font(.system(size: 22, weight: .semibold))
            }
            .accessibility(identifier: "privacySettingsButton")
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color.clear)
    }
    
    var mainSwipeCardView: some View {
        ZStack {
            if viewModel.showCircleAnimation {
                CircleExpansionView()
            } else {
                swipeCardsStack
            }
        }
    }
    
    // MARK: - Break down the complex expression into a separate computed property
    private var swipeCardsStack: some View {
        let visibleUsers = Array(viewModel.users[viewModel.currentIndex..<min(viewModel.currentIndex + 3, viewModel.users.count)]).reversed()
        
        return ForEach(visibleUsers, id: \.id) { user in
            swipeCardForUser(user)
        }
    }
    
    // MARK: - Individual card view builder
    private func swipeCardForUser(_ user: User) -> some View {
        let index = viewModel.users.firstIndex(where: { $0.id == user.id }) ?? 0
        let adjustedCurrentIndex = max(0, min(viewModel.currentIndex, viewModel.users.count - 1))
        let isCurrentCard = index == viewModel.currentIndex
        
        // Calculate transform values separately
        let cardDepth = index - adjustedCurrentIndex
        let baseY = CGFloat(index - viewModel.currentIndex) * 10
        // 旋轉角度計算（改進版本）
        let rotationAngle: Double = {
            guard isCurrentCard else { return 0 }
            
            let dx = viewModel.offset.width
            let dy = viewModel.offset.height
            let distance = sqrt(dx * dx + dy * dy)
            
            // 只有在滑動距離足夠時才開始旋轉
            guard distance > 10 else { return 0 }
            
            // 計算滑動角度
            let radians = atan2(dy, dx)
            var degrees = radians * 180 / .pi
            
            // Tinder 的特殊處理：
            // 1. 水平滑動主導時，旋轉更明顯
            // 2. 垂直滑動主導時，旋轉較少
            let horizontalDominance = (abs(dx) / (abs(dy) + 20)) * 2.0
            let rotationMultiplier = min(horizontalDominance, 1.0) // 0~1
            
            // 限制角度範圍
            let maxRotation: Double = 45.0
            if degrees > 0 {
                degrees = min(maxRotation, degrees)
            } else {
                degrees = max(-maxRotation, degrees)
            }
//            degrees = max(-maxRotation, min(maxRotation, degrees))
            
            // 根據距離和水平主導性調整強度
            let normalizedDistance = min(distance / 150, 1.0)
            let finalRotation = degrees * normalizedDistance * rotationMultiplier
            
            return finalRotation
        }()

        let zIndexValue = Double(viewModel.users.count - index)
        let scaleValue = isCurrentCard ? 1.0 : 0.95
        
        // 統一產生一組 predicted 值
        let screenWidth = UIScreen.main.bounds.width

        return SwipeCard(
            user: user,
            dragOffset: isCurrentCard ? viewModel.offset : .zero,
            onLike: { viewModel.handleSwipe(rightSwipe: true) },
            onDislike: { viewModel.handleSwipe(rightSwipe: false) },
            onUndo: { viewModel.undoSwipe() }
        )
        .offset(x: isCurrentCard ? viewModel.offset.width : 0,
                y: isCurrentCard ? viewModel.offset.height : baseY)
        .scaleEffect(scaleValue)
        .rotationEffect(.degrees(rotationAngle))
        .gesture(isCurrentCard ? createDragGesture() : nil)
        .zIndex(zIndexValue)
        .animation(nil, value: viewModel.offset)
    }
    
    // MARK: - Drag gesture builder
    private func createDragGesture() -> some Gesture {
        DragGesture()
            .onChanged { gesture in
                handleDragChanged(gesture)
            }
            .onEnded { value in
                handleDragEnded(value)
            }
    }
    
    // MARK: - Drag gesture handlers
    private func handleDragChanged(_ gesture: DragGesture.Value) {
        // 添加一些阻尼效果
        let translation = gesture.translation
        let dampingFactor: CGFloat = 0.8
        viewModel.offset = CGSize(
            width: translation.width * dampingFactor,
            height: translation.height * dampingFactor
        )
    }
    
    private func handleDragEnded(_ value: DragGesture.Value) {
        let swipeThreshold: CGFloat = 120 // 增加滑動閾值
        let velocityThreshold: CGFloat = 800 // 添加速度閾值
        
        let predictedX = value.predictedEndTranslation.width
        let predictedY = value.predictedEndTranslation.height
        let velocity = value.velocity.width
        
        // 結合位置和速度判斷
        if abs(velocity) > velocityThreshold || abs(predictedX) > swipeThreshold {
            if predictedX > 0 || velocity > velocityThreshold {
                viewModel.swipeOffScreen(toRight: true, predictedX: predictedX, predictedY: predictedY)
            } else if predictedX < 0 || velocity < -velocityThreshold {
                viewModel.swipeOffScreen(toRight: false, predictedX: predictedX, predictedY: predictedY)
            } else {
                animateCardBack()
            }
        } else {
            animateCardBack()
        }
    }
    
    private func animateCardBack() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            viewModel.offset = .zero
        }
    }

    var locationPermissionPromptView: some View {
        VStack {
            Spacer()
            Image(systemName: "location.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            Text("來認識附近的新朋友吧")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            Text("SwiftiDate 需要你的 \"位置權限\" 才能幫你找到附近好友哦")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
            Button(action: {

            }) {
                Text("前往設置")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding(.horizontal, 40)
            }
            Spacer()
        }
        .padding()
    }
}
