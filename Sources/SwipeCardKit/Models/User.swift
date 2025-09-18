//
//  User.swift
//  SwipeCardUI
//
//  Created by 游哲維 on 2025/3/16.
//

import Foundation

/// 代表一个可滑动卡片的用户模型
public struct User: Identifiable, Codable, Equatable {
    public let id: String
    public let name: String
    public let age: Int
    public let zodiac: String
    public let location: String
    public let height: Int
    public let photos: [String]

    /// 完整初始化方法
    /// - Parameters:
    ///   - id: 用户唯一标识符
    ///   - name: 用户姓名
    ///   - age: 年龄
    ///   - zodiac: 星座
    ///   - location: 位置
    ///   - height: 身高（厘米）
    ///   - photos: 照片名称数组
    public init(
        id: String,
        name: String,
        age: Int,
        zodiac: String,
        location: String,
        height: Int,
        photos: [String]
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.zodiac = zodiac
        self.location = location
        self.height = height
        self.photos = photos
    }
    
    /// 便利初始化方法（自动生成 ID）
    /// - Parameters:
    ///   - name: 用户姓名
    ///   - age: 年龄
    ///   - zodiac: 星座
    ///   - location: 位置
    ///   - height: 身高（厘米）
    ///   - photos: 照片名称数组
    public init(
        name: String,
        age: Int,
        zodiac: String,
        location: String,
        height: Int,
        photos: [String]
    ) {
        self.init(
            id: UUID().uuidString,
            name: name,
            age: age,
            zodiac: zodiac,
            location: location,
            height: height,
            photos: photos
        )
    }
}

// MARK: - Builder Pattern (可选的便利方法)
public extension User {
    /// Builder 模式创建用户
    static func builder() -> UserBuilder {
        return UserBuilder()
    }
}

public class UserBuilder {
    private var id: String = UUID().uuidString
    private var name: String = ""
    private var age: Int = 18
    private var zodiac: String = ""
    private var location: String = ""
    private var height: Int = 170
    private var photos: [String] = []
    
    public init() {}
    
    public func id(_ id: String) -> UserBuilder {
        self.id = id
        return self
    }
    
    public func name(_ name: String) -> UserBuilder {
        self.name = name
        return self
    }
    
    public func age(_ age: Int) -> UserBuilder {
        self.age = age
        return self
    }
    
    public func zodiac(_ zodiac: String) -> UserBuilder {
        self.zodiac = zodiac
        return self
    }
    
    public func location(_ location: String) -> UserBuilder {
        self.location = location
        return self
    }
    
    public func height(_ height: Int) -> UserBuilder {
        self.height = height
        return self
    }
    
    public func photos(_ photos: [String]) -> UserBuilder {
        self.photos = photos
        return self
    }
    
    public func build() -> User {
        return User(
            id: id,
            name: name,
            age: age,
            zodiac: zodiac,
            location: location,
            height: height,
            photos: photos
        )
    }
}
