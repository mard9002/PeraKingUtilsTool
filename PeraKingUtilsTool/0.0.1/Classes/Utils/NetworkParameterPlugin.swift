// 
//  NetworkParameterPlugin.swift
//  PeraKing
//
//  Created on 2025/4/16.
//

import Foundation
import Moya


public final class NetworkParameterPlugin: PluginType {
    
    // MARK: - 属性
    
    /// 公共参数字典
    private let parameters: [String: Any]
    
    /// 是否强制覆盖已存在的同名参数
    private let overrideExisting: Bool
    
    /// 动态参数获取器
    private let dynamicParametersProvider: (() -> [String: Any])?
    
    // MARK: - 初始化
    
    /// 初始化网络参数插件
    /// - Parameters:
    ///   - parameters: 要添加的公共参数字典
    ///   - overrideExisting: 是否覆盖已存在的同名参数，默认为false
    ///   - dynamicParametersProvider: 动态参数提供器，用于每次请求时获取最新参数
    public init(
        parameters: [String: Any], 
        overrideExisting: Bool = false,
        dynamicParametersProvider: (() -> [String: Any])? = nil
    ) {
        self.parameters = parameters
        self.overrideExisting = overrideExisting
        self.dynamicParametersProvider = dynamicParametersProvider
    }
    
    // MARK: - PluginType 协议实现
    
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        // 获取所有参数（静态 + 动态）
        var allParameters = parameters
        if let dynamicParams = dynamicParametersProvider?() {
            dynamicParams.forEach { allParameters[$0.key] = $0.value }
        }
        
        // 创建可变的请求副本
        var mutableRequest = request
        
        // 所有请求都添加URL查询参数
        mutableRequest = addQueryParameters(to: mutableRequest, parameters: allParameters)
        
        return mutableRequest
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加查询参数到URL
    private func addQueryParameters(to request: URLRequest, parameters: [String: Any]) -> URLRequest {
        // 获取请求URL
        guard let url = request.url else { return request }
        
        // 创建可变的请求副本
        var mutableRequest = request
        
        // 获取当前URL的查询参数
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        // 从URL中提取现有的查询项
        var queryItems = components?.queryItems ?? []
        
        // 获取已存在的参数名
        let existingParameterNames = Set(queryItems.map { $0.name })
        
        // 添加公共参数
        for (key, value) in parameters {
            // 检查是否应该覆盖同名参数
            if !overrideExisting && existingParameterNames.contains(key) {
                continue
            }
            
            // 如果需要覆盖同名参数，先移除旧参数
            if overrideExisting && existingParameterNames.contains(key) {
                queryItems.removeAll { $0.name == key }
            }
            
            // 添加新参数
            let stringValue = String(describing: value)
            let queryItem = URLQueryItem(name: key, value: stringValue)
            queryItems.append(queryItem)
        }
        
        // 更新请求URL
        components?.queryItems = queryItems
        if let newURL = components?.url {
            mutableRequest.url = newURL
        }
        
        return mutableRequest
    }
    
    // MARK: - 公共方法
    
    /// 检查请求是否已被参数插件修改
    /// - Parameter request: 要检查的请求
    /// - Returns: 如果请求包含任何公共参数，则返回true
    public static func didModify(_ request: URLRequest) -> Bool {
        guard let url = request.url,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else { 
            return false 
        }
        
        // 检查常见的公共参数是否存在于URL中
        let commonKeys = ["platform", "version", "device_id", "timestamp", "network_type"]
        let foundKeys = queryItems.map { $0.name }
        
        for key in commonKeys {
            if foundKeys.contains(key) {
                return true
            }
        }
        
        return false
    }
}

// MARK: - ConnectionType 扩展
public extension ConnectionType {
    
    /// 将ConnectionType转换为String
    var rawValue: String {
        switch self {
        case .wifi:
            return "wifi"
        case .cellular:
            return "cellular"
        case .ethernet:
            return "ethernet"
        case .unknown:
            return "unknown"
        }
    }
}

// MARK: - 使用示例
/*
使用示例:

// 1. 基本用法 - 在NetworkService初始化时添加参数插件
private init() {
    // ... 现有代码 ...
    
    // 创建基本公共参数
    let commonParameters = NetworkService.createCommonParameters()
    
    // 创建参数插件 - 附加动态时间戳
    let parameterPlugin = NetworkParameterPlugin(
        parameters: commonParameters,
        overrideExisting: false,
        dynamicParametersProvider: {
            return ["timestamp": Int(Date().timeIntervalSince1970)]
        }
    )
    
    self.provider = MoyaProvider<MultiTarget>(
        session: session,
        plugins: [networkLogger, parameterPlugin]
    )
    
    // ... 现有代码 ...
}

// 2. 高级用法 - 根据环境配置不同的参数
// 在AppDelegate中配置
func setupNetworkParameters() {
    // 基本参数
    var parameters: [String: Any] = [
        "platform": "iOS",
        "version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "",
        "build": Bundle.main.infoDictionary?["CFBundleVersion"] ?? ""
    ]
    
    // 添加设备信息
    if let deviceId = UIDevice.current.identifierForVendor?.uuidString {
        parameters["device_id"] = deviceId
    }
    
    // 根据环境添加参数
    #if DEBUG
    parameters["env"] = "development"
    #elseif STAGING
    parameters["env"] = "staging"
    #else
    parameters["env"] = "production"
    #endif
    
    // 创建插件实例
    let parameterPlugin = NetworkParameterPlugin(
        parameters: parameters,
        dynamicParametersProvider: {
            // 动态参数 - 每次请求时更新
            var dynamicParams: [String: Any] = [
                "timestamp": Int(Date().timeIntervalSince1970)
            ]
            
            // 添加网络状态
            let networkMonitor = NetworkMonitor.shared
            dynamicParams["network_type"] = networkMonitor.connectionType.rawValue
            dynamicParams["is_connected"] = networkMonitor.isConnected
            
            // 添加用户标识（如果已登录）
            if let userId = UserDefaults.standard.string(forKey: "user_id") {
                dynamicParams["user_id"] = userId
            }
            
            return dynamicParams
        }
    )
    
    // 配置网络服务
    NetworkService.configure(with: [parameterPlugin])
}

// 3. 检查请求是否已被修改 - 验证所有请求都添加了URL参数
func verifyParameters(request: URLRequest) -> Bool {
    // 检查URL中是否包含公共参数
    if NetworkParameterPlugin.didModify(request) {
        print("✅ 请求URL已正确添加公共参数")
        
        // 打印URL参数
        if let url = request.url, 
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let items = components.queryItems {
            for item in items {
                print("   参数: \(item.name) = \(item.value ?? "nil")")
            }
        }
        
        return true
    } else {
        print("❌ 请求URL未添加公共参数")
        return false
    }
}
*/ 
