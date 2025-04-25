//
//  WebViewViewController.swift
//  PeraKing
//
//  Created by Developer on 2025/4/20.
//

import UIKit
import WebKit
import StoreKit

public class WebViewViewController: UIViewController {
    
    // MARK: - 属性
    
    private var webView: WKWebView!
    private var progressView: UIProgressView!
    private var urlString: String
    private var observation: NSKeyValueObservation?
    
    // MARK: - 初始化
    
    public init(urlString: String) {
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        observation?.invalidate()
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 视图生命周期
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        setupWebView()
        setupProgressView()
        setupNavigationBar()
        loadWebPage()
        
        // 网络状态监控
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged),
            name: NetworkMonitor.Notifications.networkStatusChanged,
            object: nil
        )
    }
    
    // MARK: - 设置视图
    
    private func setupWebView() {
        // 配置WKWebView
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
        // 注册JavaScript处理方法
        userContentController.add(self, name: "jellyCucu")     // 风控埋点
        userContentController.add(self, name: "cedarEggp")     // 跳转原生或H5
        userContentController.add(self, name: "dumplingN")     // 关闭当前H5
        userContentController.add(self, name: "watermelo")     // 回到App首页
        userContentController.add(self, name: "kiwiLemon")     // 发邮件
        userContentController.add(self, name: "chickenJa")     // 系统评分
        
        configuration.userContentController = userContentController
        
        // 创建WKWebView
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view.addSubview(webView)
        
        // 添加进度监听
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        observation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, change in
            guard let self = self else { return }
            self.progressView.progress = Float(webView.estimatedProgress)
            
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                }, completion: { _ in
                    self.progressView.progress = 0
                })
            } else {
                self.progressView.alpha = 1.0
            }
        }
    }
    
    private func setupProgressView() {
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 2)
        progressView.trackTintColor = UIColor.lightGray
        progressView.progressTintColor = UIColor.blue
        progressView.alpha = 0
        view.addSubview(progressView)
    }
    
    private func setupNavigationBar() {
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left")?.withTintColor(.black, renderingMode: .alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(refreshButtonTapped)
        )
    }
    
    private func loadWebPage() {
        // 解析传入的URL字符串
        guard var urlComponents = URLComponents(string: urlString) else {
            showError("Invalid URL")
            return
        }
        
        // 构建附加参数
        let queryParams: [String: String] = [
            "husband": "ios",
            "dongqings": DeviceHelper.appVersion,
            "criticism": DeviceInfoManager.shared.deviceName,
            "stop": DeviceInfoManager.shared.idfv,
            "indicating": DeviceInfoManager.shared.osVersion,
            "pushed": "perakingapi",
            "cautious": DeviceInfoManager.shared.idfv,
            "boyfine": "\(Int(Date().timeIntervalSince1970))",
            "subtly": UserInfo.token
        ]
        
        // 获取现有的查询参数
        var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []
            
        // 添加新参数
        for (key, value) in queryParams {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
            
        // 更新查询参数
        urlComponents.queryItems = queryItems
            
        // 获取完整URL
        guard let finalURL = urlComponents.url else {
            showError("Error constructing URL")
            return
        }
        
        // 使用完整URL创建请求
        let request = URLRequest(url: finalURL, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 15)
        webView.load(request)
    }
    
    // MARK: - 监听网络状态
    
    @objc private func networkStatusChanged(_ notification: Notification) {
        guard let isConnected = notification.userInfo?["isConnected"] as? Bool else { return }
        
        DispatchQueue.main.async {
            if !isConnected {
                self.showNetworkError()
            }
        }
    }
    
    // MARK: - 导航按钮操作
    
    @objc private func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func refreshButtonTapped() {
        webView.reload()
    }
    
    // MARK: - 错误处理
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func showNetworkError() {
        let alert = UIAlertController(title: "网络错误", message: "网络连接已断开，请检查您的网络设置", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - KVO
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            // 进度监听通过observation来处理
        }
    }
    
    // MARK: - JS交互处理方法
    
    /// 处理风控埋点
    private func handleTracking(parameters: [Any]) {
        print("风控埋点: \(parameters)")
        // 在这里实现埋点逻辑
        if let par = parameters as? [String], par.count > 1 {
            API.share.event(EventModel(waste: par[0], sapiist: "10", gym: "", dropped: "\(Date().timeIntervalSince1970)", nowhere: "\(Date().timeIntervalSince1970)")) { _ in
            }
        }
        
    }
    
    /// 处理页面跳转
    private func handleNavigation(parameter: String) {
        print("跳转请求: \(parameter)")
        
        // 判断是原生页面还是H5页面
        if parameter.hasPrefix("http://") || parameter.hasPrefix("https://") {
            // 加载新的H5页面
            let webVC = WebViewViewController(urlString: parameter)
            navigationController?.pushViewController(webVC, animated: true)
        } else {
            // 处理原生页面跳转
            URLRouterManager.shared.handleURL(parameter, from: self)
        }
    }
    
    /// 关闭当前H5页面
    private func closeCurrentPage() {
        if navigationController?.viewControllers.count ?? 0 > 1 {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    /// 返回App首页
    private func backToHomePage() {
        // 返回到根视图控制器
        navigationController?.popToRootViewController(animated: true)
        
        // 如果是模态展示的，则关闭
        if presentingViewController != nil {
            dismiss(animated: true, completion: nil)
        }
    }
    
    /// 发送邮件
    private func sendEmail(emailAddress: String) {
        // 解析传入的邮箱地址，处理"email:xxxxxx"格式
        var parsedEmail = emailAddress
        if emailAddress.contains("email:") {
            let components = emailAddress.components(separatedBy: "email:")
            if components.count > 1 {
                parsedEmail = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        // 构建mailto URL
        guard let emailURL = URL(string: "mailto:\(parsedEmail)") else {
            showError("Invalid email address")
            return
        }
        
        // 检查设备是否可以打开邮件应用
        if UIApplication.shared.canOpenURL(emailURL) {
            UIApplication.shared.open(emailURL, options: [:]) { success in
                if !success {
                    self.showError("The email application cannot be opened")
                }
            }
        } else {
            showError("The device is unable to send emails")
        }
    }
    
    /// 显示App评分
    private func showAppRating() {
        if #available(iOS 14.0, *) {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        } else {
            SKStoreReviewController.requestReview()
        }
    }
}

// MARK: - WKNavigationDelegate
extension WebViewViewController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.alpha = 1.0
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        navigationItem.title = webView.title
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showError("\(error.localizedDescription)")
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // 忽略取消的请求错误
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
            return
        }
        showError("\(error.localizedDescription)")
    }
}

// MARK: - WKUIDelegate
extension WebViewViewController: WKUIDelegate {
    
    // 处理alert
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            completionHandler()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // 处理confirm
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
            completionHandler(false)
        }))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            completionHandler(true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // 处理prompt
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = defaultText
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
            completionHandler(nil)
        }))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            completionHandler(alert.textFields?.first?.text)
        }))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - WKScriptMessageHandler
extension WebViewViewController: WKScriptMessageHandler {
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("收到JS消息: \(message.name), 参数: \(message.body)")
        
        switch message.name {
        case "jellyCucu":
            // 风控埋点
            if let params = message.body as? [Any] {
                handleTracking(parameters: params)
            }
            
        case "cedarEggp":
            // 跳转原生或H5
            if let urlStr = message.body as? String {
                handleNavigation(parameter: urlStr)
            }
            
        case "dumplingN":
            // 关闭当前H5
            closeCurrentPage()
            
        case "watermelo":
            // 回到App首页
            backToHomePage()
            
        case "kiwiLemon":
            // 发送邮件
            if let emailInfo = message.body as? String {
                sendEmail(emailAddress: emailInfo)
            }
            
        case "chickenJa":
            // 显示App评分
            showAppRating()
            
        default:
            print("未知的JS消息类型: \(message.name)")
        }
    }
}
