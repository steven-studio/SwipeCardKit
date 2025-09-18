// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

// MARK: - 公开的主要组件
@available(iOS 13.0, *)
public struct SwipeCardKit {
    public static let version = "1.0.0"
    
    public init() {}
}

// MARK: - 公开所有需要的类型
public typealias SwipeUser = User
public typealias SwipeCardConfiguration = SwipeCardViewModel

// MARK: - 便利初始化方法
@available(iOS 14.0, *)
public extension SwipeCardView {
    /// 使用自定义用户数据初始化 SwipeCardView
    /// - Parameter users: 用户数组
    /// - Returns: 配置好的 SwipeCardView
    static func with(users: [User]) -> SwipeCardView {
        let view = SwipeCardView()
        view.viewModel.users = users
        return view
    }
}

// MARK: - 示例数据提供者
public struct SwipeCardDemo {
    /// 提供示例用户数据用于演示
    public static var sampleUsers: [User] {
        return [
            User(
                id: "demo_1",
                name: "Olivia",
                age: 25,
                zodiac: "天秤座",
                location: "台北市",
                height: 175,
                photos: [
                    "https://images.examples.com/wp-content/uploads/2017/11/person13.jpg",
                    "https://images.examples.com/wp-content/uploads/2017/11/person14.jpg"
                ]
            ),
            User(
                id: "demo_2",
                name: "Ryan",
                age: 28,
                zodiac: "狮子座",
                location: "新竹市",
                height: 180,
                photos: [
                    "https://images.examples.com/wp-content/uploads/2017/11/person15.jpg",
                    "https://images.examples.com/wp-content/uploads/2017/11/person16.jpg"
                ]
            ),
            User(
                id: "demo_3",
                name: "Maya",
                age: 23,
                zodiac: "双鱼座",
                location: "台中市",
                height: 165,
                photos: [
                    "https://images.examples.com/wp-content/uploads/2017/11/person17.jpg",
                    "https://images.examples.com/wp-content/uploads/2017/11/person18.jpg"
                ]
            ),
            User(
                id: "demo_4",
                name: "Ethan",
                age: 26,
                zodiac: "水瓶座",
                location: "高雄市",
                height: 178,
                photos: [
                    "https://images.examples.com/wp-content/uploads/2017/11/person19.jpg"
                ]
            )
        ]
    }
    
    /// 创建演示用的 SwipeCardView
    @available(iOS 14.0, *)
    public static func createDemoView() -> SwipeCardView {
        return SwipeCardView.with(users: sampleUsers)
    }
}
