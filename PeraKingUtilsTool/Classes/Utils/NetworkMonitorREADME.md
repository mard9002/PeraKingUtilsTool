# NetworkMonitor 网络监控工具

`NetworkMonitor` 是一个轻量级、高效的网络状态监控工具，用于iOS应用程序监控网络连接状态、类型以及网络权限变化。

## 功能特点

- 监控网络连接状态（是否已连接）
- 识别网络连接类型（WiFi、蜂窝数据、以太网等）
- 监控网络权限状态变化
- 提供回调和通知两种方式接收状态变化
- 支持网络权限检查与提示
- 自动在应用前后台切换时更新权限状态
- 定期检查确保权限状态准确

## 使用方法

### 1. 启动和停止网络监控

在 `AppDelegate` 的 `didFinishLaunchingWithOptions` 方法中启动网络监控：

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // 启动网络监控
    NetworkMonitor.shared.startMonitoring()
    setupNetworkMonitorCallbacks()
    
    return true
}

// 在合适的地方停止监控
deinit {
    NetworkMonitor.shared.stopMonitoring()
    NotificationCenter.default.removeObserver(self)
}
```

### 2. 设置网络监控回调

```swift
private func setupNetworkMonitorCallbacks() {
    // 设置网络状态变化回调
    NetworkMonitor.shared.statusChangeHandler = { isConnected, connectionType in
        if isConnected {
            print("网络已连接，类型: \(connectionType)")
            // 执行网络连接后的操作
        } else {
            print("网络已断开")
            // 执行网络断开后的操作
        }
    }
    
    // 设置权限变化回调
    NetworkMonitor.shared.permissionChangeHandler = { status in
        switch status {
        case .authorized:
            print("网络权限已授权")
        case .denied:
            print("网络权限被拒绝")
            // 显示权限设置引导
            self.showNetworkPermissionAlert()
        case .restricted:
            print("网络权限受限")
        case .unknown:
            print("网络权限状态未知")
        }
    }
}
```

### 3. 使用通知方式接收状态变化

除了回调方式外，还可以使用通知方式接收状态变化：

```swift
// 注册通知
NotificationCenter.default.addObserver(
    self,
    selector: #selector(networkStatusChanged),
    name: NetworkMonitor.Notifications.networkStatusChanged,
    object: nil
)

NotificationCenter.default.addObserver(
    self,
    selector: #selector(networkPermissionChanged),
    name: NetworkMonitor.Notifications.networkPermissionChanged,
    object: nil
)

// 处理网络状态变化通知
@objc private func networkStatusChanged(_ notification: Notification) {
    guard let isConnected = notification.userInfo?["isConnected"] as? Bool,
          let connectionType = notification.userInfo?["connectionType"] as? ConnectionType else {
        return
    }
    
    // 处理网络状态变化
}

// 处理网络权限变化通知
@objc private func networkPermissionChanged(_ notification: Notification) {
    guard let status = notification.userInfo?["permissionStatus"] as? NetworkPermissionStatus else {
        return
    }
    
    // 处理权限变化
}
```

### 4. 检查当前网络状态

可以随时检查当前网络状态和连接类型：

```swift
// 检查网络连接状态
if NetworkMonitor.shared.isConnected {
    // 网络已连接
    let connectionType = NetworkMonitor.shared.connectionType
    // 根据连接类型执行不同操作
} else {
    // 网络未连接
}

// 检查网络权限状态
let permissionStatus = NetworkMonitor.shared.permissionStatus
if permissionStatus == .denied {
    // 引导用户设置网络权限
}
```

### 5. 手动刷新权限状态

在某些情况下，可能需要手动刷新权限状态：

```swift
// 主动刷新权限状态（例如用户从设置页面返回后）
NetworkMonitor.shared.refreshPermissionStatus()
```

### 6. 在视图控制器中使用

在视图控制器中使用 NetworkMonitor 的示例：

```swift
class NetworkAwareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 检查当前网络状态
        updateUIBasedOnNetworkStatus()
        
        // 注册网络状态变化通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged),
            name: NetworkMonitor.Notifications.networkStatusChanged,
            object: nil
        )
    }
    
    private func updateUIBasedOnNetworkStatus() {
        if NetworkMonitor.shared.isConnected {
            // 网络连接 - 更新UI
            networkStatusLabel.text = "网络已连接: \(NetworkMonitor.shared.connectionDescription)"
            fetchDataButton.isEnabled = true
        } else {
            // 无网络 - 更新UI
            networkStatusLabel.text = "网络未连接"
            fetchDataButton.isEnabled = false
        }
    }
    
    @objc private func networkStatusChanged(_ notification: Notification) {
        // 在主线程更新UI
        DispatchQueue.main.async {
            self.updateUIBasedOnNetworkStatus()
        }
    }
    
    deinit {
        // 移除通知观察者
        NotificationCenter.default.removeObserver(self)
    }
}
```

## 网络权限监控与处理

### 权限状态定义

```swift
public enum NetworkPermissionStatus {
    case authorized    // 已授权
    case denied        // 被拒绝
    case restricted    // 受限制
    case unknown       // 未知状态
}
```

### 处理权限变化

当网络权限状态发生变化时，可能需要向用户显示提示并引导用户更改设置：

```swift
private func showNetworkPermissionAlert() {
    let alert = UIAlertController(
        title: "网络访问受限",
        message: "请前往设置 > 蜂窝网络，允许本应用使用网络",
        preferredStyle: .alert
    )
    
    alert.addAction(UIAlertAction(title: "取消", style: .cancel))
    alert.addAction(UIAlertAction(title: "前往设置", style: .default) { _ in
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    })
    
    present(alert, animated: true)
}
```

### 权限变化检测机制

`NetworkMonitor` 通过多种机制确保能及时检测到权限变化：

1. **应用启动时检查**：在应用启动时进行初始化检查
2. **定期自动检查**：每30秒自动检查一次权限状态
3. **网络状态变化时检查**：当网络连接状态发生变化时检查权限
4. **应用状态变化时检查**：当应用进入前台或回到活跃状态时检查权限
5. **手动触发检查**：可以在特定场景下主动触发权限检查

## 常见问题排查

### 问题1：权限变化回调不触发

如果权限变化回调没有触发，可以尝试以下解决方案：

1. **确保回调设置正确**：检查 `permissionChangeHandler` 是否正确设置，并且没有循环引用问题
2. **检查前后台切换**：确保在应用从后台切换到前台时主动刷新权限状态
3. **主动触发权限检查**：在适当的时机（如视图出现时）主动调用 `refreshPermissionStatus()`
4. **检查通知注册**：如果使用通知方式，确保正确注册了 `networkPermissionChanged` 通知

示例修复代码：
```swift
// 在应用回到前台时主动刷新
@objc private func applicationDidBecomeActive() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        NetworkMonitor.shared.refreshPermissionStatus()
    }
}
```

### 问题2：权限状态不准确

如果权限状态显示不准确，可以尝试：

1. **延迟检查**：由于系统可能需要时间更新权限状态，可以在关键节点设置延迟检查
2. **连续多次检查**：在重要操作前连续检查多次权限状态
3. **优化判断逻辑**：综合网络连接状态和权限状态进行判断

```swift
// 连续多次检查
func ensurePermissionStatusAccurate(completion: @escaping (NetworkPermissionStatus) -> Void) {
    // 第一次检查
    NetworkMonitor.shared.refreshPermissionStatus()
    
    // 1秒后再次检查
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        NetworkMonitor.shared.refreshPermissionStatus()
        
        // 再次延迟获取最终状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(NetworkMonitor.shared.permissionStatus)
        }
    }
}
```

### 问题3：首次启动权限判断错误

首次启动应用时，权限状态可能不准确，可以采取以下措施：

1. **延迟初始化**：在应用启动后延迟几秒再开始关键网络操作
2. **渐进式功能**：先显示不需要网络的功能，等确认权限后再加载需要网络的功能
3. **多重确认**：结合用户操作和网络探测共同判断权限状态

## 注意事项

1. 权限变化检测基于 `CTCellularData`，主要针对蜂窝数据权限，WiFi权限变化可能监测不完全。
2. 在UI相关代码中，确保所有UI更新都在主线程执行。
3. 在使用回调时，要注意避免循环引用问题，始终使用 `[weak self]`。
4. 网络状态变化可能会频繁触发，避免在回调中执行重量级操作。
5. iOS 13+ 上可以使用额外功能，如检查低数据模式和网络受限状态。
6. 在删除观察者时，确保移除所有已注册的通知观察者，避免内存泄漏。

## 兼容性

- 基本功能支持 iOS 12.0+
- 扩展功能（如 `connectionDescription` 等）仅支持 iOS 13.0+
- 使用 `Network` 和 `CoreTelephony` 框架 