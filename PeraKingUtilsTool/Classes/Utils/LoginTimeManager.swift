
//
//  LoginTimeManager.swift
//  PeraKing
//  
//  Created by wealon on 2025.
//  PeraKing.
//  
import Foundation

public class LoginTimeManager {
    // 单例模式
    public static let shared = LoginTimeManager()
    
    // 存储键名
    private let loginTimeKey = "LoginTimeHistory"
    
    // 私有化初始化方法，防止外部实例化
    private init() {}
    
    /// 保存当前登录时间（时间戳，毫秒）
    public func saveLoginTime() {
        // 获取当前时间戳（毫秒）
        let currentTime = Date().timeIntervalSince1970 * 1000
        // 从 UserDefaults 中读取历史登录时间
        var loginTimeHistory: [Double] = UserDefaults.standard.array(forKey: loginTimeKey) as? [Double] ?? []
        // 添加当前时间戳到历史记录中
        loginTimeHistory.append(currentTime)
        // 保存更新后的历史记录
        UserDefaults.standard.set(loginTimeHistory, forKey: loginTimeKey)
        print("登录时间已保存：\(currentTime)")
    }
    
    /// 获取上次登录时间（时间戳，毫秒）
    public func getLastLoginTime() -> Double? {
        // 从 UserDefaults 中读取历史登录时间
        guard let loginTimeHistory = UserDefaults.standard.array(forKey: loginTimeKey) as? [Double] else {
            print("没有登录时间历史")
            return nil
        }
        // 如果有历史记录，返回倒数第二个登录时间（上次登录时间）
        // 如果历史记录只有一次登录，返回当前登录时间
        if loginTimeHistory.count >= 2 {
            let lastLoginTime = loginTimeHistory[loginTimeHistory.count - 2]
            print("上次登录时间：\(lastLoginTime)")
            return lastLoginTime
        } else if let lastLoginTime = loginTimeHistory.last {
            print("没有上次登录时间，返回当前登录时间：\(lastLoginTime)")
            return lastLoginTime
        } else {
            print("登录时间历史为空")
            return nil
        }
    }
    
    /// 清空登录时间历史
    public func clearLoginTimeHistory() {
        UserDefaults.standard.removeObject(forKey: loginTimeKey)
        print("登录时间历史已清空")
    }
}

