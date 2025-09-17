//
//  CircleExpansionView.swift
//  SwipeCardUI
//
//  Created by 游哲維 on 2025/3/16.
//

import Combine
import SwiftUI

public struct CircleData: Identifiable {
    public let id: UUID
    public var scale: CGFloat
    public var opacity: Double
    
    public init(id: UUID = UUID(), scale: CGFloat, opacity: Double) {
        self.id = id
        self.scale = scale
        self.opacity = opacity
    }
}

@available(iOS 13.0, *)
public struct CircleExpansionView: View {
    @State private var circles: [CircleData] = []
    public let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    public init() {}
    
    public var body: some View {
        ZStack {
            if #available(iOS 14.0, *) {
                Color.white.ignoresSafeArea()
            } else {
                // Fallback on earlier versions
            }
            VStack {
                ZStack {
                    // 中間示範用圖片（請自行替換）
                    Image("photo1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                    
                    ForEach(circles.indices, id: \.self) { index in
                        Circle()
                            .fill(Color.green)
                            .frame(width: 100, height: 100)
                            .scaleEffect(circles[index].scale)
                            .opacity(circles[index].opacity)
                            .onAppear {
                                withAnimation(Animation.easeOut(duration: 1.5)) {
                                    circles[index].scale = 5.0
                                    circles[index].opacity = 0.0
                                }
                            }
                    }
                }
                VStack {
                    Text("附近沒有更多的人了")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.top, 30)
                    Text("可以嘗試擴大距離和年齡範圍")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 5)
                    Button(action: {
                        // 編輯篩選條件的動作
                    }) {
                        HStack {
                            Text("編輯篩選條件")
                            Image(systemName: "chevron.right")
                        }
                        .foregroundColor(.green)
                        .font(.system(size: 16, weight: .medium))
                    }
                    .padding(.top, 20)
                }
            }
        }
        .onReceive(timer) { _ in
            let newCircle = CircleData(scale: 0.1, opacity: 1.0)
            circles.append(newCircle)
        }
    }
}
