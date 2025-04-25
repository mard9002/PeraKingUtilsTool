//
//  NetworkMonitor.swift
//  PeraKing
//
//  Created by Tingyu on 2025/4/16.
//

import Foundation
import Network
import CoreTelephony

/// 网络连接类型
public enum ConnectionType {
    case wifi
    case cellular
    case ethernet
    case unknown
}

/// 网络权限状态
public enum NetworkPermissionStatus {
    case authorized        // 已授权
    case denied            // 被拒绝
    case restricted        // 受限制
    case unknown           // 未知状态
}

/// 网络状态监控工具
public final class NetworkMonitor {
    
    // MARK: - 单例实例
    public static let shared = NetworkMonitor()
    
    // MARK: - 属性
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private let cellularData = CTCellularData()
    
    /// 当前网络连接状态
    private(set) public var isConnected: Bool = false
    
    /// 当前连接类型
    private(set) public var connectionType: ConnectionType = .unknown
    
    /// 当前网络权限状态
    private(set) public var permissionStatus: NetworkPermissionStatus = .unknown
    
    /// 状态变化回调
    public var statusChangeHandler: ((Bool, ConnectionType) -> Void)?
    
    /// 权限变化回调
    public var permissionChangeHandler: ((NetworkPermissionStatus) -> Void)?
    
    /// 权限检查计时器
    private var permissionCheckTimer: Timer?
    
    /// 上次检查的权限状态
    private var lastPermissionStatus: NetworkPermissionStatus = .unknown
    
    // MARK: - 通知名称
    public struct Notifications {
        public static let networkStatusChanged = Notification.Name("NetworkStatusChangedNotification")
        public static let networkPermissionChanged = Notification.Name("NetworkPermissionChangedNotification")
    }
    
    // MARK: - 初始化
    private init() {
        monitor = NWPathMonitor()
        startMonitoring()
        checkNetworkPermission()
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - 公共方法
    
    /// 开始监控网络状态
    public func startMonitoring() {
        // 监控网络连接状态
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
                self.getConnectionType(path)
                
                // 通知状态变化
                self.statusChangeHandler?(self.isConnected, self.connectionType)
                
                // 发送通知
                NotificationCenter.default.post(
                    name: Notifications.networkStatusChanged,
                    object: nil,
                    userInfo: [
                        "isConnected": self.isConnected,
                        "connectionType": self.connectionType
                    ]
                )
                
                // 网络状态变化时，重新检查权限状态
                self.refreshPermissionStatus()
            }
        }
        
        monitor.start(queue: queue)
        
        // 监控网络权限状态
        startMonitoringPermission()
    }
    
    /// 停止监控网络状态
    public func stopMonitoring() {
        monitor.cancel()
        stopPermissionCheckTimer()
        
        // 移除通知观察者
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 检查网络权限
    public func checkNetworkPermission() {
        // 使用CTCellularData来检查蜂窝数据权限，间接反映网络权限状态
        cellularData.cellularDataRestrictionDidUpdateNotifier = { [weak self] restrictionState in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch restrictionState {
                case .notRestricted:
                    // 没有限制，说明已授权
                    self.updatePermissionStatus(.authorized)
                case .restricted:
                    // 受限制，说明权限被拒绝
                    self.updatePermissionStatus(.denied)
                case .restrictedStateUnknown:
                    // 状态未知
                    self.updatePermissionStatus(.unknown)
                @unknown default:
                    self.updatePermissionStatus(.unknown)
                }
            }
        }
    }
    
    /// 主动触发权限检查（可用于用户手动刷新权限状态）
    public func refreshPermissionStatus() {
        // 这个方法会触发cellularData.cellularDataRestrictionDidUpdateNotifier
        let restrictionState = cellularData.restrictedState
        
        // 主动更新权限状态，而不仅仅依赖通知回调
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch restrictionState {
            case .notRestricted:
                self.updatePermissionStatus(.authorized)
            case .restricted:
                self.updatePermissionStatus(.denied)
            case .restrictedStateUnknown:
                self.updatePermissionStatus(.unknown)
            @unknown default:
                self.updatePermissionStatus(.unknown)
            }
        }
    }
    
    // MARK: - 私有方法
    
    /// 检查连接类型
    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }
    
    /// 开始监控网络权限状态
    private func startMonitoringPermission() {
        // 停止之前的计时器（如果有）
        stopPermissionCheckTimer()
        
        // 第一次检查权限状态
        refreshPermissionStatus()
        
        // 5秒后再次检查一次，确保权限状态已正确读取
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.refreshPermissionStatus()
        }
        
        // 启动定期检查权限的计时器（每30秒检查一次）
        DispatchQueue.main.async { [weak self] in
            self?.startPermissionCheckTimer()
        }
        
        // 注册应用状态变化通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    /// 启动权限检查计时器
    private func startPermissionCheckTimer() {
        // 停止之前的计时器（如果有）
        stopPermissionCheckTimer()
        
        // 创建新的计时器，每30秒检查一次权限状态
        permissionCheckTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.refreshPermissionStatus()
        }
    }
    
    /// 停止权限检查计时器
    private func stopPermissionCheckTimer() {
        permissionCheckTimer?.invalidate()
        permissionCheckTimer = nil
    }
    
    /// 应用回到前台时刷新权限状态
    @objc private func applicationDidBecomeActive() {
        refreshPermissionStatus()
        
        // 重新启动计时器
        startPermissionCheckTimer()
    }
    
    /// 应用即将进入前台时
    @objc private func applicationWillEnterForeground() {
        // 应用即将进入前台时刷新权限状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.refreshPermissionStatus()
        }
    }
    
    /// 更新权限状态并触发通知
    private func updatePermissionStatus(_ status: NetworkPermissionStatus) {
        // 只有状态发生变化时才触发
        guard status != permissionStatus else { return }
        
        // 记录上次的状态
        lastPermissionStatus = permissionStatus
        
        // 更新状态
        permissionStatus = status
        
        print("网络权限状态已变更: \(lastPermissionStatus) -> \(status)")
        
        // 触发回调
        self.permissionChangeHandler?(status)
        
        // 发送通知
        NotificationCenter.default.post(
            name: Notifications.networkPermissionChanged,
            object: nil,
            userInfo: ["permissionStatus": status]
        )
    }
}

// MARK: - 网络监控扩展 (仅适用于iOS 13+)

@available(iOS 13.0, *)
public extension NetworkMonitor {
    
    /// 获取当前网络连接信息的字符串表示
    var connectionDescription: String {
        if !isConnected {
            return "未连接网络"
        }
        
        switch connectionType {
        case .wifi:
            return "WiFi连接"
        case .cellular:
            return "蜂窝数据连接"
        case .ethernet:
            return "有线网络连接"
        case .unknown:
            return "其他网络连接"
        }
    }
    
    /// 检查网络是否受限制（允许访问有限的互联网资源）
    var isNetworkConstrained: Bool {
        return monitor.currentPath.isConstrained
    }
    
    /// 检查是否是低数据模式
    var isExpensive: Bool {
        return monitor.currentPath.isExpensive
    }
    
    /// 获取网络权限状态的字符串表示
    var permissionDescription: String {
        switch permissionStatus {
        case .authorized:
            return "网络权限已授权"
        case .denied:
            return "网络权限被拒绝"
        case .restricted:
            return "网络权限受限"
        case .unknown:
            return "网络权限状态未知"
        }
    }
}

// MARK: - 使用示例

/*
// 在AppDelegate或其他适当位置启动网络监控
func setupNetworkMonitor() {
    // 开始监控网络状态
    NetworkMonitor.shared.startMonitoring()
    
    // 设置状态变化回调
    NetworkMonitor.shared.statusChangeHandler = { isConnected, connectionType in
        if isConnected {
            print("网络已连接，类型: \(connectionType)")
        } else {
            print("网络已断开")
        }
    }
    
    // 设置权限变化回调
    NetworkMonitor.shared.permissionChangeHandler = { status in
        switch status {
        case .authorized:
            print("网络权限已授权，可以正常访问网络")
        case .denied:
            print("网络权限被拒绝，请在设置中允许网络访问")
            // 显示引导用户去设置页面的提示
        case .restricted:
            print("网络权限受限")
        case .unknown:
            print("网络权限状态未知")
        }
    }
    
    // 也可以通过通知接收状态变化
    NotificationCenter.default.addObserver(
        self,
        selector: #selector(networkStatusChanged),
        name: NetworkMonitor.Notifications.networkStatusChanged,
        object: nil
    )
    
    // 通过通知接收权限变化
    NotificationCenter.default.addObserver(
        self,
        selector: #selector(networkPermissionChanged),
        name: NetworkMonitor.Notifications.networkPermissionChanged,
        object: nil
    )
}

@objc private func networkStatusChanged(_ notification: Notification) {
    guard let isConnected = notification.userInfo?["isConnected"] as? Bool,
          let connectionType = notification.userInfo?["connectionType"] as? ConnectionType else {
        return
    }
    
    if isConnected {
        print("网络已连接，类型: \(connectionType)")
    } else {
        print("网络已断开")
    }
}

@objc private func networkPermissionChanged(_ notification: Notification) {
    guard let status = notification.userInfo?["permissionStatus"] as? NetworkPermissionStatus else {
        return
    }
    
    if status == .denied {
        // 显示无网络权限提示
        showNetworkPermissionAlert()
    }
}

// 显示网络权限提示
func showNetworkPermissionAlert() {
    let alert = UIAlertController(
        title: "网络访问受限",
        message: "请前往设置 > 蜂窝网络，允许本应用使用网络",
        preferredStyle: .alert
    )
    
    alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
    alert.addAction(UIAlertAction(title: "前往设置", style: .default) { _ in
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    })
    
    // 显示提示
    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
}

// 使用网络监控信息
func checkNetworkStatus() {
    // 先检查网络权限
    if NetworkMonitor.shared.permissionStatus == .denied {
        print("无网络权限，请在设置中允许应用使用网络")
        showNetworkPermissionAlert()
        return
    }
    
    // 再检查网络连接状态
    if NetworkMonitor.shared.isConnected {
        print("网络已连接")
        
        // 执行网络请求
        NetworkService.shared.request(UserAPIService.getProfile) { (result: Result<BaseResponse<User>, Error>) in
            // 处理结果
        }
    } else {
        print("网络未连接，无法执行请求")
        // 显示离线提示
    }
}
*/ 
