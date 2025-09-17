//
//  User.swift
//  SwipeCardUI
//
//  Created by 游哲維 on 2025/3/16.
//


public struct User {
    public let id: String
    public let name: String
    public let age: Int
    public let zodiac: String
    public let location: String
    public let height: Int
    public let photos: [String]

    public init(id: String, name: String, age: Int, zodiac: String, location: String, height: Int, photos: [String]) {
        self.id = id
        self.name = name
        self.age = age
        self.zodiac = zodiac
        self.location = location
        self.height = height
        self.photos = photos
    }
}