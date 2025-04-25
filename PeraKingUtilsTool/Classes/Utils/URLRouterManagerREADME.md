# URLRouterManager 路由管理工具

`URLRouterManager` 是一个用于处理应用内部路由和外部链接的工具类。它能够根据URL格式自动导航到应用的不同页面，也可以打开外部网页。该工具采用单例模式设计，确保在整个应用程序中使用统一的路由处理逻辑。

## 功能特点

- 处理应用内自定义URL scheme路由
- 智能解析URL路径和参数
- 处理外部网页链接
- 支持完成回调处理
- 支持在AppDelegate或其他适当位置集中配置路由处理逻辑
- 去除硬编码的页面跳转逻辑，支持灵活配置

## 路由类型

| 路由 | URL路径 | 说明 |
|------|--------|------|
| 设置页 | `/leekEggplant` | 导航到应用设置页面 |
| 首页 | `/soybeanDillU` | 导航到应用首页 |
| 登录页 | `/croissantTac` | 以模态方式显示登录页面 |
| 产品详情页 | `/turnipSauceM` | 导航到产品详情页面，支持参数 |

## 使用方法

### 初始化与配置

`URLRouterManager`使用单例模式，通过`shared`属性访问。在应用启动时（如 AppDelegate 中）需要注册各种路由类型的处理器：

```swift
// 在 AppDelegate 的 application(_:didFinishLaunchingWithOptions:) 方法中配置
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // 配置URL路由管理器
    configureURLRouter()
    
    return true
}

private func configureURLRouter() {
    let router = URLRouterManager.shared
    
    // 注册设置页面路由处理器
    router.registerRouteHandler(for: .settings) { parameters, sourceVC, completion in
        let settingsVC = PeraKingSettingsViewController()
        sourceVC.navigationController?.pushViewController(settingsVC, animated: true)
        completion?(true)
    }
    
    // 注册首页路由处理器
    router.registerRouteHandler(for: .home) { parameters, sourceVC, completion in
        // 如果当前已经在首页，不需要跳转
        if sourceVC is PeraKingHomeViewController {
            completion?(true)
            return
        }
        
        // 跳转到首页
        let homeVC = PeraKingHomeViewController()
        
        // 设置为根视图控制器或推入导航栈
        if let navigationController = sourceVC.navigationController {
            navigationController.popToRootViewController(animated: false)
            if let rootVC = navigationController.viewControllers.first,
               !(rootVC is PeraKingHomeViewController) {
                navigationController.setViewControllers([homeVC], animated: true)
            }
        } else {
            let navController = UINavigationController(rootViewController: homeVC)
            UIApplication.shared.windows.first?.rootViewController = navController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
        
        completion?(true)
    }
    
    // 注册登录页面路由处理器
    router.registerRouteHandler(for: .login) { parameters, sourceVC, completion in
        let loginVC = PeraKingLoginViewController()
        
        // 如果是模态呈现的界面，直接dismiss后再呈现登录界面
        if sourceVC.presentingViewController != nil {
            sourceVC.dismiss(animated: true) {
                if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                    rootVC.present(loginVC, animated: true, completion: nil)
                }
            }
        } else {
            loginVC.modalPresentationStyle = .fullScreen
            sourceVC.present(loginVC, animated: true, completion: nil)
        }
        
        completion?(true)
    }
    
    // 注册产品详情页面路由处理器
    router.registerRouteHandler(for: .productDetail) { parameters, sourceVC, completion in
        let productDetailVC = PeraKingProductDetailViewController()
        
        // 设置产品ID
        if let arched = parameters?["arched"] as? Int {
            productDetailVC.productId = String(arched)
        }
        
        sourceVC.navigationController?.pushViewController(productDetailVC, animated: true)
        completion?(true)
    }
    
    // 注册Web路由处理器
    router.registerWebRouteHandler { url, sourceVC, completion in
        let webVC = PeraKingWebViewController()
        webVC.url = url
        sourceVC.navigationController?.pushViewController(webVC, animated: true)
        completion?(true)
    }
}
```

### 处理URL字符串

配置完成后，使用`handleURL`方法处理URL字符串：

```swift
// 示例1：处理设置页面URL
URLRouterManager.shared.handleURL("peraking://king.pera.app/leekEggplant", from: self) { success in
    if success {
        print("成功跳转到设置页面")
    } else {
        print("跳转失败")
    }
}

// 示例2：处理产品详情页URL（带参数）
URLRouterManager.shared.handleURL("peraking://king.pera.app/turnipSauceM?arched=12345", from: self) { success in
    if success {
        print("成功跳转到产品详情页面")
    } else {
        print("跳转失败")
    }
}

// 示例3：处理外部网页URL
URLRouterManager.shared.handleURL("https://www.example.com", from: self) { success in
    if success {
        print("成功打开网页")
    } else {
        print("打开网页失败")
    }
}
```

### 直接导航到指定页面

使用`navigateTo`方法直接导航到指定页面：

```swift
// 示例1：导航到设置页面
URLRouterManager.shared.navigateTo(routeType: .settings, from: self) { success in
    print("导航结果: \(success)")
}

// 示例2：导航到产品详情页面（带参数）
URLRouterManager.shared.navigateTo(
    routeType: .productDetail,
    parameters: ["arched": 12345],
    from: self
) { success in
    print("导航结果: \(success)")
}
```

## 处理外部URL打开应用

在 AppDelegate 中实现 `application(_:open:options:)` 方法，处理外部应用打开URL的情况：

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    // 处理通过URL scheme打开应用的情况
    let urlString = url.absoluteString
    
    // 获取当前顶层视图控制器
    if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
        let topViewController = getTopViewController(rootViewController)
        
        // 使用URLRouterManager处理URL
        URLRouterManager.shared.handleURL(urlString, from: topViewController) { success in
            print("处理外部URL结果: \(success)")
        }
        
        return true
    }
    
    return false
}

// 递归获取顶层视图控制器的辅助方法
private func getTopViewController(_ viewController: UIViewController) -> UIViewController {
    if let presented = viewController.presentedViewController {
        return getTopViewController(presented)
    }
    
    if let navigationController = viewController as? UINavigationController {
        return getTopViewController(navigationController.visibleViewController ?? navigationController)
    }
    
    if let tabBarController = viewController as? UITabBarController,
       let selected = tabBarController.selectedViewController {
        return getTopViewController(selected)
    }
    
    return viewController
}
```

## URL规则说明

### 应用内部路由

应用内部路由URL必须以`peraking://king.pera.app`开头，后面跟路径和可选参数：

- 设置页：`peraking://king.pera.app/leekEggplant`
- 首页：`peraking://king.pera.app/soybeanDillU`
- 登录页：`peraking://king.pera.app/croissantTac`
- 产品详情页：`peraking://king.pera.app/turnipSauceM?arched=123`（其中`arched`是产品ID）

### 外部链接

以`http://`或`https://`开头的URL将被视为外部链接，会使用注册的Web路由处理器进行处理。

## 扩展路由类型

如需添加新的路由类型，只需在 RouteType 枚举中添加新的 case，并在配置中注册对应的处理器：

```swift
// 在 URLRouterManager.swift 中添加新的路由类型
public enum RouteType: String {
    // 现有类型
    case settings = "/leekEggplant"
    case home = "/soybeanDillU"
    case login = "/croissantTac"
    case productDetail = "/turnipSauceM"
    
    // 新增类型
    case userProfile = "/userProfile"
    
    case unknown
}

// 在配置方法中注册新的处理器
router.registerRouteHandler(for: .userProfile) { parameters, sourceVC, completion in
    let userProfileVC = UserProfileViewController()
    
    // 设置用户ID参数
    if let userId = parameters?["userId"] as? String {
        userProfileVC.userId = userId
    }
    
    sourceVC.navigationController?.pushViewController(userProfileVC, animated: true)
    completion?(true)
}
```

## 注意事项

1. 必须在应用启动时（如AppDelegate中）注册所有路由处理器
2. 在使用`handleURL`和`navigateTo`方法时，必须提供当前视图控制器作为参数
3. 产品详情页需要`arched`参数，代表产品ID
4. 所有方法都提供了完成回调，可用于处理跳转成功或失败的情况
5. 不符合应用内部路由规则且不是`http/https`的URL将无法处理
6. 未注册处理器的路由类型将无法处理 