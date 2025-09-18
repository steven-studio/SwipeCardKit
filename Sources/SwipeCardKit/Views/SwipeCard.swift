//
//  SwipeCard.swift
//  SwipeCardUI
//
//  Created by 游哲維 on 2025/3/16.
//

import SwiftUI

@available(iOS 13.0, *)
public struct SwipeCard: View {
    public var user: User
    @State private var currentPhotoIndex = 0

    public init(user: User) {
        self.user = user
    }
    
    public var body: some View {
        ZStack {
            if user.photos.indices.contains(currentPhotoIndex) {
                if #available(iOS 17.0, *) {
                    photoImageView
                        .frame(maxWidth: UIScreen.main.bounds.width - 20, maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.white, lineWidth: 4))
                        .edgesIgnoringSafeArea(.top)
                        .onTapGesture { value in
                            let screenWidth = UIScreen.main.bounds.width
                            let tapX = value.x
                            if tapX < screenWidth / 2 {
                                if currentPhotoIndex > 0 {
                                    currentPhotoIndex -= 1
                                }
                            } else {
                                if currentPhotoIndex < user.photos.count - 1 {
                                    currentPhotoIndex += 1
                                }
                            }
                        }
                } else if #available(iOS 17.0, *) {
                    Image(user.photos[currentPhotoIndex])
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: UIScreen.main.bounds.width - 20, maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.white, lineWidth: 4))
                        .edgesIgnoringSafeArea(.top)
                        .onTapGesture { value in
                            let screenWidth = UIScreen.main.bounds.width
                            let tapX = value.x
                            if tapX < screenWidth / 2 {
                                if currentPhotoIndex > 0 {
                                    currentPhotoIndex -= 1
                                }
                            } else {
                                if currentPhotoIndex < user.photos.count - 1 {
                                    currentPhotoIndex += 1
                                }
                            }
                        }
                } else {
                    // 舊版本不支援 tap 座標，因此簡單切換至下一張圖片
                    Image(user.photos[currentPhotoIndex])
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: UIScreen.main.bounds.width - 20, maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.white, lineWidth: 4))
                        .edgesIgnoringSafeArea(.top)
                        .onTapGesture {
                            if currentPhotoIndex < user.photos.count - 1 {
                                currentPhotoIndex += 1
                            } else {
                                // 可根據需求回到第一張或不做事
                                currentPhotoIndex = 0
                            }
                        }
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
                    ForEach(0..<user.photos.count, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 4)
                            .frame(width: 40, height: 8)
                            .foregroundColor(index == currentPhotoIndex ? .white : .gray)
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
                            // Dislike action
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
                            // Like action
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
        }
    }
    
    // MARK: - 圖片視圖
    @ViewBuilder
    private var photoImageView: some View {
        let photoURL = user.photos[currentPhotoIndex]
        
        if #available(iOS 15.0, *) {
            // iOS 15+ 使用系統的 AsyncImage
            AsyncImage(url: URL(string: photoURL)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ZStack {
                    Color.gray.opacity(0.3)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
        } else {
            // iOS 13-14 降級處理
            LegacyAsyncImageView(url: photoURL)
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
