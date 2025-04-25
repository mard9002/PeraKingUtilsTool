import UIKit
import SafariServices

/// URL路由管理器，用于处理应用内部路由和外部链接
public class URLRouterManager {
    
    // MARK: - 单例
    
    public static let shared = URLRouterManager()
    
    private init() {}
    
    // MARK: - 常量
    
    /// 应用的URL Scheme
    private let appScheme = "peraking://king.pera.app"
    
    /// 路由类型
    public enum RouteType: String {
        /// 设置页
        case settings = "/leekEggplant"
        
        /// 首页
        case home = "/soybeanDillU"
        
        /// 登录页
        case login = "/croissantTac"
        
        /// 产品详情页
        case productDetail = "/turnipSauceM"
        
        /// 未知类型
        case unknown
    }
    
    // MARK: - 类型定义
    
    /// 路由处理器闭包类型，用于处理不同类型的路由
    public typealias RouteHandler = (_ parameters: [String: Any]?, _ sourceViewController: UIViewController, _ completion: ((Bool) -> Void)?) -> Void
    
    /// Web路由处理器闭包类型，用于处理外部URL
    public typealias WebRouteHandler = (_ url: String, _ sourceViewController: UIViewController, _ completion: ((Bool) -> Void)?) -> Void
    
    // MARK: - 私有属性
    
    /// 路由处理器字典，存储不同路由类型的处理逻辑
    private var routeHandlers: [RouteType: RouteHandler] = [:]
    
    /// Web路由处理器，处理外部URL
    private var webRouteHandler: WebRouteHandler?
    
    // MARK: - 公共方法
    
    /// 注册路由处理器
    /// - Parameters:
    ///   - routeType: 路由类型
    ///   - handler: 处理器闭包
    public func registerRouteHandler(for routeType: RouteType, handler: @escaping RouteHandler) {
        routeHandlers[routeType] = handler
    }
    
    /// 注册Web路由处理器
    /// - Parameter handler: 处理器闭包
    public func registerWebRouteHandler(_ handler: @escaping WebRouteHandler) {
        webRouteHandler = handler
    }
    
    /// 处理URL路由
    /// - Parameters:
    ///   - urlString: URL字符串
    ///   - sourceViewController: 来源视图控制器
    ///   - completion: 完成回调，返回是否成功处理路由
    public func handleURL(_ urlString: String, from sourceViewController: UIViewController, completion: ((Bool) -> Void)? = nil) {
        guard !urlString.isEmpty else {
            completion?(false)
            return
        }
        
        // 检查是否是应用内部路由
        if urlString.hasPrefix(appScheme) {
            handleInternalURL(urlString, from: sourceViewController, completion: completion)
        } else if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
            // 处理外部URL（网页）
            handleExternalURL(urlString, from: sourceViewController, completion: completion)
        } else {
            // 无法处理的URL类型
            print("无法处理的URL类型: \(urlString)")
            completion?(false)
        }
    }
    
    /// 直接导航到指定路由类型
    /// - Parameters:
    ///   - routeType: 路由类型
    ///   - parameters: 路由参数
    ///   - sourceViewController: 来源视图控制器
    ///   - completion: 完成回调，返回是否成功处理路由
    public func navigateTo(routeType: RouteType, parameters: [String: Any]? = nil, from sourceViewController: UIViewController, completion: ((Bool) -> Void)? = nil) {
        if let handler = routeHandlers[routeType] {
            handler(parameters, sourceViewController, completion)
        } else {
            print("未找到路由类型处理器: \(routeType)")
            completion?(false)
        }
    }
    
    // MARK: - 私有方法
    
    /// 处理应用内部URL
    private func handleInternalURL(_ urlString: String, from sourceViewController: UIViewController, completion: ((Bool) -> Void)? = nil) {
        guard let url = URL(string: urlString) else {
            completion?(false)
            return
        }
        
        // 解析路径
        let path = url.path
        
        // 解析查询参数
        var parameters: [String: Any] = [:]
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            for item in queryItems {
                if let value = item.value {
                    // 对于数字类型的参数，尝试转换为Int
                    if let intValue = Int(value) {
                        parameters[item.name] = intValue
                    } else {
                        parameters[item.name] = value
                    }
                }
            }
        }
        
        // 根据路径判断路由类型
        let routeType = RouteType(rawValue: path) ?? .unknown
        
        // 执行导航
        navigateTo(routeType: routeType, parameters: parameters, from: sourceViewController, completion: completion)
    }
    
    /// 处理外部URL（网页）
    private func handleExternalURL(_ urlString: String, from sourceViewController: UIViewController, completion: ((Bool) -> Void)? = nil) {
        
        if let webHandler = webRouteHandler {
            webHandler(urlString, sourceViewController, completion)
        } else {
            print("未注册Web路由处理器")
            completion?(false)
        }
    }
    
}
