import Foundation

/// 网络参数提供器
/// 用于整合设备信息和位置信息，提供给网络请求使用
public class NetworkParameterProvider {
    
    // MARK: - 单例
    public static let shared = NetworkParameterProvider()
    
    // MARK: - 私有属性
    private let deviceInfo = DeviceInfoManager.shared
    private let locationManager = LocationManager.shared
    
    // MARK: - 初始化
    private init() {}
    
    // MARK: - 公共方法
    
    /// 基础参数（无位置信息）
    public func getBaseParameters() -> [String: Any] {
        var params: [String: Any] = [:]
        
        // 设备标识信息
        params["device_id"] = deviceInfo.idfv
        params["device_name"] = deviceInfo.deviceName
        params["device_model"] = deviceInfo.deviceModelIdentifier
        
        // 系统信息
        params["os_version"] = deviceInfo.osVersion
        params["platform"] = "iOS"
        
        // 应用信息
        params["app_version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        params["app_build"] = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        
        // 网络信息
        params["network_type"] = deviceInfo.networkType
        params["carrier"] = deviceInfo.carrierName
        
        // 时间戳
        params["timestamp"] = Int(Date().timeIntervalSince1970)
        
        return params
    }
    
    /// 获取包含当前缓存位置的参数（立即返回）
    public func getParametersWithCachedLocation() -> [String: Any] {
        var params = getBaseParameters()
        
        // 添加缓存的位置信息
        let cachedLocation = locationManager.getLastLocationString()
        if !cachedLocation.latitude.isEmpty && !cachedLocation.longitude.isEmpty {
            params["latitude"] = cachedLocation.latitude
            params["longitude"] = cachedLocation.longitude
        }
        
        return params
    }
    
    /// 获取包含实时位置的参数（通过回调返回）
    public func getParametersWithLocation(timeout: TimeInterval = 5.0, completion: @escaping ([String: Any]) -> Void) {
        // 先获取基础参数
        var params = getBaseParameters()
        
        // 请求位置并添加到参数中
        locationManager.getCurrentLocation(timeout: timeout) { latitude, longitude in
            if !latitude.isEmpty && !longitude.isEmpty {
                params["latitude"] = latitude
                params["longitude"] = longitude
            }
            
            // 回调最终参数
            completion(params)
        }
    }
    
    /// 获取包含详细地址信息的参数（通过回调返回）
    public func getParametersWithAddressDetail(timeout: TimeInterval = 5.0, completion: @escaping ([String: Any]) -> Void) {
        // 先获取基础参数
        var params = getBaseParameters()
        
        // 请求详细地址信息并添加到参数中
        locationManager.getAddressDetail(timeout: timeout) { addressDetail in
            // 添加所有地址信息到参数中
            for (key, value) in addressDetail.dictionary {
                if !value.isEmpty {
                    params[key] = value
                }
            }
            
            // 回调最终参数
            completion(params)
        }
    }
    
    /// 获取动态参数提供器（适用于NetworkParameterPlugin）
    public func getDynamicParametersProvider() -> (() -> [String: Any]) {
        return { [weak self] in
            guard let self = self else { return [:] }
            
            var params: [String: Any] = [
                "timestamp": Int(Date().timeIntervalSince1970) // 确保时间戳是最新的
            ]
            
            // 获取最新的网络状态
            params["network_type"] = self.deviceInfo.networkType
            
            // 添加缓存的详细地址信息
            let cachedAddress = self.locationManager.getCachedAddressDetail()
            
            // 添加地址信息
            for (key, value) in cachedAddress.dictionary {
                if !value.isEmpty {
                    params[key] = value
                }
            }
            
            return params
        }
    }
    
    /// 创建并配置位置感知的参数插件
    public func createLocationAwarePlugin() -> NetworkParameterPlugin {
        // 基础参数(相对静态的设备信息)
        let baseParams: [String: Any] = [
            "device_id": deviceInfo.idfv,
            "device_name": deviceInfo.deviceName,
            "device_model": deviceInfo.deviceModelIdentifier,
            "os_version": deviceInfo.osVersion,
            "platform": "iOS",
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            "app_build": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        ]
        
        // 创建插件，使用动态参数提供器
        return NetworkParameterPlugin(
            parameters: baseParams,
            dynamicParametersProvider: getDynamicParametersProvider()
        )
    }
} 