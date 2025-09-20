//
//  SwipeDataSourceEnvironment.swift
//  SwipeCardKit
//
//  Created by 游哲維 on 2025/9/18.
//

import SwiftUI

@MainActor
private struct SwipeDataSourceKey: @MainActor EnvironmentKey {
    static let defaultValue: SwipeDataSource = MockSwipeDataSource()
}

@MainActor
public extension EnvironmentValues {
    var swipeDataSource: SwipeDataSource {
        get { self[SwipeDataSourceKey.self] }
        set { self[SwipeDataSourceKey.self] = newValue }
    }
}
