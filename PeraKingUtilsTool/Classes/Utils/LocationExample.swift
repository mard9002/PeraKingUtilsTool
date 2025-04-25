import Foundation
import UIKit
import SwiftUI

/// 定位使用示例
public class LocationExample {
    
    /// 简单获取位置示例
    public static func getLocation() {
        LocationManager.shared.getCurrentLocation { latitude, longitude in
            print("位置获取成功: 纬度=\(latitude), 经度=\(longitude)")
        }
    }
    
    /// 多次请求示例，演示不同请求的回调是一一对应的
    public static func multipleRequests() {
        // 第一次请求
        print("发起第一次位置请求")
        LocationManager.shared.getCurrentLocation { latitude, longitude in
            print("第一次请求结果: 纬度=\(latitude), 经度=\(longitude)")
        }
        
        // 延迟1秒后发起第二次请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("发起第二次位置请求")
            LocationManager.shared.getCurrentLocation { latitude, longitude in
                print("第二次请求结果: 纬度=\(latitude), 经度=\(longitude)")
            }
        }
        
        // 延迟2秒后发起第三次请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            print("发起第三次位置请求")
            LocationManager.shared.getCurrentLocation { latitude, longitude in
                print("第三次请求结果: 纬度=\(latitude), 经度=\(longitude)")
            }
        }
    }
    
    /// 自定义超时示例
    public static func customTimeout() {
        // 使用2秒超时
        LocationManager.shared.getCurrentLocation(timeout: 2.0) { latitude, longitude in
            print("2秒超时结果: 纬度=\(latitude), 经度=\(longitude)")
        }
        
        // 使用10秒超时
        LocationManager.shared.getCurrentLocation(timeout: 10.0) { latitude, longitude in
            print("10秒超时结果: 纬度=\(latitude), 经度=\(longitude)")
        }
    }
    
    /// 在网络请求中添加位置参数示例
    public static func useLocationInNetworkRequest() {
        LocationManager.shared.getCurrentLocation { latitude, longitude in
            // 构建请求参数
            var params: [String: Any] = [
                "device_id": DeviceInfoManager.shared.idfv,
                "platform": "iOS",
                "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            ]
            
            // 添加位置信息
            if !latitude.isEmpty && !longitude.isEmpty {
                params["latitude"] = latitude
                params["longitude"] = longitude
            }
            
            // 这里可以继续进行网络请求
            print("准备发送请求，参数: \(params)")
        }
    }
    
    /// 在SwiftUI视图中使用位置数据示例
    public static func createLocationView() -> some View {
        return LocationView()
    }
    
    /// 获取并打印详细地址信息示例
    public static func getAddressDetail() {
        print("开始获取详细地址信息...")
        
        LocationManager.shared.getAddressDetail { addressDetail in
            print("=== 详细地址信息 ===")
            print("经度: \(addressDetail.longitude)")
            print("纬度: \(addressDetail.latitude)")
            print("国家: \(addressDetail.country)")
            print("国家代码: \(addressDetail.countryCode)")
            print("省: \(addressDetail.province)")
            print("市: \(addressDetail.city)")
            print("区/县: \(addressDetail.district)")
            print("街道: \(addressDetail.street)")
            print("===================")
        }
    }
    
    /// 获取详细地址并用于网络请求示例
    public static func useAddressInNetworkRequest() {
        print("获取详细地址信息用于网络请求...")
        
        LocationManager.shared.getAddressDetail { addressDetail in
            // 构建请求参数
            var params: [String: Any] = [
                "device_id": DeviceInfoManager.shared.idfv,
                "platform": "iOS",
                "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            ]
            
            // 添加所有地址信息
            for (key, value) in addressDetail.dictionary {
                if !value.isEmpty {
                    params[key] = value
                }
            }
            
            // 这里可以继续进行网络请求
            print("准备发送请求，包含地址参数: \(params)")
        }
    }
    
    /// 在SwiftUI视图中显示详细地址信息示例
    public static func createAddressDetailView() -> some View {
        return AddressDetailView()
    }
}

/// 位置显示视图
struct LocationView: View {
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    @State private var isLoading: Bool = false
    @State private var lastUpdateTime: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("位置信息")
                .font(.largeTitle)
                .padding(.top, 20)
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding()
                
                Text("获取位置中...")
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("纬度:")
                            .fontWeight(.bold)
                        Text(latitude.isEmpty ? "未知" : latitude)
                            .foregroundColor(.blue)
                    }
                    
                    HStack {
                        Text("经度:")
                            .fontWeight(.bold)
                        Text(longitude.isEmpty ? "未知" : longitude)
                            .foregroundColor(.blue)
                    }
                    
                    if !lastUpdateTime.isEmpty {
                        HStack {
                            Text("更新时间:")
                                .fontWeight(.bold)
                            Text(lastUpdateTime)
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            
            Button(action: updateLocation) {
                Text("刷新位置")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .disabled(isLoading)
            
            Spacer()
        }
        .padding()
        .onAppear {
            // 加载视图时获取位置
            updateLocation()
        }
    }
    
    private func updateLocation() {
        isLoading = true
        
        LocationManager.shared.getCurrentLocation { lat, long in
            self.latitude = lat
            self.longitude = long
            self.isLoading = false
            
            // 更新时间
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.lastUpdateTime = formatter.string(from: Date())
        }
    }
}

/// 地址详情显示视图
struct AddressDetailView: View {
    @State private var addressDetail = LocationManager.AddressDetail()
    @State private var isLoading: Bool = false
    @State private var lastUpdateTime: String = ""
    
    var body: some View {
        List {
            Section(header: Text("位置坐标")) {
                infoRow(title: "纬度", value: addressDetail.latitude)
                infoRow(title: "经度", value: addressDetail.longitude)
                
                if !lastUpdateTime.isEmpty {
                    infoRow(title: "更新时间", value: lastUpdateTime)
                }
            }
            
            Section(header: Text("地址信息")) {
                infoRow(title: "国家", value: addressDetail.country)
                infoRow(title: "国家代码", value: addressDetail.countryCode)
                infoRow(title: "省/州", value: addressDetail.province)
                infoRow(title: "城市", value: addressDetail.city)
                infoRow(title: "区/县", value: addressDetail.district)
                infoRow(title: "街道", value: addressDetail.street)
            }
            
            Button(action: updateAddressDetail) {
                HStack {
                    Spacer()
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding(.trailing, 10)
                    }
                    Text(isLoading ? "正在获取地址..." : "刷新地址信息")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
            .disabled(isLoading)
            .listRowInsets(EdgeInsets())
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
        }
        .navigationTitle("详细地址信息")
        .onAppear {
            updateAddressDetail()
        }
    }
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .fontWeight(.semibold)
            Spacer()
            Text(value.isEmpty ? "未知" : value)
                .foregroundColor(.secondary)
        }
    }
    
    private func updateAddressDetail() {
        isLoading = true
        
        LocationManager.shared.getAddressDetail { detail in
            self.addressDetail = detail
            self.isLoading = false
            
            // 更新时间
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.lastUpdateTime = formatter.string(from: Date())
        }
    }
} 