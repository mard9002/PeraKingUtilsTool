import Foundation
import SwiftUI

/// 设备信息使用示例
struct DeviceInfoExample {
    
    /// 打印所有设备信息到控制台
    static func printAllDeviceInfo() {
        let deviceInfo = DeviceInfoManager.shared
        let allInfo = deviceInfo.getAllDeviceInfo()
        
        print("========== 设备信息 ==========")
        for (key, value) in allInfo {
            print("\(key): \(value)")
        }
        print("=============================")
    }
    
    /// 获取设备信息的JSON字符串
    static func getDeviceInfoJSON() -> String? {
        let deviceInfo = DeviceInfoManager.shared
        let allInfo = deviceInfo.getAllDeviceInfo()
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: allInfo, options: .prettyPrinted) else {
            return nil
        }
        
        return String(data: jsonData, encoding: .utf8)
    }
    
    /// 创建设备信息的视图
    static func createDeviceInfoView() -> some View {
        let deviceInfo = DeviceInfoManager.shared
        
        return DeviceInfoView(deviceInfo: deviceInfo)
    }
}

/// 设备信息显示视图
struct DeviceInfoView: View {
    let deviceInfo: DeviceInfoManager
    
    var body: some View {
        List {
            Section(header: Text("设备基础信息")) {
                infoRow(title: "设备名称", value: deviceInfo.deviceName)
                infoRow(title: "设备ID", value: deviceInfo.idfv)
                infoRow(title: "设备型号", value: deviceInfo.deviceModelIdentifier)
                infoRow(title: "屏幕尺寸", value: deviceInfo.screenSize)
                infoRow(title: "是否为手机", value: deviceInfo.isPhone == 1 ? "是" : "否")
            }
            
            Section(header: Text("系统信息")) {
                infoRow(title: "系统版本", value: deviceInfo.systemVersion)
                infoRow(title: "是否模拟器", value: deviceInfo.isSimulator == 1 ? "是" : "否")
                infoRow(title: "是否越狱", value: deviceInfo.isJailbroken == 1 ? "是" : "否")
            }
            
            Section(header: Text("存储和内存")) {
                infoRow(title: "总存储", value: formatBytes(deviceInfo.totalStorageSize))
                infoRow(title: "可用存储", value: formatBytes(deviceInfo.availableStorageSize))
                infoRow(title: "总内存", value: formatBytes(deviceInfo.totalMemorySize))
                infoRow(title: "可用内存", value: formatBytes(deviceInfo.availableMemorySize))
            }
            
            Section(header: Text("网络信息")) {
                infoRow(title: "网络类型", value: deviceInfo.networkType)
                infoRow(title: "运营商", value: deviceInfo.carrierName)
                infoRow(title: "IP地址", value: deviceInfo.ipAddress)
                infoRow(title: "使用代理", value: deviceInfo.isUsingProxy == 1 ? "是" : "否")
                infoRow(title: "使用VPN", value: deviceInfo.isUsingVPN == 1 ? "是" : "否")
                infoRow(title: "WiFi SSID", value: deviceInfo.wifiSSID)
                infoRow(title: "WiFi BSSID", value: deviceInfo.wifiBSSID)
            }
            
            Section(header: Text("区域和语言")) {
                infoRow(title: "时区", value: deviceInfo.timeZoneID)
                infoRow(title: "语言", value: deviceInfo.deviceLanguage)
            }
            
            Section(header: Text("电池信息")) {
                infoRow(title: "电量百分比", value: "\(Int(deviceInfo.batteryPercentage))%")
                infoRow(title: "正在充电", value: deviceInfo.isCharging == 1 ? "是" : "否")
            }
            
            Section(header: Text("广告标识")) {
                infoRow(title: "IDFA", value: deviceInfo.idfa)
            }
        }
        .navigationTitle("设备信息")
    }
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
} 