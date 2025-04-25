import Foundation

/// 字符串和数据格式化工具类
public struct StringFormatter {
    
    // MARK: - 日期格式化
    
    /// 将Date转换为格式化的字符串
    /// - Parameters:
    ///   - date: 日期
    ///   - format: 格式化模板（默认：yyyy-MM-dd HH:mm:ss）
    ///   - timeZone: 时区（默认：当前时区）
    ///   - locale: 地区（默认：当前地区）
    /// - Returns: 格式化后的字符串
    public static func formatDate(
        _ date: Date,
        format: String = "yyyy-MM-dd HH:mm:ss",
        timeZone: TimeZone = .current,
        locale: Locale = .current
    ) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = timeZone
        formatter.locale = locale
        return formatter.string(from: date)
    }
    
    /// 将字符串转换为Date
    /// - Parameters:
    ///   - string: 日期字符串
    ///   - format: 格式化模板（默认：yyyy-MM-dd HH:mm:ss）
    ///   - timeZone: 时区（默认：当前时区）
    ///   - locale: 地区（默认：当前地区）
    /// - Returns: 转换后的Date，失败则返回nil
    public static func parseDate(
        _ string: String,
        format: String = "yyyy-MM-dd HH:mm:ss",
        timeZone: TimeZone = .current,
        locale: Locale = .current
    ) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = timeZone
        formatter.locale = locale
        return formatter.date(from: string)
    }
    
    /// 获取相对时间描述（例如：刚刚、5分钟前、昨天等）
    /// - Parameter date: 日期
    /// - Returns: 相对时间字符串
    public static func relativeTimeString(from date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: now)
        
        if let year = components.year, year > 0 {
            return "\(year)年前"
        } else if let month = components.month, month > 0 {
            return "\(month)个月前"
        } else if let day = components.day, day > 0 {
            if day == 1 {
                return "昨天"
            } else if day == 2 {
                return "前天"
            } else if day < 7 {
                return "\(day)天前"
            } else {
                let weeks = day / 7
                return "\(weeks)周前"
            }
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)小时前"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)分钟前"
        } else if let second = components.second, second > 0 {
            return "\(second)秒前"
        } else {
            return "刚刚"
        }
    }
    
    /// 格式化文件大小
    /// - Parameter bytes: 字节数
    /// - Returns: 格式化后的文件大小字符串（例如：1.5 MB）
    public static func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    // MARK: - 文本处理
    
    /// 截取字符串到指定长度，如果超出长度则添加省略号
    /// - Parameters:
    ///   - text: 原始文本
    ///   - length: 最大长度
    ///   - suffix: 后缀（默认为"..."）
    /// - Returns: 截取后的文本
    public static func truncate(_ text: String, length: Int, suffix: String = "...") -> String {
        if text.count <= length {
            return text
        }
        
        let index = text.index(text.startIndex, offsetBy: length)
        return text[..<index] + suffix
    }
    
    /// 从HTML字符串中提取纯文本
    /// - Parameter html: HTML字符串
    /// - Returns: 提取的纯文本
    public static func plainText(from html: String) -> String {
        guard let data = html.data(using: .utf8) else {
            return html
        }
        
        do {
            let attributedString = try NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html,
                          .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil
            )
            return attributedString.string
        } catch {
            return html
        }
    }
    
    /// 移除字符串中的HTML标签
    /// - Parameter string: 包含HTML标签的字符串
    /// - Returns: 移除HTML标签后的字符串
    public static func removeHTMLTags(from string: String) -> String {
        return string.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression,
            range: nil
        )
    }
    
    // MARK: - 验证格式
    
    /// 验证邮箱格式是否正确
    /// - Parameter email: 邮箱
    /// - Returns: 是否是有效的邮箱
    public static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    /// 验证URL格式是否正确
    /// - Parameter urlString: URL字符串
    /// - Returns: 是否是有效的URL
    public static func isValidURL(_ urlString: String) -> Bool {
        return URL(string: urlString) != nil
    }

    /// 格式化手机号（3-4-4格式）
    /// - Parameter phoneNumber: 手机号
    /// - Returns: 格式化后的手机号
    public static func formatPhoneNumber(_ phoneNumber: String) -> String {
        let cleanNumber = phoneNumber.replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
        
        guard cleanNumber.count == 11 else {
            return phoneNumber
        }
        
        let prefix = cleanNumber.prefix(3)
        let middle = cleanNumber.dropFirst(3).prefix(4)
        let suffix = cleanNumber.dropFirst(7)
        
        return "\(prefix) \(middle) \(suffix)"
    }
    
    /// 隐藏手机号中间部分
    /// - Parameter phoneNumber: 手机号
    /// - Returns: 隐藏中间部分的手机号
    public static func maskPhoneNumber(_ phoneNumber: String) -> String {
        let cleanNumber = phoneNumber.replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
        
        guard cleanNumber.count == 11 else {
            return phoneNumber
        }
        
        let prefix = cleanNumber.prefix(3)
        let suffix = cleanNumber.suffix(4)
        
        return "\(prefix)****\(suffix)"
    }
    
    /// 隐藏邮箱地址中间部分
    /// - Parameter email: 邮箱
    /// - Returns: 隐藏中间部分的邮箱
    public static func maskEmail(_ email: String) -> String {
        let components = email.components(separatedBy: "@")
        
        guard components.count == 2 else {
            return email
        }
        
        var username = components[0]
        let domain = components[1]
        
        if username.count > 2 {
            let visiblePrefix = String(username.prefix(2))
            username = "\(visiblePrefix)****"
        }
        
        return "\(username)@\(domain)"
    }
    
    /// 首字母大写
    /// - Parameter string: 原始字符串
    /// - Returns: 首字母大写的字符串
    public static func capitalize(_ string: String) -> String {
        return string.prefix(1).capitalized + string.dropFirst()
    }
} 