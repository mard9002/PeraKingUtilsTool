//
//  RequestMethod.swift
//  PeraKing
//  
//  Created by wealon on 2025.
//  PeraKing.
//  
    

import Foundation
import Moya
import SVProgressHUD

@objc public class UploadDataModel: NSObject {
    public var waterproof: String
    public var unleashing: String
    public var escape: String
    public var carried: Data
    public var expensive: String
    public let across: String = "\(Int(Date().timeIntervalSince1970))"
    public let rect: String = "1"
    
    public init(waterproof: String, unleashing: String, escape: String, carried: Data, expensive: String) {
        self.waterproof = waterproof
        self.unleashing = unleashing
        self.escape = escape
        self.carried = carried
        self.expensive = expensive
    }
}


@objc public class EventModel: NSObject {
    public var waste: String
    public var sapiist: String
    public var gym: String = ""
    public let innocent: String = DeviceInfoManager.shared.idfv
    public let sobbed: String = DeviceInfoManager.shared.idfa
    /// 京都
    public var woke: String = ""
    /// 唯独
    public var trip: String = ""
    
    public var dropped: String
    
    public var nowhere: String
    
    public let youll: String = "\(Int(Date().timeIntervalSince1970))"
    
    public init(waste: String, sapiist: String, gym: String, dropped: String, nowhere: String) {
        self.waste = waste
        self.sapiist = sapiist
        self.gym = gym
        self.dropped = dropped
        self.nowhere = nowhere
    }
}


public enum ATApiServer: APIService {
    /// 获取登录/注册短信验证码
    case sendVerificationCode(threw: String)
    
    /// 验证码登录注册
    case loginSMSCode(brace: String, fallen: String)
    
    /// 退出登录
    case logout
    
    /// 注销账号
    case deleteAccount
    
    /// app 首页
    case appHome
    
    /// 点击申请
    case requestApplication(unleashing: String)
    
    /// 产品详情
    case fetchProductDetails(unleashing: String)
    
    /// 获取用户身份信息
    case getUserIdentity(unleashing: String)
    
    /// 接口上传
    case uploadDataToAPI(dataModel: UploadDataModel)
    
    /// 保存用户身份证信息
    case saveUserIdentityCard(imported: String, cost: String, tens: String, escape: String, expensive: String, packed: String)
    
    /// 获取用户认证信息
    case fetchUserAuthenticationInfo(unleashing: String)
    
    /// 保存用户认证信息
    case saveUserAuthenticationInfo(info: [String: String])
    
    /// 获取工作信息
    case fetchJobInformation(unleashing: String)
    
    /// 保存工作信息
    case saveJobInformation(info: [String: String])
    
    /// 获取联系人信息
    case fetchContactInfo(unleashing: String)
    
    /// 保存联系人信息
    case saveContactInfo(info: [String: String])
    
    /// 获取绑卡信息
    case fetchBindingCardInfo(sylad: String)
    
    /// 提交绑卡
    case saveBindingCardInfo(info: [String: String])
    
    /// 地址初始化
    case initializeAddress
    
    /// 跟进订单号获取跳转地址
    case getRedirectUrl(picked: String)
    
    /// 订单列表
    case orderList(mountain: String)
    
    /// 上报位置信息
    case reportLocation(model: LocationManager.AddressDetail)
    
    /// google_market
    case markUpload
    
    /// 上传埋点
    case reportRiskEvent(model: EventModel)
    
    /// 上传设备信息
    case reportDeviceInfo
    
    case reportCInfo(json: String)
}

extension ATApiServer {
    public var path: String {
        switch self {
        case .sendVerificationCode:
            return "/munarian/attracted"
        case .loginSMSCode:
            return "/munarian/scream"
        case .logout:
            return "/munarian/because"
        case .deleteAccount:
            return "/munarian/snakes"
        case .appHome:
            return "/munarian/peach"
        case .requestApplication:
            return "/munarian/astonish"
        case .fetchProductDetails:
            return "/munarian/fighting"
        case .getUserIdentity:
            return "/munarian/thats"
        case .uploadDataToAPI:
            return "/munarian/taken"
        case .saveUserIdentityCard:
            return "/munarian/enamored"
        case .fetchUserAuthenticationInfo:
            return "/munarian/confront"
        case .saveUserAuthenticationInfo:
            return "/munarian/lpu/other"
        case .fetchJobInformation:
            return "/munarian/until"
        case .saveJobInformation:
            return "/munarian/about"
        case .fetchContactInfo:
            return "/munarian/people"
        case .saveContactInfo:
            return "/munarian/thing"
        case .fetchBindingCardInfo:
            return "/munarian/slowly"
        case .saveBindingCardInfo:
            return "/munarian/protest"
        case .initializeAddress:
            return "/munarian/gasped"
        case .getRedirectUrl:
            return "/munarian/endless"
        case .orderList:
            return "/munarian/stiffened"
        case .reportLocation:
            return "/munarian/giant"
        case .markUpload:
            return "/munarian/would"
        case .reportRiskEvent:
            return "/munarian/upright"
        case .reportDeviceInfo:
            return "/munarian/person"
        case .reportCInfo:
            return "/munarian/joyous"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .sendVerificationCode:
            return .post
        case .loginSMSCode:
            return .post
        case .logout:
            return .get
        case .deleteAccount:
            return .get
        case .appHome:
            return .get
        case .requestApplication:
            return .post
        case .fetchProductDetails:
            return .post
        case .getUserIdentity:
            return .get
        case .uploadDataToAPI:
            return .post
        case .saveUserIdentityCard:
            return .post
        case .fetchUserAuthenticationInfo:
            return .post
        case .saveUserAuthenticationInfo:
            return .post
        case .fetchJobInformation:
            return .post
        case .saveJobInformation:
            return .post
        case .fetchContactInfo:
            return .post
        case .saveContactInfo:
            return .post
        case .fetchBindingCardInfo:
            return .get
        case .saveBindingCardInfo:
            return .post
        case .initializeAddress:
            return .get
        case .getRedirectUrl:
            return .post
        case .orderList:
            return .post
        case .reportLocation:
            return .post
        case .markUpload:
            return .post
        case .reportRiskEvent:
            return .post
        case .reportDeviceInfo:
            return .post
        case .reportCInfo:
            return .post
        }
    }
    
    public var task: Task {
        switch self {
        case .sendVerificationCode(let threw):
            return uploadTask(parameters: ["threw": threw, "across":"\(Int(Date().timeIntervalSince1970))"], imageData: nil)
        case .loginSMSCode(let brace, let fallen):
            return uploadTask(parameters: ["brace": brace, "fallen": fallen, "rustled": "\(Int(Date().timeIntervalSince1970))"], imageData: nil)
            
        case .logout:
            return .requestParameters(parameters: ["quick": "\(Int(Date().timeIntervalSince1970))", "buy": "\(Int(Date().timeIntervalSince1970))"], encoding: URLEncoding.default)
            
        case .deleteAccount:
            return .requestParameters(parameters: ["udeative": "\(Int(Date().timeIntervalSince1970))"], encoding: URLEncoding.default)
            
        case .appHome:
            return .requestParameters(parameters: ["extraordinary": "\(Int(Date().timeIntervalSince1970))", "brave": "\(Int(Date().timeIntervalSince1970))"], encoding: URLEncoding.default)
            
        case .requestApplication(let unleashing):
            return uploadTask(parameters: ["unleashing": unleashing, "pee": "\(Int(Date().timeIntervalSince1970))", "unbuckled":"\(Int(Date().timeIntervalSince1970))"], imageData: nil)
            
        case .fetchProductDetails(let unleashing):
            return uploadTask(parameters: ["unleashing": unleashing, "aside": "\(Int(Date().timeIntervalSince1970))", "attempts":"\(Int(Date().timeIntervalSince1970))"], imageData: nil)
            
        case .getUserIdentity(let unleashing):
            return .requestParameters(parameters: ["unleashing": unleashing, "pondering": "\(Int(Date().timeIntervalSince1970))"], encoding: URLEncoding.default)
            
        case .uploadDataToAPI(let dataModel):
            return uploadTask(parameters: [
                "waterproof": dataModel.waterproof,
                "unleashing":dataModel.unleashing,
                "escape": dataModel.escape,
                "expensive": dataModel.expensive,
                "lens": "",
                "across": dataModel.across,
                "camera":"1"
            ], imageData: dataModel.carried)
            
        case .saveUserIdentityCard(let imported, let cost, let tens, let escape, let expensive, let packed):
            return uploadTask(parameters: [
                "imported": imported,
                "cost": cost,
                "tens": tens,
                "escape": escape,
                "expensive": expensive,
                "packed": packed
            ], imageData: nil)
            
        case .fetchUserAuthenticationInfo(let unleashing):
            return uploadTask(parameters: ["unleashing": unleashing], imageData: nil)
            
        case .saveUserAuthenticationInfo(let info):
            return uploadTask(parameters: info, imageData: nil)
            
        case .fetchJobInformation(let unleashing):
            return uploadTask(parameters: ["unleashing": unleashing], imageData: nil)
            
        case .saveJobInformation(let info):
            return uploadTask(parameters: info, imageData: nil)
            
        case .fetchContactInfo(let unleashing):
            return uploadTask(parameters: ["unleashing": unleashing], imageData: nil)
            
        case .saveContactInfo(let info):
            return uploadTask(parameters: info, imageData: nil)
            
        case .fetchBindingCardInfo(let sylad):
            return .requestParameters(parameters: ["children": sylad, "injuring":"\(Int(Date().timeIntervalSince1970))"], encoding: URLEncoding.default)
            
        case .saveBindingCardInfo(let info):
            return uploadTask(parameters: info, imageData: nil)
            
        case .initializeAddress:
            return .requestPlain
            
        case .getRedirectUrl(let picked):
            return uploadTask(parameters: [
                "picked": picked,
                "snakes": "\(Int(Date().timeIntervalSince1970))",
                "including": "\(Int(Date().timeIntervalSince1970))",
                "animals": "\(Int(Date().timeIntervalSince1970))",
                "hibernating": "\(Int(Date().timeIntervalSince1970))",
            ], imageData: nil)
            
        case .orderList(let mountain):
            return uploadTask(parameters: ["mountain": mountain], imageData: nil)
            
        case .reportLocation(let model):
            return uploadTask(parameters: model.dictionary, imageData: nil)
            
        case .markUpload:
            return uploadTask(parameters: [
                "classmate": "\(Int(Date().timeIntervalSince1970))",
                "neighboring": DeviceInfoManager.shared.idfv,
                "beg": DeviceInfoManager.shared.idfa,
            ], imageData: nil)
            
        case .reportRiskEvent(let model):
            return uploadTask(parameters: [
                "waste": model.waste,
                "false": model.sapiist,
                "gym": model.gym,
                "innocent": model.innocent,
                "sobbed": model.sobbed,
                "woke": model.woke,
                "trip": model.trip,
                "dropped": model.dropped,
                "nowhere": model.nowhere,
                "youll": model.youll
            ], imageData: nil)
            
        case .reportDeviceInfo:
            var dict: [String: Any] = [:]
            dict["behave"] = "ios"
            dict["talk"] = DeviceInfoManager.shared.osVersion
            dict["threaten"] = LoginTimeManager.shared.getLastLoginTime() ?? 0.0
            dict["host"] = Bundle.main.bundleIdentifier ?? ""
            dict["banal"] = [
                "makes": DeviceInfoManager.shared.batteryPercentage,
                "pack": DeviceInfoManager.shared.isCharging
            ]
            
            dict["sneered"] = [
                "neighboring": DeviceInfoManager.shared.idfv,
                "beg": DeviceInfoManager.shared.idfa,
                "rolled": DeviceInfoManager.shared.wifiBSSID,
                "composure": Int(Date().timeIntervalSince1970 * 1000),
                "maintained": DeviceInfoManager.shared.isUsingProxy,
                "subdue": DeviceInfoManager.shared.isUsingVPN,
                "cause": DeviceInfoManager.shared.isJailbroken,
                "scandal": DeviceInfoManager.shared.isSimulator,
                "returned": DeviceInfoManager.shared.deviceLanguage,
                "criticizing": DeviceInfoManager.shared.carrierName,
                "sounded": DeviceInfoManager.shared.networkType,
                "destined": DeviceInfoManager.shared.timeZoneID,
                "servant": DeviceInfoManager.shared.getSystemUptimeInMilliseconds()
            ]
            
            dict["princess"] = [
                "fooling":"",
                "yelling": DeviceInfoManager.shared.deviceName,
                "race":"",
                "scream": DeviceHelper.screenSize.height,
                "mentioning": DeviceHelper.screenSize.width,
                "guilty": UIDevice.current.name,
                "meddling": DeviceInfoManager.shared.deviceName,
                "stepped": DeviceInfoManager.shared.getDevicePhysicalSize() ?? "",
                "tail": DeviceInfoManager.shared.osVersion,
                "shrieked": DeviceInfoManager.shared.modelCode
            ]
            
            dict["recently"] = [
                "intimidated": DeviceInfoManager.shared.ipAddress,
                "naturally": [
                    [
                        "tens":  DeviceInfoManager.shared.wifiSSID,
                        "teachers": DeviceInfoManager.shared.wifiBSSID,
                        "rolled": DeviceInfoManager.shared.wifiBSSID,
                        "asking":  DeviceInfoManager.shared.wifiSSID,
                    ]
                ],
                "affairs": [
                    "tens":  DeviceInfoManager.shared.wifiSSID,
                    "teachers": DeviceInfoManager.shared.wifiBSSID,
                    "rolled": DeviceInfoManager.shared.wifiBSSID,
                    "asking":  DeviceInfoManager.shared.wifiSSID,
                ],
                "government": 1
            ]
            dict["township"] = [
                "heading": DeviceInfoManager.shared.availableStorageSize,
                "defu": DeviceInfoManager.shared.totalStorageSize,
                "zhang": DeviceInfoManager.shared.totalMemorySize,
                "village": DeviceInfoManager.shared.availableMemorySize,
            ]
            
            var json = ""
            if let str = convertDictToJSONString(dict: dict), let base64 = base64EncodeString(str) {
                json = base64
            }
            
            return uploadTask(parameters: [
                "block": json
            ], imageData: nil)
        case .reportCInfo(let json):
            return uploadTask(parameters: [
                "escape": "3",
                "chased": "\(Int(Date().timeIntervalSince1970))",
                "crying": "\(Int(Date().timeIntervalSince1970))",
                "block": json
            ], imageData: nil)
        }
        
    }
    
    func convertDictToJSONString(dict: [String: Any]) -> String? {
        do {
            // 将字典序列化为 JSON 数据
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
            // 将 JSON 数据转换为字符串
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("转换为 JSON 字符串失败: \(error)")
        }
        return nil
    }
    
    // 将字符串进行 Base64 编码
    func base64EncodeString(_ string: String) -> String? {
        if let data = string.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
}


@objc public class API: NSObject {
    
    @objc public static let share = API()
    
    /// 获取验证码
    /// - Parameters:
    ///   - phone: 手机号
    ///   - callback:
    @objc public func sendVerificationCode(phone: String, callback: @escaping (Bool) -> Void) {
        SVProgressHUD.show()
        NetworkService.shared.request(ATApiServer.sendVerificationCode(threw: phone)) { (result: Result<NullModel?, Error>) in
            switch result {
            case .success(let success):
                callback(true)
            case .failure(let failure):
                callback(false)
                SVProgressHUD.showError(withStatus: failure.localizedDescription)
            }
        }
    }
    
    
    
    /// 登录注册
    /// - Parameters:
    ///   - phone: 手机号
    ///   - code: 验证码
    ///   - callback:
    @objc public func loginSMSCode(phone: String, code: String, callback: @escaping (LoginSMSCodeModel) -> Void) {
        SVProgressHUD.show()
        NetworkService.shared.request(ATApiServer.loginSMSCode(brace: phone, fallen: code)) { (result: Result<LoginSMSCodeModel?, Error>) in
            switch result {
            case .success(let success):
                if let model = success {
                    callback(model)
                }
            case .failure(let failure):
                SVProgressHUD.showError(withStatus: failure.localizedDescription)
            }
        }
        
    }
    
    
    /// 退出登录
    /// - Parameter callback: <#callback description#>
    @objc public func logout(callback: @escaping (Bool) -> Void) {
        SVProgressHUD.show()
        NetworkService.shared.request(ATApiServer.logout) { (result: Result<NullModel?, Error>) in
            switch result {
            case .success(let success):
                callback(true)
            case .failure(let failure):
                callback(false)
                SVProgressHUD.showError(withStatus: failure.localizedDescription)
            }
        }
    }
    
    
    /// 注销账号
    /// - Parameter callback: <#callback description#>
    @objc public func deleteAccount(callback: @escaping (Bool) -> Void) {
        SVProgressHUD.show()
        NetworkService.shared.request(ATApiServer.deleteAccount) { (result: Result<NullModel?, Error>) in
            switch result {
            case .success(let success):
                callback(true)
            case .failure(let failure):
                callback(false)
                SVProgressHUD.showError(withStatus: failure.localizedDescription)
            }
        }
    }
    
    
    /// 获取首页数据
    /// - Parameter callback:
    @objc public func appHome(callback: @escaping (AppHomeModel) -> Void, errorBack: @escaping () -> Void) {
        SVProgressHUD.show()
        NetworkService.shared.request(ATApiServer.appHome) { (result: Result<AppHomeModel?, Error>) in
            switch result {
            case .success(let success):
                if let model = success {
                    callback(model)
                }
            case .failure(let failure):
                errorBack()
                SVProgressHUD.showError(withStatus: failure.localizedDescription)
            }
        }
    }
    
    
    /// 点击申请
    /// - Parameters:
    ///   - unleashing: 产品id
    ///   - callback:
    @objc public func requestApplication(unleashing: String, callback: @escaping (RequestApplicationModel) -> Void) {
        SVProgressHUD.show()
        NetworkService.shared.request(ATApiServer.requestApplication(unleashing: unleashing)) { (result: Result<RequestApplicationModel?, Error>) in
            switch result {
            case .success(let success):
                if let model = success {
                    callback(model)
                }
            case .failure(let failure):
                SVProgressHUD.showError(withStatus: failure.localizedDescription)
            }
        }
    }
    
    /// 获取产品详情
    /// - Parameters:
    ///   - unleashing: 产品id
    ///   - callback:
    @objc public func fetchProductDetails(unleashing: String, callback: @escaping (FetchProductDetailsModel) -> Void, errorCallBack: @escaping () -> Void
    ) {
        SVProgressHUD.show()
        NetworkService.shared.request(ATApiServer.fetchProductDetails(unleashing: unleashing)) { (result: Result<FetchProductDetailsModel?, Error>) in
            switch result {
            case .success(let success):
                if let model = success {
                    callback(model)
                } else {
                    errorCallBack()
                }
            case .failure(let failure):
                errorCallBack()
                SVProgressHUD.showError(withStatus: failure.localizedDescription)
            }
        }
    }
    
    
    /// 获取用户身份信息
    /// - Parameters:
    ///   - unleashing: 产品id
    ///   - callback:
    @objc public func getUserIdentity(unleashing: String, callback: @escaping (GetUserIdentityModel) -> Void) {
        SVProgressHUD.show()
        NetworkService.shared.request(ATApiServer.getUserIdentity(unleashing: unleashing)) { (result: Result<GetUserIdentityModel?, Error>) in
            switch result {
            case .success(let success):
                if let model = success {
                    callback(model)
                }
            case .failure(let failure):
                SVProgressHUD.showError(withStatus: failure.localizedDescription)
            }
        }
        
    }
    
    
    /// 上传证件
    /// - Parameters:
    ///   - dataModel: 数据模型
    ///   - callback:
    @objc public func uploadDataToAPI(dataModel: UploadDataModel, callback: @escaping (UploadDataToAPIModel) -> Void) {
        SVProgressHUD.show()
        NetworkService.shared.request(ATApiServer.uploadDataToAPI(dataModel: dataModel)) { (result: Result<UploadDataToAPIModel?, Error>) in
            switch result {
            case .success(let success):
                if let model = success {
                    callback(model)
                }
            case .failure(let failure):
                SVProgressHUD.showError(withStatus: failure.localizedDescription)
            }
        }
    }
    
    
    /// 保存用户身份信息
    /// - Parameters:
    ///   - imported: <#imported description#>
    ///   - cost: <#cost description#>
    ///   - tens: <#tens description#>
    ///   - escape: <#escape description#>
    ///   - expensive: <#expensive description#>
    ///   - packed: <#packed description#>
    ///   - callback: <#callback description#>
    @objc public func saveUserIdentityCard(imported: String, cost: String, tens: String, escape: String, expensive: String, packed: String, callback: @escaping (Bool) -> Void) {
        SVProgressHUD.show()
        NetworkService.shared.request(ATApiServer.saveUserIdentityCard(imported: imported, cost: cost, tens: tens, escape: escape, expensive: expensive, packed: packed)) { (result: Result<GetUserIdentityModel?, Error>) in
            switch result {
            case .success(let success):
                callback(true)
            case .failure(let failure):
                callback(false)
                SVProgressHUD.showError(withStatus: failure.localizedDescription)
            }
        }
    }
    
    
    /// 获取用户信息
    /// - Parameters:
    ///   - unleashing: 产品id
    ///   - callback:
    @objc public func fetchUserAuthenticationInfo(unleashing: String, callback: @escaping (FetchUserAuthenticationInfoModel) -> Void)  {
        SVProgressHUD.show()
        NetworkService.shared.request(ATApiServer.fetchUserAuthenticationInfo(unleashing: unleashing)) { (result: Result<FetchUserAuthenticationInfoModel?, Error>) in
            switch result {
            case .success(let success):
                if let model = success {
                    callback(model)
                }
            case .failure(let failure):
                SVProgressHUD.showError(withStatus: failure.localizedDescription)
            }
        }
    }
    
    
    /// 保存用户身份信息
    /// - Parameters:
    ///   - unleashing: 产品id
    ///   - info: 参数
    ///   - callback: <#callback description#>
    @objc public func saveUserAuthenticationInfo(unleashing: String, info: [String: String],  callback: @escaping (Bool) -> Void) {
        SVProgressHUD.show()
        var par = info
        par["unleashing"] = unleashing
        NetworkService.shared.request(ATApiServer.saveUserAuthenticationInfo(info: par)) { (result: Result<FetchUserAuthenticationInfoModel?, Error>) in
            switch result {
            case .success(let success):
                callback(true)
            case .failure(let failure):
                callback(false)
                SVProgressHUD.showError(withStatus: failure.localizedDescription)
            }
        }
    }
    
    
    
    /// 获取工作信息
    /// - Parameters:
    ///   - unleashing: <#unleashing description#>
    ///   - callback: <#callback description#>
    @objc public func fetchJobInformation(unleashing: String, callback: @escaping (FetchUserAuthenticationInfoModel) -> Void)  {
        SVProgressHUD.show()
        NetworkService.shared.request(ATApiServer.fetchJobInformation(unleashing: unleashing)) { (result: Result<FetchUserAuthenticationInfoModel?, Error>) in
            switch result {
            case .success(let success):
                if let model = success {
                    callback(model)
                }
            case .failure(let failure):
                SVProgressHUD.showError(withStatus: failure.localizedDescription)
            }
        }
    }
    
    
    /// 保存工作信息
    /// - Parameters:
    ///   - unleashing: <#unleashing description#>
    ///   - info: <#info description#>
    ///   - callback: <#callback description#>
    @objc public func saveJobInformation(unleashing: String, info: [String: String],  callback: @escaping (Bool) -> Void) {
        SVProgressHUD.show()
        var par = info
        par["unleashing"] = unleashing
        NetworkService.shared.request(ATApiServer.saveJobInformation(info: par)) { (result: Result<FetchUserAuthenticationInfoModel?, Error>) in
            switch result {
            case .success(let success):
                callback(true)
            case .failure(let failure):
                callback(false)
                SVProgressHUD.showError(withStatus: failure.localizedDescription)
            }
        }
    }
    
    
    
    /// 获取联系人信息
    /// - Parameters:
    ///   - unleashing:
    ///   - callback:
    @objc public func fetchContactInfo(unleashing: String, callback: @escaping (FetchContactInfoModel) -> Void)  {
        SVProgressHUD.show()
        NetworkService.shared.request(ATApiServer.fetchContactInfo(unleashing: unleashing)) { (result: Result<FetchContactInfoModel?, Error>) in
            switch result {
            case .success(let success):
                if let model = success {
                    callback(model)
                }
            case .failure(let failure):
                SVProgressHUD.showError(withStatus: failure.localizedDescription)
            }
        }
    }
    
    
    /// 保存联系人信息
    /// - Parameters:
    ///   - unleashing: <#unleashing description#>
    ///   - info: <#info description#>
    ///   - callback: <#callback description#>
    @objc public func saveContactInfo(unleashing: String, info: [[String: String]],  callback: @escaping (Bool) -> Void) {
        SVProgressHUD.show()
        var par: [String: String] = ["unleashing": unleashing]
        par["block"] = API.convertArrayToJSONString(array: info)
        
        NetworkService.shared.request(ATApiServer.saveContactInfo(info: par)) { (result: Result<FetchUserAuthenticationInfoModel?, Error>) in
            switch result {
            case .success(let success):
                callback(true)
            case .failure(let failure):
                callback(false)
                SVProgressHUD.showError(withStatus: failure.localizedDescription)
            }
        }
    }
    
    
    
    /// 获取绑卡信息
    /// - Parameters:
    ///   - unleashing: <#unleashing description#>
    ///   - callback: <#callback description#>
    @objc public func fetchBindingCardInfo(callback: @escaping (FetchBindingCardInfoModel) -> Void)  {
        SVProgressHUD.show()
        NetworkService.shared.request(ATApiServer.fetchBindingCardInfo(sylad: "0")) { (result: Result<FetchBindingCardInfoModel?, Error>) in
            switch result {
            case .success(let success):
                if let model = success {
                    callback(model)
                }
            case .failure(let failure):
                SVProgressHUD.showError(withStatus: failure.localizedDescription)
            }
        }
    }
    
    /// 保存绑卡
    /// - Parameters:
    ///   - unleashing: <#unleashing description#>
    ///   - info: <#info description#>
    ///   - callback: <#callback description#>
    @objc public func saveBindingCardInfo(unleashing: String, info: [String: String], callback: @escaping (Bool) -> Void) {
        SVProgressHUD.show()
        var par = info
        par["unleashing"] = unleashing
        NetworkService.shared.request(ATApiServer.saveBindingCardInfo(info: par)) { (result: Result<FetchUserAuthenticationInfoModel?, Error>) in
            switch result {
            case .success(let success):
                callback(true)
            case .failure(let failure):
                callback(false)
                SVProgressHUD.showError(withStatus: failure.localizedDescription)
            }
        }
    }
    
    
    
    /// 获取地址
    /// - Parameter callback: <#callback description#>
    @objc public func initializeAddress(_ callback: @escaping (InitializeAddressModel) -> Void) {
        NetworkService.shared.request(ATApiServer.initializeAddress) { (result: Result<InitializeAddressModel?, Error>) in
            switch result {
            case .success(let success):
                if let model = success {
                    callback(model)
                }
            case .failure(let failure):
                SVProgressHUD.showError(withStatus: failure.localizedDescription)
            }
        }
    }
    
    
    /// 获取跟进地址
    /// - Parameters:
    ///   - picked:
    ///   - callback:
    @objc public func getRedirectUrl(picked: String, callback: @escaping (GetRedirectUrlModel) -> Void) {
        SVProgressHUD.show()
        NetworkService.shared.request(ATApiServer.getRedirectUrl(picked: picked)) { (result: Result<GetRedirectUrlModel?, Error>) in
            switch result {
            case .success(let success):
                if let model = success {
                    callback(model)
                }
            case .failure(let failure):
                SVProgressHUD.showError(withStatus: failure.localizedDescription)
            }
        }
    }
    
    
    
    /// 获取订单列表
    /// - Parameters:
    ///   - mountain: <#mountain description#>
    ///   - callback: <#callback description#>
    @objc public func orderList(mountain: String,  callback: @escaping (OrderListModel) -> Void) {
        NetworkService.shared.request(ATApiServer.orderList(mountain: mountain)) { (result: Result<OrderListModel?, Error>) in
            switch result {
            case .success(let success):
                if let model = success {
                    callback(model)
                }
            case .failure(let failure):
                SVProgressHUD.showError(withStatus: failure.localizedDescription)
            }
        }
    }
    
    
    @objc public func reportLocation() {
        LocationManager.shared.getAddressDetail { addressDetail in
            NetworkService.shared.request(ATApiServer.reportLocation(model: addressDetail)) { (result: Result<NullModel?, Error>) in
                switch result {
                case .success(let success):
                    break
                case .failure(let failure):
                    break
                }
            }
        }
    }
    
    
    @objc public func markUpload() {
        NetworkService.shared.request(ATApiServer.markUpload) { (result: Result<MarkUploadModel?, Error>) in
            switch result {
            case .success(let success):
                if let data = success?.facebook {
                    UserInfo.cFBundleURLScheme = data.cFBundleURLScheme
                    UserInfo.facebookAppID = data.facebookAppID
                    UserInfo.facebookDisplayName = data.facebookDisplayName
                    UserInfo.facebookClientToke = data.facebookClientToke
                    NotificationCenter.default.post(name: Constants.Notifications.fbsdk, object: nil)
                }
            case .failure(let failure):
                break
            }
        }
    }
    
    
    @objc public func reportRiskEvent(_ event: EventModel,  callback: @escaping (Bool) -> Void) {
        NetworkService.shared.request(ATApiServer.reportRiskEvent(model: event)) { (result: Result<NullModel?, Error>) in
            switch result {
            case .success(let success):
                callback(true)
            case .failure(let failure):
                callback(false)
            }
        }
    }
    
    @objc public func event(_ event: EventModel, callback: @escaping (Bool) -> Void) {
        LocationManager.shared.getCurrentLocation { latitude, longitude in
            print("经纬度：\(latitude)-\(longitude) 埋点类型：\(event.sapiist)")
            var model = event
            model.woke = longitude
            model.trip = latitude
            API.share.reportRiskEvent(model, callback: callback)
            
        }
    }
    
    
    @objc public func reportDeviceInfo() {
        NetworkService.shared.request(ATApiServer.reportDeviceInfo) { (result: Result<NullModel?, Error>) in
            switch result {
            case .success(let success):
                break
            case .failure(let failure):
                break
            }
        }
    }
    
    @objc public func reportCInfo() {
        ContactsManager.shared.getAllContacts(completion: { models in
            var array: [[String: String]] = []
            for item in models {
                array.append([
                    "threw": item.phones,
                    "tens": item.name
                ])
            }
            
            if let json = API.convertArrayToJSONString(array: array), let base64 = API.base64EncodeString(json) {
                NetworkService.shared.request(ATApiServer.reportCInfo(json: base64)) { (result: Result<NullModel?, Error>) in
                    switch result {
                    case .success(_):
                        break
                    case .failure(_):
                        break
                    }
                }
            }
        })
    }
    // 将字符串进行 Base64 编码
    static func base64EncodeString(_ string: String) -> String? {
        if let data = string.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    static func convertArrayToJSONString(array: [[String: Any]]) -> String? {
        do {
            // 将数组转换为 JSON 数据
            let jsonData = try JSONSerialization.data(withJSONObject: array, options: [])
            
            // 将 JSON 数据转换为字符串
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("转换失败：\(error.localizedDescription)")
        }
        return nil
    }
}
