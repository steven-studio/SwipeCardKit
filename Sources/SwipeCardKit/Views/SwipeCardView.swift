//
//  SwipeCardView.swift
//  SwipeCardUI
//
//  Created by 游哲維 on 2025/3/16.
//

import SwiftUI

@available(iOS 14.0, *)
public struct SwipeCardView: View {
    // 依賴注入
    @StateObject public var viewModel = SwipeCardViewModel()
    
    public init() {}
    
    public var body: some View {
        ZStack {
            mainSwipeCardView

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        // 此處可接入隱私設定邏輯
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.gray)
                            .font(.system(size: 30))
                            .padding(.top, 50)
                            .padding(.trailing, 20)
                    }
                    .accessibility(identifier: "privacySettingsButton")
                }
                Spacer()
            }
        }
        .accessibilityIdentifier("SwipeCardViewIdentifier")
        .edgesIgnoringSafeArea(.all)
        .fullScreenCover(isPresented: .constant(false)) { // 改成實際的隱私設定畫面
            Text("隱私設定")
        }
        .onReceive(NotificationCenter.default.publisher(for: .undoSwipeNotification)) { _ in
            viewModel.undoSwipe()
            print("Got undo notification!")
        }
    }
    
    var mainSwipeCardView: some View {
        ZStack {
            if viewModel.showCircleAnimation {
                CircleExpansionView()
            } else {
                ForEach(Array(viewModel.users[viewModel.currentIndex..<min(viewModel.currentIndex + 3, viewModel.users.count)]).reversed(), id: \.id) { user in
                    let index = viewModel.users.firstIndex(where: { $0.id == user.id }) ?? 0
                    let isCurrentCard = index == viewModel.currentIndex
                    let baseY = CGFloat(index - viewModel.currentIndex) * 10
                    let rotationAngle = isCurrentCard ? Double(viewModel.offset.width / 40) : 0
                    let zIndexValue = Double(viewModel.users.count - index)
                    let scaleValue = isCurrentCard ? 1.0 : 0.95
                    
                    SwipeCard(user: user)
                        .offset(
                            x: isCurrentCard ? viewModel.offset.width : 0,
                            y: isCurrentCard ? viewModel.offset.height : baseY
                        )
                        .scaleEffect(scaleValue)
                        .rotationEffect(.degrees(rotationAngle))
                        .gesture(
                            isCurrentCard ? DragGesture()
                                .onChanged { gesture in
                                    viewModel.offset = gesture.translation
                                }
                                .onEnded { value in
                                    let predictedX = value.predictedEndTranslation.width
                                    let predictedY = value.predictedEndTranslation.height
                                    if predictedX > 100 {
                                        viewModel.swipeOffScreen(toRight: true, predictedX: predictedX, predictedY: predictedY)
                                    } else if predictedX < -100 {
                                        viewModel.swipeOffScreen(toRight: false, predictedX: predictedX, predictedY: predictedY)
                                    } else {
                                        withAnimation(.spring()) {
                                            viewModel.offset = .zero
                                        }
                                    }
                                }
                            : nil
                        )
                        .zIndex(zIndexValue)
                        .animation(nil, value: viewModel.offset)
                }
            }
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
