import UIKit

/// 应用程序常量
@objc public class Constants: NSObject {
    
    /// 屏幕常量
    @objc public class Screen: NSObject {
        @objc public static let width = UIScreen.main.bounds.width
        @objc public static let height = UIScreen.main.bounds.height
        @objc public static let scale = UIScreen.main.scale
        @objc public static let isWideScreen = width >= 375.0
        
        // 安全区域兼容
        @objc public static var safeAreaTop: CGFloat {
            if #available(iOS 11.0, *) {
                return UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
            }
            return 20
        }
        
        @objc public static var safeAreaBottom: CGFloat {
            if #available(iOS 11.0, *) {
                return UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
            }
            return 0
        }
        
        @objc public static var statusBarHeight: CGFloat {
            if #available(iOS 13.0, *) {
                return UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            } else {
                return UIApplication.shared.statusBarFrame.height
            }
        }
        
        @objc public static let navBarHeight: CGFloat = 44.0
        @objc public static let tabBarHeight: CGFloat = 49.0
        @objc public static let navBarWithStatusBarHeight = statusBarHeight + navBarHeight
    }
    
    /// 颜色常量
    @objc public class Colors: NSObject {
        // 品牌颜色
        @objc public static let primary = UIColor(hex: "#FFF1EA")
        @objc public static let buttonColor = UIColor(hex: "#FF8C00")
        @objc public static let button2Color = UIColor(hex: "#FB0301")

        // 文本颜色
        @objc public static let textPrimary = UIColor(hex: "#000000")
        @objc public static let textWhite = UIColor.white
        @objc public static let textTertiary = UIColor(hex: "#666666", alpha: 1.0)
        @objc public static let codeTextColor = UIColor(hex: "#FFF6EC", alpha: 1.0)
        @objc public static let privacyBgColor = UIColor(hex: "#FF8E0F", alpha: 1.0)
        @objc public static let homeBgColor = UIColor(hex: "#FFF1EA", alpha: 1.0)

    }
    
    /// 字体常量
    @objc public class Fonts: NSObject {
        // 标题字体
        @objc public static let largeTitle = UIFont.systemFont(ofSize: 34, weight: .bold)
        @objc public static let title1 = UIFont.systemFont(ofSize: 28, weight: .bold)
        @objc public static let title2 = UIFont.systemFont(ofSize: 22, weight: .bold)
        @objc public static let title3 = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        // 正文字体
        @objc public static let body = UIFont.systemFont(ofSize: 17, weight: .regular)
        @objc public static let bodyBold = UIFont.systemFont(ofSize: 17, weight: .semibold)
        @objc public static let callout = UIFont.systemFont(ofSize: 16, weight: .regular)
        @objc public static let subheadline = UIFont.systemFont(ofSize: 15, weight: .regular)
        @objc public static let subheadlineBold = UIFont.systemFont(ofSize: 15, weight: .semibold)
        
        // 辅助字体
        @objc public static let footnote = UIFont.systemFont(ofSize: 13, weight: .regular)
        @objc public static let footnoteBold = UIFont.systemFont(ofSize: 13, weight: .semibold)
        @objc public static let caption1 = UIFont.systemFont(ofSize: 12, weight: .regular)
        @objc public static let caption2 = UIFont.systemFont(ofSize: 11, weight: .regular)
    }
    
    /// 布局常量
    @objc public class Layout: NSObject {
        // 通用间距
        @objc public static let spacing: CGFloat = 8
        @objc public static let spacingSmall: CGFloat = 4
        @objc public static let spacingMedium: CGFloat = 12
        @objc public static let spacingLarge: CGFloat = 16
        @objc public static let spacingExtraLarge: CGFloat = 24
        
        // 边距
        @objc public static let margin: CGFloat = 16
        @objc public static let marginSmall: CGFloat = 8
        @objc public static let marginMedium: CGFloat = 20
        @objc public static let marginLarge: CGFloat = 32
        
        // 圆角
        @objc public static let cornerRadius: CGFloat = 8
        @objc public static let cornerRadiusSmall: CGFloat = 4
        @objc public static let cornerRadiusMedium: CGFloat = 12
        @objc public static let cornerRadiusLarge: CGFloat = 16
        
        // 卡片尺寸
        @objc public static let cardPadding: CGFloat = 16
        @objc public static let cardPaddingSmall: CGFloat = 12
        
        // 按钮尺寸
        @objc public static let buttonHeight: CGFloat = 44
        @objc public static let buttonHeightSmall: CGFloat = 32
        @objc public static let buttonHeightLarge: CGFloat = 54
        
        // 输入框高度
        @objc public static let textFieldHeight: CGFloat = 44
    }
    
    /// 动画常量
    @objc public class Animation: NSObject {
        @objc public static let defaultDuration: TimeInterval = 0.3
        @objc public static let quickDuration: TimeInterval = 0.15
        @objc public static let slowDuration: TimeInterval = 0.5
        
        @objc public static let springDamping: CGFloat = 0.7
        @objc public static let springVelocity: CGFloat = 0.5
    }
    
    /// 存储相关常量
    @objc public class Storage: NSObject {
        @objc public static let userDefaultsPrefix = "com.anytime.test."
        
        // UserDefaults键名
        @objc public static let isFirstLaunch = userDefaultsPrefix + "isFirstLaunch"
        @objc public static let lastVisitDate = userDefaultsPrefix + "lastVisitDate"
        @objc public static let userProfile = userDefaultsPrefix + "userProfile"
        @objc public static let authToken = userDefaultsPrefix + "authToken"
        
        // 缓存目录名
        @objc public static let imageCacheDirectory = "ImageCache"
        @objc public static let documentCacheDirectory = "DocumentCache"
    }
    
    /// API相关常量
    @objc public class APIURL: NSObject {
        #if DEBUG
        @objc public static let baseURL = "http://8.220.140.188:9793/perakingapi"
        #else
        @objc public static let baseURL = "http://8.220.140.188:9793/"
        #endif
        
        @objc public static let baseH5Url = "http://8.220.140.188:9793"
        
        @objc public static let timeout: TimeInterval = 30
        
        // 响应码
        public struct ResponseCodes {
            public static let success = 200
            public static let created = 201
            public static let badRequest = 400
            public static let unauthorized = 401
            public static let forbidden = 403
            public static let notFound = 404
            public static let serverError = 500
        }
    }
    
    /// 通知名称
    @objc public class Notifications: NSObject {
        @objc public static let userDidLogin = Notification.Name(Storage.userDefaultsPrefix + "userDidLogin")
        
        @objc public static let switchLogin = Notification.Name(Storage.userDefaultsPrefix + "switchLogin")
        
        @objc public static let userDidLogout = Notification.Name(Storage.userDefaultsPrefix + "userDidLogout")
        
        @objc public static let fbsdk = Notification.Name(Storage.userDefaultsPrefix + "fbsdk")
        
        @objc public static let profileDidUpdate = Notification.Name(Storage.userDefaultsPrefix + "profileDidUpdate")
        @objc public static let networkStatusChanged = Notification.Name("networkStatusChanged")
        @objc public static let newMessageReceived = Notification.Name(Storage.userDefaultsPrefix + "newMessageReceived")
    }
} 
