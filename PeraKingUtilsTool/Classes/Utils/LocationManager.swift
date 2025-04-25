import Foundation
import CoreLocation
import UIKit

/// 定位管理工具类
public final class LocationManager: NSObject {
    
    // MARK: - 公共类型
    
    /// 定位结果回调类型
    public typealias LocationCallback = ((_ latitude: String, _ longitude: String) -> Void)
    
    /// 定位请求状态
    private enum RequestState {
        case waiting    // 等待定位结果
        case completed  // 已完成
        case timeout    // 超时
    }
    
    /// 定位请求
    private class LocationRequest: NSObject, CLLocationManagerDelegate {
        let id: UUID = UUID()
        var callback: LocationCallback?
        let timeoutInterval: TimeInterval
        let createTime: Date = Date()
        var timer: Timer?
        var state: RequestState = .waiting
        
        private let lastLocationLatitudeKey = "com.anytime.location.latitude"
        private let lastLocationLongitudeKey = "com.anytime.location.longitude"
        
        private let locationManager = CLLocationManager()
        private let userDefaults = UserDefaults.standard
        
        init(callback: @escaping LocationCallback, timeoutInterval: TimeInterval) {
            self.callback = callback
            self.timeoutInterval = timeoutInterval
            super.init()
            self.setupLocationManager()
            self.startLocationUpdates()
        }
        /// 设置位置管理器
        private func setupLocationManager() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 10 // 10米
        }
        
        /// 开始定位
        private func startLocationUpdates() {
            DispatchQueue.main.async {
                // 检查定位权限
                let authStatus = CLLocationManager.authorizationStatus()
                
                if authStatus == .notDetermined {
                    self.locationManager.requestWhenInUseAuthorization()
                } else if authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways {
                    self.locationManager.requestLocation()
                } else {
                    // 如果没有权限，处理所有待处理的请求
                    let result = self.getLocationFromCache()
                    self.callback?(result?.latitude ?? "", result?.longitude ?? "")
                    self.timer?.invalidate()
                }
            }
            
        }
        
        // 位置更新回调
        public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last, location.horizontalAccuracy >= 0 else { return }
            self.locationManager.stopUpdatingLocation()
            callback?(String(location.coordinate.latitude), String(location.coordinate.longitude))
            saveLocationToCache(location)
            callback = nil
            timer?.invalidate()
        }
        
        // 位置错误回调
        public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            let result = getLocationFromCache()
            callback?(result?.latitude ?? "", result?.longitude ?? "")
            callback = nil
            timer?.invalidate()
            
        }
        /// 从缓存获取位置
        private func getLocationFromCache() -> (latitude: String, longitude: String)? {
            if let latitude = userDefaults.string(forKey: lastLocationLatitudeKey),
               let longitude = userDefaults.string(forKey: lastLocationLongitudeKey),
               !latitude.isEmpty, !longitude.isEmpty {
                return (latitude, longitude)
            }
            return nil
        }
        /// 保存位置到缓存
        private func saveLocationToCache(_ location: CLLocation) {
            userDefaults.set(String(location.coordinate.latitude), forKey: lastLocationLatitudeKey)
            userDefaults.set(String(location.coordinate.longitude), forKey: lastLocationLongitudeKey)
            userDefaults.synchronize()
        }
    }
    
    /// 详细地址信息结构
    public struct AddressDetail {
        public var province: String = ""      // 省
        public var countryCode: String = ""   // 国家代码
        public var country: String = ""       // 国家
        public var street: String = ""        // 街道
        public var latitude: String = ""      // 纬度
        public var longitude: String = ""     // 经度
        public var city: String = ""          // 市
        public var district: String = ""      // 区/县
        
        // 转换为字典
        public var dictionary: [String: String] {
            return [
                "dumbfounded": province,
                "accused": countryCode,
                "learn": country,
                "bewildered": street,
                "trip": latitude,
                "woke": longitude,
                "damage": city
            ]
        }
    }
    
    /// 定位详细信息回调类型
    public typealias AddressDetailCallback = ((_ addressDetail: AddressDetail) -> Void)
    
    // MARK: - 共享实例
    public static let shared = LocationManager()
    
    // MARK: - 私有属性
    private let locationManager = CLLocationManager()
    private var locationRequests: [LocationRequest] = []
    private let userDefaults = UserDefaults.standard
    private let queue = DispatchQueue(label: "com.anytime.LocationManager", qos: .userInitiated)
    
    // 用于存储缓存位置的键
    private let lastLocationLatitudeKey = "com.anytime.location.latitude"
    private let lastLocationLongitudeKey = "com.anytime.location.longitude"
    private let lastLocationTimestampKey = "com.anytime.location.timestamp"
    
    // 默认超时时间
    private let defaultTimeout: TimeInterval = 5.0
    
    // 最后一次有效的位置
    private var lastValidLocation: CLLocation? {
        didSet {
            if let location = lastValidLocation {
                // 缓存位置到本地
                saveLocationToCache(location)
            }
        }
    }
    
    // MARK: - 初始化
    private override init() {
        super.init()
        setupLocationManager()
    }
    
    // MARK: - 私有方法
    
    /// 设置位置管理器
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // 10米
    }
    
    /// 开始定位
    private func startLocationUpdates() {
        // 检查定位权限
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways {
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
            } else {
                // 如果定位服务不可用，处理所有待处理的请求
            }
        } else {
            // 如果没有权限，处理所有待处理的请求
        }
    }
    
    /// 保存位置到缓存
    private func saveLocationToCache(_ location: CLLocation) {
        userDefaults.set(String(location.coordinate.latitude), forKey: lastLocationLatitudeKey)
        userDefaults.set(String(location.coordinate.longitude), forKey: lastLocationLongitudeKey)
        userDefaults.set(Date().timeIntervalSince1970, forKey: lastLocationTimestampKey)
        userDefaults.synchronize()
    }
    
    /// 从缓存获取位置
    private func getLocationFromCache() -> (latitude: String, longitude: String)? {
        if let latitude = userDefaults.string(forKey: lastLocationLatitudeKey),
           let longitude = userDefaults.string(forKey: lastLocationLongitudeKey),
           !latitude.isEmpty, !longitude.isEmpty {
            return (latitude, longitude)
        }
        return nil
    }
    
    /// 创建并添加定位请求
    private func addLocationRequest(timeout: TimeInterval, callback: @escaping LocationCallback) -> LocationRequest {
        let request = LocationRequest(callback: callback, timeoutInterval: timeout)
        
        // 设置定时器
        request.timer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self, weak request] _ in
            guard let self = self, let request = request else { return }
            // 获取缓存的位置
            let cachedLocation = self.getLocationFromCache()
            // 在主线程回调
            DispatchQueue.main.async {
                if let cached = cachedLocation {
                    request.callback?(cached.latitude, cached.longitude)
                    request.callback = nil
                } else {
                    // 如果没有缓存，返回空字符串
                    request.callback?("", "")
                    request.callback = nil
                }
            }
        }
        self.locationRequests.append(request)
        return request
    }
    
    // MARK: - 公共方法
    
    /// 获取当前位置（经纬度）
    /// - Parameters:
    ///   - timeout: 超时时间（默认5秒）
    ///   - callback: 位置回调(纬度，经度)
    public func getCurrentLocation(timeout: TimeInterval = 5.0, callback: @escaping LocationCallback) {
        let request = LocationRequest(callback: callback, timeoutInterval: timeout)
        // 设置定时器
        request.timer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self, weak request] _ in
            guard let self = self, let request = request else { return }
            // 获取缓存的位置
            let cachedLocation = self.getLocationFromCache()
            // 在主线程回调
            DispatchQueue.main.async {
                if let cached = cachedLocation {
                    request.callback?(cached.latitude, cached.longitude)
                    request.callback = nil
                } else {
                    // 如果没有缓存，返回空字符串
                    request.callback?("", "")
                    request.callback = nil
                }
            }
        }
        self.locationRequests.append(request)
    }
    
    /// 获取最新位置字符串，如果没有则返回空字符串
    public func getLastLocationString() -> (latitude: String, longitude: String) {
        if let location = lastValidLocation {
            return (String(location.coordinate.latitude), String(location.coordinate.longitude))
        } else if let cached = getLocationFromCache() {
            return cached
        }
        return ("", "")
    }
    
    /// 获取详细地址信息（省、国家代码、国家、街道、纬度、经度、市、区/县）
    /// - Parameters:
    ///   - timeout: 超时时间（默认5秒）
    ///   - completion: 地址详情回调
    public func getAddressDetail(timeout: TimeInterval = 5.0, completion: @escaping AddressDetailCallback) {
        // 先创建一个空的结果对象
        var addressDetail = AddressDetail()
        
        // 获取经纬度信息
        getCurrentLocation(timeout: timeout) { latitude, longitude in
            // 设置经纬度
            addressDetail.latitude = latitude
            addressDetail.longitude = longitude
            
            // 如果没有获取到经纬度，直接返回空结果
            if latitude.isEmpty || longitude.isEmpty {
                DispatchQueue.main.async {
                    completion(addressDetail)
                }
                return
            }
            
            // 使用CLGeocoder进行反地理编码
            if let lat = Double(latitude), let lng = Double(longitude) {
                let location = CLLocation(latitude: lat, longitude: lng)
                let geocoder = CLGeocoder()
                
                geocoder.reverseGeocodeLocation(location) { placemarks, error in
                    // 在主线程回调
                    DispatchQueue.main.async {
                        if let error = error {
                            print("反地理编码错误: \(error.localizedDescription)")
                            completion(addressDetail)
                            return
                        }
                        
                        // 提取地址信息
                        if let placemark = placemarks?.first {
                            // 省（行政区划，在国外可能是州或省份）
                            addressDetail.province = placemark.administrativeArea ?? ""
                            
                            // 国家代码
                            addressDetail.countryCode = placemark.isoCountryCode ?? ""
                            
                            // 国家
                            addressDetail.country = placemark.country ?? ""
                            
                            // 街道（包含门牌号）
                            if let thoroughfare = placemark.thoroughfare {
                                if let subThoroughfare = placemark.subThoroughfare {
                                    addressDetail.street = "\(thoroughfare) \(subThoroughfare)"
                                } else {
                                    addressDetail.street = thoroughfare
                                }
                            } else if let name = placemark.name {
                                // 如果没有街道信息，使用地标名称
                                addressDetail.street = name
                            }
                            
                            // 市
                            addressDetail.city = placemark.locality ?? ""
                            
                            // 区/县
                            addressDetail.district = placemark.subLocality ?? ""
                        }
                        
                        // 保存到缓存
                        self.saveAddressDetailToCache(addressDetail)
                        
                        // 返回结果
                        completion(addressDetail)
                    }
                }
            } else {
                // 经纬度格式不正确，返回仅包含原始经纬度的结果
                DispatchQueue.main.async {
                    completion(addressDetail)
                }
            }
        }
    }
    
    /// 获取缓存的详细地址信息
    /// - Returns: 详细地址信息，如果没有则返回空值
    public func getCachedAddressDetail() -> AddressDetail {
        var addressDetail = AddressDetail()
        
        // 获取缓存的经纬度
        let cachedLocation = getLastLocationString()
        addressDetail.latitude = cachedLocation.latitude
        addressDetail.longitude = cachedLocation.longitude
        
        // 获取缓存的地址信息
        if let province = userDefaults.string(forKey: "com.anytime.location.province") {
            addressDetail.province = province
        }
        if let countryCode = userDefaults.string(forKey: "com.anytime.location.countryCode") {
            addressDetail.countryCode = countryCode
        }
        if let country = userDefaults.string(forKey: "com.anytime.location.country") {
            addressDetail.country = country
        }
        if let street = userDefaults.string(forKey: "com.anytime.location.street") {
            addressDetail.street = street
        }
        if let city = userDefaults.string(forKey: "com.anytime.location.city") {
            addressDetail.city = city
        }
        if let district = userDefaults.string(forKey: "com.anytime.location.district") {
            addressDetail.district = district
        }
        
        return addressDetail
    }
    
    /// 保存详细地址信息到缓存
    private func saveAddressDetailToCache(_ addressDetail: AddressDetail) {
        userDefaults.set(addressDetail.province, forKey: "com.anytime.location.province")
        userDefaults.set(addressDetail.countryCode, forKey: "com.anytime.location.countryCode")
        userDefaults.set(addressDetail.country, forKey: "com.anytime.location.country")
        userDefaults.set(addressDetail.street, forKey: "com.anytime.location.street")
        userDefaults.set(addressDetail.city, forKey: "com.anytime.location.city")
        userDefaults.set(addressDetail.district, forKey: "com.anytime.location.district")
        userDefaults.synchronize()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    // 位置更新回调
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, location.horizontalAccuracy >= 0 else { return }
        
        // 更新最后有效位置
        lastValidLocation = location
        
        // 处理所有等待中的请求
        queue.async { [weak self] in
            guard let self = self else { return }
            
            // 复制一份当前的请求列表
            let currentRequests = self.locationRequests.filter { $0.state == .waiting }
            
            // 为每个等待中的请求提供位置
            for request in currentRequests {
                request.state = .completed
                
                if let timer = request.timer {
                    timer.invalidate()
                    request.timer = nil
                }
            }
            
            // 移除已完成的请求
            self.locationRequests.removeAll { $0.state != .waiting }
            
            // 如果没有更多请求，停止更新位置
            if self.locationRequests.isEmpty {
                self.locationManager.stopUpdatingLocation()
            }
        }
    }
    
    // 位置错误回调
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // 处理所有等待中的请求，使用缓存
//        handleAllPendingRequestsWithCachedLocation()
    }
    
    // 授权状态变更回调
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // 如果有等待中的请求，开始更新位置
            if !locationRequests.filter({ $0.state == .waiting }).isEmpty {
                locationManager.startUpdatingLocation()
            }
        case .denied, .restricted: break
            // 如果权限被拒绝，处理所有等待中的请求
//            handleAllPendingRequestsWithCachedLocation()
        default:
            break
        }
    }
} 
