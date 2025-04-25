import Foundation
import UIKit
import MachO
import SystemConfiguration
import CoreTelephony
import AdSupport
import Security
import NetworkExtension
import SystemConfiguration.CaptiveNetwork

/// 设备信息管理工具类
public final class DeviceInfoManager: NSObject {
    
    // MARK: - 单例
    public static let shared = DeviceInfoManager()
    
    // MARK: - 常量
    private struct Constants {
        static let idfvKeychainKey = "com.anytime.deviceId"
        static let serviceKey = "com.anytime.deviceinfo"
    }
    
    // MARK: - 属性
    private let device = UIDevice.current
    private let screen = UIScreen.main
    private let bundle = Bundle.main
    private let fileManager = FileManager.default
    private let locale = Locale.current
    private let timeZone = TimeZone.current
    private let networkMonitor = NetworkMonitor.shared
    
    // MARK: - 初始化
    private override init() {}
    
    // MARK: - 公共方法
    
    public var modelCode: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String(validatingUTF8: ptr)
            }
        } ?? ""
        
        return modelCode
    }
    
    /// 1. 获取设备名称（iPhone 11, iPhone 12 Pro Max等）
    public var deviceName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String(validatingUTF8: ptr)
            }
        } ?? ""
        
        return mapToDeviceName(identifier: modelCode)
    }
    
    /// 2. 获取IDFV (从钥匙串获取或生成保存)
    public var idfv: String {
        // 先尝试从钥匙串获取
        if let savedIDFV = getIDFVFromKeychain() {
            return savedIDFV
        }
        
        // 如果钥匙串没有，生成并保存
        let newIDFV = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        saveIDFVToKeychain(newIDFV)
        return newIDFV
    }
    
    /// 3. 设备OS版本 (如 15.0)
    public var osVersion: String {
        return device.systemVersion
    }
    
    /// 4. 可用存储大小 (单位：byte)
    public var availableStorageSize: Int64 {
        do {
            let attributes = try fileManager.attributesOfFileSystem(forPath: NSHomeDirectory())
            if let freeSize = attributes[.systemFreeSize] as? Int64 {
                return freeSize
            }
        } catch {}
        return 0
    }
    
    /// 5. 总存储大小 (单位：byte)
    public var totalStorageSize: Int64 {
        do {
            let attributes = try fileManager.attributesOfFileSystem(forPath: NSHomeDirectory())
            if let totalSize = attributes[.systemSize] as? Int64 {
                return totalSize
            }
        } catch {}
        return 0
    }
    
    /// 6. 内存大小 (单位：byte)
    public var totalMemorySize: Int64 {
        return Int64(ProcessInfo.processInfo.physicalMemory)
    }
    
    /// 7. 可用内存大小 (单位：byte)
    public var availableMemorySize: Int64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let availableMemory = totalMemorySize - Int64(info.resident_size)
            return max(0, availableMemory)
        }
        return 0
    }
    
    /// 8. 电池百分比
    public var batteryPercentage: Float {
        device.isBatteryMonitoringEnabled = true
        let percentage = device.batteryLevel
        return percentage * 100
    }
    
    /// 9. 是否正在充电 (1: 是, 0: 否)
    public var isCharging: Int {
        device.isBatteryMonitoringEnabled = true
        return device.batteryState == .charging || device.batteryState == .full ? 1 : 0
    }
    
    /// 10. 系统版本
    public var systemVersion: String {
        return device.systemVersion
    }
    
    /// 11. iPhone原始设备型号代码
    public var deviceModelIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String(validatingUTF8: ptr)
            }
        } ?? ""
        
        return modelCode
    }
    
    /// 12. 手机物理尺寸
    public var screenSize: String {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        return "\(screenWidth)x\(screenHeight)"
    }
    
    /// 13. 是否是模拟器 (1: 是, 0: 否)
    public var isSimulator: Int {
        #if targetEnvironment(simulator)
            return 1
        #else
            return 0
        #endif
    }
    
    /// 14. 是否越狱 (1: 是, 0: 否)
    public var isJailbroken: Int {
        // 检查常见的越狱应用路径
        let jailbreakPaths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/"
        ]
        
        for path in jailbreakPaths {
            if fileManager.fileExists(atPath: path) {
                return 1
            }
        }
        
        // 尝试写入受限目录
        do {
            let restrictedPath = "/private/jailbreak_test"
            try "test".write(toFile: restrictedPath, atomically: true, encoding: .utf8)
            try fileManager.removeItem(atPath: restrictedPath)
            return 1
        } catch {
            // 不能写入表示没有越狱
        }
        
        return 0
    }
    
    /// 15. 时区ID
    public var timeZoneID: String {
        return timeZone.identifier
    }
    
    /// 16. 是否使用代理 (1: 是, 0: 否)
    public var isUsingProxy: Int {
        let proxySettings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as NSDictionary?
        if let settings = proxySettings {
            if let HTTPProxy = settings["HTTPProxy"] as? String, !HTTPProxy.isEmpty {
                return 1
            } else if let HTTPSProxy = settings["HTTPSProxy"] as? String, !HTTPSProxy.isEmpty {
                return 1
            } else if let SOCKSProxy = settings["SOCKSProxy"] as? String, !SOCKSProxy.isEmpty {
                return 1
            }
        }
        return 0
    }
    
    /// 17. 是否使用VPN (1: 是, 0: 否)
    public var isUsingVPN: Int {
        guard let cfDict = CFNetworkCopySystemProxySettings()?.takeRetainedValue() else { return 0 }
        
        let nsDict = cfDict as NSDictionary
        guard let interfaces = nsDict["__SCOPED__"] as? NSDictionary else { return 0 }
        
        for key in interfaces.allKeys {
            guard let interface = key as? String else { continue }
            
            if interface.contains("tap") || interface.contains("tun") || interface.contains("ppp") || interface.contains("ipsec") {
                return 1
            }
        }
        
        return 0
    }
    
    /// 18. 网络运营商名称
    public var carrierName: String {
        let networkInfo = CTTelephonyNetworkInfo()
        if #available(iOS 12.0, *) {
            if let carriers = networkInfo.serviceSubscriberCellularProviders, let carrier = carriers.values.first {
                return carrier.carrierName ?? "Unknown"
            }
        } else {
            if let carrier = networkInfo.subscriberCellularProvider {
                return carrier.carrierName ?? "Unknown"
            }
        }
        return "Unknown"
    }
    
    /// 19. 设备语言
    public var deviceLanguage: String {
        return Locale.preferredLanguages.first ?? "en"
    }
    
    /// 20. 网络类型
    public var networkType: String {
        let connectionType = networkMonitor.connectionType
        if !networkMonitor.isConnected {
            return "Bad Network"
        }
        
        switch connectionType {
        case .wifi:
            return "WIFI"
        case .cellular:
            return "4G"
        default:
            return "Unknown Network"
        }
    }
    
    /// 21. 是否是手机 (1: 是, 0: 否)
    public var isPhone: Int {
        return device.userInterfaceIdiom == .phone ? 1 : 0
    }
    
    /// 22. IP地址
    public var ipAddress: String {
        var address: String = "Unknown"
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                guard let interface = ptr?.pointee else { continue }
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    let name = String(cString: interface.ifa_name)
                    if name == "en0" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                    &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                        break
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        
        return address
    }
    
    /// 23. 设备MAC (WiFi BSSID)
    public var macAddress: String {
        return wifiBSSID
    }
    
    /// 24. IDFA
    public var idfa: String {
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }
        return "00000000-0000-0000-0000-000000000000"
    }
    
    /// 25. 当前WiFi BSSID
    public var wifiBSSID: String {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else { return "Unknown" }
        
        for interface in interfaces {
            if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any],
               let bssid = interfaceInfo["BSSID"] as? String {
                return bssid
            }
        }
        
        return "Unknown"
    }
    
    /// 26. 当前WiFi SSID
    public var wifiSSID: String {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else { return "Unknown" }
        
        for interface in interfaces {
            if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any],
               let ssid = interfaceInfo["SSID"] as? String {
                return ssid
            }
        }
        
        return "Unknown"
    }
    
    // MARK: - 辅助方法
    
    /// 将设备标识符映射到设备名称
    private func mapToDeviceName(identifier: String) -> String {
        #if os(iOS)
        switch identifier {
        case "iPhone1,1": return "iPhone"
        case "iPhone1,2": return "iPhone 3G"
        case "iPhone2,1": return "iPhone 3GS"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3": return "iPhone 4"
        case "iPhone4,1": return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2": return "iPhone 5"
        case "iPhone5,3", "iPhone5,4": return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2": return "iPhone 5s"
        case "iPhone7,2": return "iPhone 6"
        case "iPhone7,1": return "iPhone 6 Plus"
        case "iPhone8,1": return "iPhone 6s"
        case "iPhone8,2": return "iPhone 6s Plus"
        case "iPhone8,4": return "iPhone SE (1st generation)"
        case "iPhone9,1", "iPhone9,3": return "iPhone 7"
        case "iPhone9,2", "iPhone9,4": return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4": return "iPhone 8"
        case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6": return "iPhone X"
        case "iPhone11,2": return "iPhone XS"
        case "iPhone11,4", "iPhone11,6": return "iPhone XS Max"
        case "iPhone11,8": return "iPhone XR"
        case "iPhone12,1": return "iPhone 11"
        case "iPhone12,3": return "iPhone 11 Pro"
        case "iPhone12,5": return "iPhone 11 Pro Max"
        case "iPhone12,8": return "iPhone SE (2nd generation)"
        case "iPhone13,1": return "iPhone 12 mini"
        case "iPhone13,2": return "iPhone 12"
        case "iPhone13,3": return "iPhone 12 Pro"
        case "iPhone13,4": return "iPhone 12 Pro Max"
        case "iPhone14,2": return "iPhone 13 Pro"
        case "iPhone14,3": return "iPhone 13 Pro Max"
        case "iPhone14,4": return "iPhone 13 mini"
        case "iPhone14,5": return "iPhone 13"
        case "iPhone14,6": return "iPhone SE"
        case "iPhone14,7": return "iPhone 14"
        case "iPhone14,8": return "iPhone 14 Plus"
        case "iPhone15,2": return "iPhone 14 Pro"
        case "iPhone15,3": return "iPhone 14 Pro Max"
        case "iPhone15,4": return "iPhone 15"
        case "iPhone15,5": return "iPhone 15 Plus"
        case "iPhone16,1": return "iPhone 15 Pro"
        case "iPhone16,2": return "iPhone 15 Pro Max"
            
        case "iPad1,1": return "iPad"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3": return "iPad"
        case "iPad3,4", "iPad3,5", "iPad3,6": return "iPad (4th generation)"
        case "iPad4,1", "iPad4,2", "iPad4,3": return "iPad Air"
        case "iPad5,3", "iPad5,4": return "iPad Air 2"
        case "iPad6,11", "iPad6,12": return "iPad (5th generation)"
        case "iPad7,5", "iPad7,6": return "iPad (6th generation)"
        case "iPad7,11", "iPad7,12": return "iPad (7th generation)"
        case "iPad11,6", "iPad11,7": return "iPad (8th generation)"
        case "iPad12,1", "iPad12,2": return "iPad (9th generation)"
        case "iPad13,18", "iPad13,19": return "iPad (10th generation)"
        case "iPad11,3", "iPad11,4": return "iPad Air"
        case "iPad13,1", "iPad13,2": return "iPad Air (4th generation)"
        case "iPad13,16", "iPad13,17": return "iPad Air (5th generation)"
        case "iPad2,5", "iPad2,6", "iPad2,7": return "iPad mini"
        case "iPad4,4", "iPad4,5", "iPad4,6": return "iPad mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9": return "iPad mini 3"
        case "iPad5,1", "iPad5,2": return "iPad mini 4"
        case "iPad11,1", "iPad11,2": return "iPad mini (5th generation)"
        case "iPad14,1", "iPad14,2": return "iPad mini (6th generation)"
        case "iPad6,3", "iPad6,4": return "iPad Pro (9.7-inch)"
        case "iPad7,1", "iPad7,2": return "iPad Pro (12.9-inch) (2nd generation)"
        case "iPad7,3", "iPad7,4": return "iPad Pro (10.5-inch)"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": return "iPad Pro (11-inch) (1st generation)"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8": return "iPad Pro"
        case "iPad8,9", "iPad8,10": return "iPad Pro (11-inch) (2nd generation)"
        case "iPad8,11", "iPad8,12": return "iPad Pro (12.9-inch) (4th generation)"
        case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7": return "iPad Pro"
        case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11": return "iPad Pro (12.9-inch) (5th generation)"
        case "iPad14,3", "iPad14,4": return "iPad Pro (11-inch) (4th generation)"
        case "iPad14,5", "iPad14,6": return "iPad Pro (12.9-inch) (6th generation)"
            
        case "iPod1,1": return "iPod touch"
        case "iPod2,1": return "iPod touch (2nd generation)"
        case "iPod3,1": return "iPod touch"
        case "iPod4,1": return "iPod touch (4th generation)"
        case "iPod5,1": return "iPod touch (5th generation)"
        case "iPod7,1": return "iPod touch (6th generation)"
        case "iPod9,1": return "iPod touch (7th generation)"
            
        case "i386", "x86_64", "arm64": return "Simulator \(mapToDeviceName(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
        default: return identifier
        }
        #else
        return identifier
        #endif
    }
    
    /// 从钥匙串获取IDFV
    private func getIDFVFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Constants.serviceKey,
            kSecAttrAccount as String: Constants.idfvKeychainKey,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess, let data = item as? Data, let string = String(data: data, encoding: .utf8) {
            return string
        }
        
        return nil
    }
    
    /// 保存IDFV到钥匙串
    private func saveIDFVToKeychain(_ value: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Constants.serviceKey,
            kSecAttrAccount as String: Constants.idfvKeychainKey,
            kSecValueData as String: data
        ]
        
        // 尝试添加，如果已存在则更新
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem {
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: Constants.serviceKey,
                kSecAttrAccount as String: Constants.idfvKeychainKey
            ]
            
            let attributesToUpdate: [String: Any] = [
                kSecValueData as String: data
            ]
            
            SecItemUpdate(updateQuery as CFDictionary, attributesToUpdate as CFDictionary)
        }
    }
    
    /// 获取设备完整信息字典
    public func getAllDeviceInfo() -> [String: Any] {
        return [
            "deviceName": deviceName,
            "idfv": idfv,
            "osVersion": osVersion,
            "availableStorageSize": availableStorageSize,
            "totalStorageSize": totalStorageSize,
            "totalMemorySize": totalMemorySize,
            "availableMemorySize": availableMemorySize,
            "batteryPercentage": batteryPercentage,
            "isCharging": isCharging,
            "systemVersion": systemVersion,
            "deviceModelIdentifier": deviceModelIdentifier,
            "screenSize": screenSize,
            "isSimulator": isSimulator,
            "isJailbroken": isJailbroken,
            "timeZoneID": timeZoneID,
            "isUsingProxy": isUsingProxy,
            "isUsingVPN": isUsingVPN,
            "carrierName": carrierName,
            "deviceLanguage": deviceLanguage,
            "networkType": networkType,
            "isPhone": isPhone,
            "ipAddress": ipAddress,
            "macAddress": macAddress,
            "idfa": idfa,
            "wifiBSSID": wifiBSSID,
            "wifiSSID": wifiSSID
        ]
    }
    
    public func getSystemUptimeInMilliseconds() -> UInt64 {
        // 获取设备的启动时间（纳秒）
        var baseInfo = mach_timebase_info_data_t()
        mach_timebase_info(&baseInfo)
        
        let timeInNanoseconds = mach_absolute_time() * UInt64(baseInfo.numer) / UInt64(baseInfo.denom)
        
        // 将纳秒转换为毫秒
        return timeInNanoseconds / 1_000_000
    }

    public func getDevicePhysicalSize() -> String? {
        // 获取主屏幕的尺寸
        let screenBounds = UIScreen.main.bounds
        let screenWidth = screenBounds.width
        let screenHeight = screenBounds.height
        // 计算屏幕的对角线长度（像素）
        let widthInPixels = screenWidth * UIScreen.main.scale
        let heightInPixels = screenHeight * UIScreen.main.scale
        let diagonalInPixels = sqrt(widthInPixels * widthInPixels + heightInPixels * heightInPixels)
        // 将像素转换为英寸
        let diagonalInInches = diagonalInPixels / UIScreen.main.nativeScale
        // 返回物理尺寸
        return String(format: "%.1f 英寸", diagonalInInches)
    }

}
