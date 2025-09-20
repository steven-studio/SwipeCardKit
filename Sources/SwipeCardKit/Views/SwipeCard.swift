//
//  SwipeCard.swift
//  SwipeCardUI
//
//  Created by 游哲維 on 2025/3/16.
//

import SwiftUI
import AVKit
import AVFoundation

@available(iOS 13.0, *)
public struct SwipeCard: View {
    public var user: User
    public var dragOffset: CGSize // 添加這個參數
    @State private var currentIndex = 0
    
    // ✅ 保留 AVPlayer，避免被釋放
    @State private var player: AVPlayer? = nil
    
    // 添加 viewModel 參數和回調函數
    public var onLike: (() -> Void)?
    public var onDislike: (() -> Void)?
    public var onUndo: (() -> Void)?

    // 修正初始化器 - 接受所有必要的參數
    public init(
        user: User,
        dragOffset: CGSize = .zero,
        onLike: (() -> Void)? = nil,
        onDislike: (() -> Void)? = nil,
        onUndo: (() -> Void)? = nil
    ) {
        self.user = user
        self.dragOffset = dragOffset
        self.onLike = onLike
        self.onDislike = onDislike
        self.onUndo = onUndo
    }

    public var body: some View {
        ZStack {
            if user.medias.indices.contains(currentIndex) {
                if #available(iOS 14.0, *) {
                    mediaView
                        .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.white, lineWidth: 4))
                        .edgesIgnoringSafeArea(.top)
                        .contentShape(Rectangle())   // 讓整塊都可點
                        .gesture(tapToNavigate)     // ← 改這裡：用可取座標的手勢
                        .onChange(of: currentIndex) { _ in preparePlayerForCurrentMedia() }
                        .onAppear { preparePlayerForCurrentMedia() }
                } else {
                    // Fallback on earlier versions
                    mediaView
                        .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.white, lineWidth: 4))
                        .edgesIgnoringSafeArea(.top)
                        .contentShape(Rectangle())   // 讓整塊都可點
                        .gesture(tapToNavigate)     // ← 改這裡：用可取座標的手勢
                }
            } else {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 5) {
                    ForEach(0..<user.medias.count, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 4)
                            .frame(width: 40, height: 8)
                            .foregroundColor(index == currentIndex ? .white : .gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)
                .padding(.horizontal)
                .cornerRadius(10)
                
                Spacer()
                
                VStack {
                    Spacer()
                    Text("\(user.name), \(user.age)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 10) {
                        HStack(spacing: 5) {
                            Image(systemName: "bolt.circle.fill")
                            Text(user.zodiac)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.8))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        
                        HStack(spacing: 5) {
                            Image(systemName: "location.fill")
                            Text(user.location)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.8))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        
                        HStack(spacing: 5) {
                            Image(systemName: "ruler")
                            Text("\(user.height) cm")
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.8))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Button(action: {
                            NotificationCenter.default.post(name: .undoSwipeNotification, object: nil)
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.8))
                                    .frame(width: 50, height: 50)
                                VStack {
                                    Image(systemName: "arrow.uturn.backward")
                                        .font(.title)
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // Dislike action - 使用回調函數
                            onDislike?()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.gray.opacity(0.8))
                                    .frame(width: 70, height: 50)
                                Image(systemName: "xmark")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.red)
                                    .accessibility(identifier: "xmarkButtonImage")
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // Message action
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.8))
                                    .frame(width: 50, height: 50)
                                VStack {
                                    Image(systemName: "message.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.gold) // 若 gold 需自訂
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // Like action - 使用回調函數
                            onLike?()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.gray.opacity(0.8))
                                    .frame(width: 70, height: 50)
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.green)
                                    .accessibility(identifier: "heartFillButtonImage")
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // Special feature action
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.8))
                                    .frame(width: 50, height: 50)
                                VStack {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            
            // 添加滑動提示覆蓋層
            swipeIndicatorOverlay
        }
    }
    
    // MARK: - 圖片視圖
    @ViewBuilder
    private var mediaView: some View {
        let media = user.medias[currentIndex]
        switch media.type {
        case .image:
            if #available(iOS 15.0, *) {
                AsyncImage(url: URL(string: media.url)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
            } else {
                LegacyAsyncImageView(url: media.url)
            }

        case .video:
            if #available(iOS 14.0, *) {
                if let player {
                    VideoPlayer(player: player)
                        .background(Color.black)                 // 看起來更穩
                        .aspectRatio(contentMode: .fill)
                        .onAppear { player.play() }              // ✅ 顯示時播放
                        .onDisappear { player.pause() }          // ✅ 離開時暫停
                } else {
                    // 還沒準備好 player 時顯示載入中
                    if #available(iOS 15.0, *) {
                        ZStack { Color.black; ProgressView().tint(.white) }
                    }
                }
            } else {
                // iOS 13 fallback：不支援 VideoPlayer，可顯示縮圖或提示
                ZStack { Color.black; Text("影片需 iOS 14+").foregroundColor(.white) }
            }
        }
    }
    
    // MARK: - 準備/更新 Player
    private func preparePlayerForCurrentMedia() {
        let media = user.medias[currentIndex]
        if media.type == .video, let url = URL(string: media.url) {
            // ⚠️ 若是 http 請確認 Info.plist 已允許 ATS，否則會黑屏
            // NSAppTransportSecurity -> NSAllowsArbitraryLoads = YES (或改用 https)
            player = AVPlayer(url: url)
        } else {
            // 切回圖片時釋放 player
            player?.pause()
            player = nil
        }
    }
    
    // MARK: - Tap -> 左右切換
    private var tapToNavigate: some Gesture {
        if #available(iOS 16.0, *) {
            return SpatialTapGesture()
                .onEnded { value in
                    let x = value.location.x
                    let mid = UIScreen.main.bounds.width / 2
                    if x < mid { prev() } else { next() }
                }
        } else {
            // iOS 13–15：用零距離 Drag 當 tap 並讀 location
            return DragGesture(minimumDistance: 0)
                .onEnded { value in
                    let x = value.location.x
                    let mid = UIScreen.main.bounds.width / 2
                    if x < mid { prev() } else { next() }
                }
        }
    }

    // MARK: - 索引邏輯（包成函式，避免越界/彈跳）
    private func next() {
        guard !user.medias.isEmpty else { return }
        // 你要「環狀」還是「卡住」自己選一種：
        // 環狀：
        currentIndex = (currentIndex + 1) % user.medias.count
        // 若想改為「卡住到最後一張」：
        // currentIndex = min(currentIndex + 1, user.medias.count - 1)
    }

    private func prev() {
        guard !user.medias.isEmpty else { return }
        // 環狀：
        currentIndex = (currentIndex - 1 + user.medias.count) % user.medias.count
        // 若想改為「卡住到第一張」：
        // currentIndex = max(currentIndex - 1, 0)
    }
    
    @ViewBuilder
    private var swipeIndicatorOverlay: some View {
        if abs(dragOffset.width) > 20 { // 只有在滑動距離足夠時才顯示
            ZStack {
                if dragOffset.width > 0 {
                    // 右滑 - 喜歡
                    HStack {
                        Spacer()
                        VStack {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(.green)
                            if #available(iOS 14.0, *) {
                                Text("LIKE")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                        .rotationEffect(.degrees(-20))
                        .opacity(min(Double(dragOffset.width / 150), 1.0))
                        .scaleEffect(min(dragOffset.width / 100, 1.5))
                        Spacer()
                    }
                } else {
                    // 左滑 - 不喜歡
                    HStack {
                        Spacer()
                        VStack {
                            Image(systemName: "xmark")
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(.red)
                            if #available(iOS 14.0, *) {
                                Text("NOPE")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                        .rotationEffect(.degrees(20))
                        .opacity(min(Double(abs(dragOffset.width) / 150), 1.0))
                        .scaleEffect(min(abs(dragOffset.width) / 100, 1.5))
                        Spacer()
                    }
                }
            }
            .allowsHitTesting(false) // 不干擾手勢
        }
    }
}

// MARK: - iOS 13-14 相容的圖片載入組件
@available(iOS 13.0, *)
struct LegacyAsyncImageView: View {
    let url: String
    @State private var image: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if isLoading {
                ZStack {
                    Color.gray.opacity(0.3)
                    if #available(iOS 14.0, *) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("載入中...")
                            .foregroundColor(.white)
                    }
                }
            } else {
                ZStack {
                    Color.gray.opacity(0.3)
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.white)
                            .font(.system(size: 30))
                        Text("載入失敗")
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                }
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        // 如果是本地圖片，直接載入
        if !url.hasPrefix("http") {
            self.image = UIImage(named: url)
            self.isLoading = false
            return
        }
        
        // 載入網路圖片
        guard let imageURL = URL(string: url) else {
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let data = data, let loadedImage = UIImage(data: data) {
                    self.image = loadedImage
                }
            }
        }.resume()
    }
}
