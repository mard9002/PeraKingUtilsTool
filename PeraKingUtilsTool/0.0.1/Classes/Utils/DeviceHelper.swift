import UIKit

/// 设备辅助类 - 提供设备信息和环境判断
@objc public final class DeviceHelper: NSObject {
    
    /// 设备类型枚举
    public enum DeviceType {
        case iPhone
        case iPad
        case iPod
        case simulator
        case unknown
    }
    
    /// 获取当前设备类型
    public static var deviceType: DeviceType {
        let device = UIDevice.current
        
        switch device.model {
        case let name where name.contains("iPhone"):
            return .iPhone
        case let name where name.contains("iPad"):
            return .iPad
        case let name where name.contains("iPod"):
            return .iPod
        case let name where name.contains("Simulator"):
            return .simulator
        default:
            return .unknown
        }
    }
    
    /// 获取iOS版本号
    public static var iOSVersion: String {
        return UIDevice.current.systemVersion
    }
    
    /// 获取App版本号
    public static var appVersion: String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "Unknown"
        }
        return version
    }
    
    /// 获取App构建版本号
    public static var buildVersion: String {
        guard let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
            return "Unknown"
        }
        return build
    }
    
    /// 获取设备唯一标识符
    public static var deviceID: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
    }
    
    /// 判断是否是模拟器
    public static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    /// 判断是否是调试模式
    public static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    /// 获取设备屏幕尺寸
    public static var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }
    
    /// 判断是否为刘海屏设备
    public static var hasNotch: Bool {
        guard #available(iOS 11.0, *), let window = UIApplication.shared.windows.first else {
            return false
        }
        return window.safeAreaInsets.bottom > 0
    }
    
    /// 获取设备安全区域
    @available(iOS 11.0, *)
    public static var safeAreaInsets: UIEdgeInsets {
        guard let window = UIApplication.shared.windows.first else {
            return .zero
        }
        return window.safeAreaInsets
    }
    
    /// 获取顶部状态栏高度
    public static var statusBarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }
    
    /// 判断设备是否为iPad
    public static var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    /// 判断设备是否为iPhone
    public static var isPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    /// 判断设备是横屏还是竖屏
    public static var isLandscape: Bool {
        return UIDevice.current.orientation.isLandscape
    }
    
    /// 判断设备是否为深色模式
    @available(iOS 13.0, *)
    public static var isDarkMode: Bool {
        return UITraitCollection.current.userInterfaceStyle == .dark
    }
    
    /// 获取当前设备电池电量
    public static var batteryLevel: Float {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return UIDevice.current.batteryLevel
    }
    
    /// 获取电池状态
    public static var batteryState: UIDevice.BatteryState {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return UIDevice.current.batteryState
    }
    
    /// 获取设备磁盘空间信息
    public static func diskSpace() -> (total: Int, used: Int, free: Int)? {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey])
            if let total = values.volumeTotalCapacity, let free = values.volumeAvailableCapacity {
                return (total, total - free, free)
            }
        } catch {
            print("获取磁盘空间出错: \(error.localizedDescription)")
        }
        return nil
    }
    
    /// 获取设备内存信息
    public static func memoryInfo() -> (total: UInt64, used: UInt64)? {
        let processInfo = ProcessInfo.processInfo
        let totalMemory = processInfo.physicalMemory
        
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let kerr = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return (totalMemory, UInt64(info.resident_size))
        }
        
        return nil
    }
    
    /// 检查相机权限
    public static func cameraAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    /// 检查位置权限
    public static func locationAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            completion(true)
        case .notDetermined:
            let locationManager = CLLocationManager()
            locationManager.requestWhenInUseAuthorization()
            completion(false)
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    @objc public static func locationAuthorizationStatus() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        case .notDetermined:
            let locationManager = CLLocationManager()
            locationManager.requestWhenInUseAuthorization()
            return false
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
    /// 打开应用设置页面
    public static func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

// MARK: - 必要的导入
import LocalAuthentication
import Photos
import CoreLocation 
