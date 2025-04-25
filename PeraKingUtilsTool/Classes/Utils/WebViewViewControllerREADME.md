# WebViewViewController

WebViewViewController 是一个基于 WKWebView 的视图控制器，用于在应用中展示网页内容，并支持丰富的 JavaScript 与原生交互功能。

## 特点

- 加载和展示网页内容
- 自动为URL添加设备和应用信息参数
- 显示加载进度指示器
- 监控网络连接状态
- 支持多种 JavaScript 与原生的交互方法
- 自动处理 JavaScript 的 alert/confirm/prompt 对话框
- 内置错误处理和网络监控

## 初始化方法

```swift
// 使用 URL 字符串初始化，系统会自动添加必要的设备和应用信息参数
let webVC = WebViewViewController(urlString: "https://example.com")

// 通过导航控制器展示
navigationController?.pushViewController(webVC, animated: true)

// 或者模态展示
let navController = UINavigationController(rootViewController: webVC)
present(navController, animated: true, completion: nil)
```

### 自动添加的URL参数

当初始化WebViewController时，系统会自动为URL添加以下参数：

- husband: 固定值 "ios"
- dongqings: 应用版本号
- criticism: 设备名称 
- stop: 设备IDFV
- indicating: 系统版本
- pushed: 固定值 "perakingapi"
- cautious: 设备IDFV
- boyfine: 当前时间戳

例如，如果初始化URL为 `https://example.com`，最终加载的URL可能是：
```
https://example.com?husband=ios&dongqings=1.0.0&criticism=iPhone&stop=1234-5678&indicating=15.0&pushed=perakingapi&cautious=1234-5678&boyfine=1625097600
```

## JavaScript 与原生交互

WebViewViewController 支持多种 JavaScript 与原生代码的交互方法，使 H5 页面能够调用原生功能。

### 1. 风控埋点 - jellyCucu

用于上报埋点数据。

```javascript
// JavaScript 调用示例
window.webkit.messageHandlers.jellyCucu.postMessage(['truffles', 'intend']);
```

### 2. 页面跳转 - cedarEggp

用于跳转到原生页面或加载新的 H5 页面。

```javascript
// 跳转到 H5 页面
window.webkit.messageHandlers.cedarEggp.postMessage('https://example.com/page');

// 跳转到原生页面 (通过约定的路由格式)
window.webkit.messageHandlers.cedarEggp.postMessage('native://profile');
```

### 3. 关闭当前 H5 - dumplingN

关闭当前 H5 页面，返回上一页。

```javascript
// JavaScript 调用示例
window.webkit.messageHandlers.dumplingN.postMessage('');
```

### 4. 回到 App 首页 - watermelo

返回 App 的首页。

```javascript
// JavaScript 调用示例
window.webkit.messageHandlers.watermelo.postMessage('');
```

### 5. 发送邮件 - kiwiLemon

打开系统邮件应用，并准备发送邮件。此方法会跳出应用，直接打开系统邮件程序。参数格式为 `email:xxxx@example.com`，其中 `xxxx@example.com` 为目标邮箱地址。

```javascript
// JavaScript 调用示例
window.webkit.messageHandlers.kiwiLemon.postMessage('email:contact@example.com');
```

### 6. 应用评分 - chickenJa

弹出 App Store 评分弹窗，请求用户对应用进行评分。

```javascript
// JavaScript 调用示例
window.webkit.messageHandlers.chickenJa.postMessage('');
```

## 完整 JavaScript 调用示例

以下是一个完整的 HTML 示例，演示如何在网页中调用所有原生交互方法：

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WebView 交互示例</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, sans-serif;
            margin: 20px;
            line-height: 1.5;
        }
        button {
            display: block;
            margin: 10px 0;
            padding: 10px 15px;
            background-color: #007AFF;
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            width: 100%;
        }
    </style>
</head>
<body>
    <h1>原生交互测试</h1>
    
    <button onclick="trackEvent()">测试埋点</button>
    <button onclick="navigateToPage()">跳转到新页面</button>
    <button onclick="navigateToNative()">跳转到原生页面</button>
    <button onclick="closeWebView()">关闭当前页面</button>
    <button onclick="goToHomePage()">返回首页</button>
    <button onclick="sendEmail()">发送邮件</button>
    <button onclick="rateApp()">应用评分</button>
    
    <script>
        // 测试埋点
        function trackEvent() {
            window.webkit.messageHandlers.jellyCucu.postMessage(['button_click', 'homepage']);
            alert('埋点已发送');
        }
        
        // 跳转到新H5页面
        function navigateToPage() {
            window.webkit.messageHandlers.cedarEggp.postMessage('https://www.apple.com');
        }
        
        // 跳转到原生页面
        function navigateToNative() {
            window.webkit.messageHandlers.cedarEggp.postMessage('native://profile');
        }
        
        // 关闭当前页面
        function closeWebView() {
            window.webkit.messageHandlers.dumplingN.postMessage('');
        }
        
        // 返回首页
        function goToHomePage() {
            window.webkit.messageHandlers.watermelo.postMessage('');
        }
        
        // 发送邮件
        function sendEmail() {
            // 格式必须是 'email:xxxx@example.com'
            window.webkit.messageHandlers.kiwiLemon.postMessage('email:support@example.com');
        }
        
        // 应用评分
        function rateApp() {
            window.webkit.messageHandlers.chickenJa.postMessage('');
        }
    </script>
</body>
</html>
```

## 注意事项

1. 邮件功能使用系统 URL Scheme 跳转到外部邮件应用，不再使用内置邮件编辑器：
   ```swift
   // 使用URL Scheme打开系统邮件程序
   if let emailURL = URL(string: "mailto:example@email.com") {
       UIApplication.shared.open(emailURL, options: [:], completionHandler: nil)
   }
   ```

2. App 评分功能在同一版本中调用频率有限制，不要过于频繁地请求用户评分。

3. 处理网络错误时，确保提供良好的用户体验，例如显示友好的错误提示和重试选项。

4. 为了性能考虑，不再使用 WebViewController 时应主动调用停止加载方法：
   ```swift
   webView.stopLoading()
   ```

5. 在使用 JavaScript 交互功能时，确保 H5 页面中的代码正确处理了功能不可用的情况，例如检查 `window.webkit` 是否存在。

## 兼容性

- 支持 iOS 11.0 及以上版本
- 使用 WKWebView 和 StoreKit 框架 