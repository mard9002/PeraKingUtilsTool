import Foundation
import Moya
import Alamofire
import SmartCodable
import SVProgressHUD

// MARK: - 网络服务基类
public final class NetworkService {
    
    // MARK: 单例实例
    public static let shared = NetworkService()
    
    // MARK: 属性
    private let provider: MoyaProvider<MultiTarget>
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let queue = DispatchQueue(label: "com.anytime.test.network", qos: .userInitiated)
    public static var dynamicParametersProvider: (() -> [String: Any])?
    // MARK: 初始化
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Constants.APIURL.timeout
        configuration.headers = .default
        
        // 自定义日志插件
        let networkLogger = NetworkLoggerPlugin(configuration: .init(
            logOptions: .verbose
        ))
        
        let session = Session(configuration: configuration)
        let plugin = NetworkParameterPlugin(
            parameters: [
                "husband":"ios",
                "dongqings": DeviceHelper.appVersion,
                "criticism": DeviceInfoManager.shared.deviceName,
                "stop": DeviceInfoManager.shared.idfv,
                "indicating": DeviceInfoManager.shared.osVersion,
                "pushed":"perakingapi",
                "cautious": DeviceInfoManager.shared.idfv,
                "boyfine": "\(Int(Date().timeIntervalSince1970))",
            ],
            dynamicParametersProvider: {
                return NetworkService.dynamicParametersProvider?() ?? [:]
            }
        )
        self.provider = MoyaProvider<MultiTarget>(
            session: session,
            plugins: [networkLogger, plugin]
        )
        
        // 配置解码器
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }
    /// 取消所有正在进行的请求
    func cancelAllRequests() {
        provider.session.session.getAllTasks { tasks in
            tasks.forEach { $0.cancel() }
        }
    }
    // MARK: 请求方法
    
    /// 发送网络请求并解析返回的响应
    /// - Parameters:
    ///   - target: API目标
    ///   - completion: 完成回调
    public func request<T: SmartCodable, U: TargetType>(_ target: U, completion: @escaping (Result<T?, Error>) -> Void) {
        let multiTarget = MultiTarget(target)
        
        provider.request(multiTarget, callbackQueue: queue) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                do {
                    // 检查是否有错误响应
                    if self.isErrorStatusCode(response.statusCode) {
                        let error = try self.parseErrorResponse(from: response)
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    guard let dictionary = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any]  else { return }
                    // 解析成功响应
                    if let decodedResponse = BaseResponse<T>.deserialize(from:  dictionary) {
                        if decodedResponse.downwards == 0 {
                            DispatchQueue.main.async {
                                SVProgressHUD.dismiss()
                                completion(.success(decodedResponse.block))
                            }
                        } else if decodedResponse.downwards == -2 {
                            NotificationCenter.default.post(name: Constants.Notifications.switchLogin, object: nil)
                        }
                        else  {
                            let paths = [
                                "/munarian/joyous",
                                "/munarian/person",
                                "/munarian/upright",
                                "/munarian/would",
                                "/munarian/giant",
                                "/munarian/giant",
                            ]
                            DispatchQueue.main.async {
                                if !paths.contains(target.path) {
                                    SVProgressHUD.showInfo(withStatus: decodedResponse.panic)
                                }
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            SVProgressHUD.showInfo(withStatus: "Data error")
                        }
                        
                    }

                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.decodingFailed(error)))
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(self.handleMoyaError(error)))
                }
            }
        }
    }
    
    /// 发送网络请求并返回原始数据
    /// - Parameters:
    ///   - target: API目标
    ///   - completion: 完成回调
    public func requestData<U: TargetType>(_ target: U, completion: @escaping (Result<Data, Error>) -> Void) {
        let multiTarget = MultiTarget(target)
        
        provider.request(multiTarget, callbackQueue: queue) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if self.isErrorStatusCode(response.statusCode) {
                    let error = try? self.parseErrorResponse(from: response)
                    DispatchQueue.main.async {
                        completion(.failure(error ?? NetworkError.serverError(response.statusCode)))
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    completion(.success(response.data))
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(self.handleMoyaError(error)))
                }
            }
        }
    }
    
    // MARK: 帮助方法
    
    /// 检查状态码是否表示错误
    private func isErrorStatusCode(_ statusCode: Int) -> Bool {
        return statusCode < 200 || statusCode >= 300
    }
    
    /// 解析错误响应
    private func parseErrorResponse(from response: Response) throws -> Error {
        // 尝试解析服务器错误消息
        if let json = try? JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any],
           let message = json["caulihappenitive"] as? String {
            return NetworkError.serverMessage(response.statusCode, message)
        }
        
        // 如果无法解析，返回一般的HTTP错误
        return NetworkError.serverError(response.statusCode)
    }
    
    /// 处理Moya错误
    private func handleMoyaError(_ error: MoyaError) -> Error {
        switch error {
        case .underlying(let nsError as NSError, _):
            if nsError.domain == NSURLErrorDomain {
                switch nsError.code {
                case NSURLErrorNotConnectedToInternet:
                    return NetworkError.noConnection
                case NSURLErrorTimedOut:
                    return NetworkError.timeout
                default:
                    return NetworkError.connectionError(nsError)
                }
            }
            return NetworkError.unknown(error)
            
        case .statusCode(let response):
            return NetworkError.serverError(response.statusCode)
            
        case .objectMapping:
            return NetworkError.decodingFailed(error)
            
        default:
            return NetworkError.unknown(error)
        }
    }
}

// MARK: - 网络错误类型
public enum NetworkError: Error, LocalizedError {
    case noConnection
    case timeout
    case serverError(Int)
    case serverMessage(Int, String)
    case decodingFailed(Error)
    case encodingFailed(Error)
    case connectionError(Error)
    case invalidData
    case cancelled
    case unknown(Error)
    
    public var errorDescription: String? {
        switch self {
        case .noConnection:
            return "The network connection is unavailable"
        case .timeout:
            return "Request timeout"
        case .serverError(let code):
            return "Server error: \(code)"
        case .serverMessage(let code, let message):
            return "Server error \(code): \(message)"
        case .decodingFailed:
            return "Response data parsing error"
        case .encodingFailed:
            return "The request data encoding is incorrect"
        case .connectionError:
            return "Network connection error"
        case .invalidData:
            return "Invalid data"
        case .cancelled:
            return "The request has been cancelled."
        case .unknown:
            return "Unknown error"
        }
    }
}

// MARK: - API基本协议
public protocol APIService: TargetType {
    /// 配置请求的额外头部信息
    var additionalHeaders: [String: String]? { get }
    
    func uploadTask(parameters: [String: String], imageData: Data?) -> Task
}

// MARK: - API扩展
public extension APIService {
    /// 基础URL
    var baseURL: URL {
        guard let url = URL(string: Constants.APIURL.baseURL) else {
            fatalError("Invalid base URL: \(Constants.APIURL.baseURL)")
        }
        return url
    }
    
    var additionalHeaders: [String: String]? {
        return nil
    }
    
    /// 默认头部信息
    var headers: [String: String]? {
        var headers: [String: String] = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        // 合并额外的头部信息
        if let additionalHeaders = additionalHeaders {
            headers.merge(additionalHeaders) { (_, new) in new }
        }
        return headers
    }
    
    /// 构建上传任务
    /// - Parameters:
    ///   - imageData: 图片数据（可选）
    ///   - parameters: 表单参数
    /// - Returns: 上传任务类型
    func uploadTask(parameters: [String: String], imageData: Data?)-> Task {
        var formData: [Moya.MultipartFormData] = []
        
        // 添加图片数据
        if let imageData = imageData {
            let fileName = "\(Int(Date().timeIntervalSince1970)).jpg"
            formData.append(MultipartFormData(provider: .data(imageData), name: "carried", fileName: fileName, mimeType: "image/jpeg"))
        }
        
        // 添加表单参数
        for (key, value) in parameters {
            if let data = value.data(using: .utf8) {
                formData.append(MultipartFormData(provider: .data(data), name: key))
            }
        }
        
        return .uploadMultipart(formData)
    }
}




// MARK: - 响应模型

/// 基础响应模型
public class BaseResponse<T: SmartCodable>: SmartCodable {
    required public init() {}
    
    public var downwards: Int?
    public var panic: String?
    public var block: T?
}

/// 用户模型
public struct User: Codable {
    public let id: String
    public let name: String
    public let email: String
    public let avatarURL: String?
    public let createdAt: Date
    public let updatedAt: Date
}

// MARK: - 使用示例
/*
 使用示例:
 
 // 登录请求
 NetworkService.shared.request(UserAPIService.login(email: "user@example.com", password: "password")) { (result: Result<BaseResponse<User>, Error>) in
     switch result {
     case .success(let response):
         if let user = response.data {
             print("登录成功: \(user.name)")
         }
     case .failure(let error):
         print("登录失败: \(error.localizedDescription)")
     }
 }
 
 // 获取个人资料
 NetworkService.shared.request(UserAPIService.getProfile) { (result: Result<BaseResponse<User>, Error>) in
     switch result {
     case .success(let response):
         if let user = response.data {
             print("个人资料: \(user)")
         }
     case .failure(let error):
         print("获取个人资料失败: \(error.localizedDescription)")
     }
 }
 */ 
