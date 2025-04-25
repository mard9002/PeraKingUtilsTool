import UIKit

// MARK: - UIView Extensions
public extension UIView {
    /// 添加圆角
    @discardableResult
    func cornerRadius(_ radius: CGFloat, masksToBounds: Bool = true) -> Self {
        layer.cornerRadius = radius
        layer.masksToBounds = masksToBounds
        return self
    }
    
    /// 添加边框
    @discardableResult
    func border(width: CGFloat, color: UIColor) -> Self {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
        return self
    }
    
    /// 添加阴影
    @discardableResult
    func shadow(color: UIColor, offset: CGSize, radius: CGFloat, opacity: Float) -> Self {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
        return self
    }
    
    /// 设置视图的尺寸
    @discardableResult
    func size(_ size: CGSize) -> Self {
        var frame = self.frame
        frame.size = size
        self.frame = frame
        return self
    }
    
    /// 设置视图的位置
    @discardableResult
    func origin(_ origin: CGPoint) -> Self {
        var frame = self.frame
        frame.origin = origin
        self.frame = frame
        return self
    }
    
    /// 从XIB加载视图
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}

// MARK: - UIColor Extensions
public extension UIColor {
    /// 使用十六进制字符串创建颜色
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "无效的十六进制颜色代码")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
    
    /// 适配深色模式颜色
    static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ? dark : light
            }
        } else {
            return light
        }
    }
}

// MARK: - UIImage Extensions
public extension UIImage {
    /// 调整图片大小
    func resize(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    /// 创建纯色图片
    static func from(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 图片圆角处理
    func withRoundedCorners(radius: CGFloat) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context = UIGraphicsGetCurrentContext()!
        let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        context.addPath(path.cgPath)
        context.clip()
        draw(in: rect)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return roundedImage
    }
    
    
    /// 根据目标宽度计算等比例高度
    /// - Parameter targetWidth: 目标宽度
    /// - Returns: 计算后的高度（若图片为空则返回0）
    func height(forTargetWidth targetWidth: CGFloat) -> CGFloat {
        guard size.width > 0 && size.height > 0 else {
            return 0
        }
        let ratio = size.height / size.width
        return targetWidth * ratio
    }
    
    /// 根据目标高度计算等比例宽度
    /// - Parameter targetHeight: 目标高度
    /// - Returns: 计算后的宽度（若图片为空则返回0）
    func width(forTargetHeight targetHeight: CGFloat) -> CGFloat {
        guard size.width > 0 && size.height > 0 else {
            return 0
        }
        let ratio = size.width / size.height
        return targetHeight * ratio
    }
}

public extension UILabel {
    /// 设置行间距
    /// - Parameters:
    ///   - lineSpacing: 行间距
    func setLineSpacing(_ lineSpacing: CGFloat) {
        guard let text = self.text else { return }
        
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = self.textAlignment
        
        attributedString.addAttribute(.paragraphStyle,
                                      value: paragraphStyle,
                                      range: NSRange(location: 0, length: text.count))
        
        self.attributedText = attributedString
    }
}

// MARK: - UIButton Extensions
public extension UIButton {
    /// 设置按钮背景颜色
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        setBackgroundImage(UIImage.from(color: color), for: state)
    }
    
    /// 设置按钮标题（包括间距、字体、颜色等）
    @discardableResult
    func configure(title: String? = nil, 
                   font: UIFont? = nil, 
                   titleColor: UIColor? = nil,
                   for state: UIControl.State = .normal) -> Self {
        if let title = title {
            setTitle(title, for: state)
        }
        
        if let font = font {
            titleLabel?.font = font
        }
        
        if let titleColor = titleColor {
            setTitleColor(titleColor, for: state)
        }
        
        return self
    }
    
    /// 为按钮添加点击事件
    func addAction(for controlEvents: UIControl.Event = .touchUpInside, _ closure: @escaping () -> Void) {
        @objc class ClosureSleeve: NSObject {
            let closure: () -> Void
            init(_ closure: @escaping () -> Void) { self.closure = closure }
            @objc func invoke() { closure() }
        }
        let sleeve = ClosureSleeve(closure)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
        objc_setAssociatedObject(self, "\(UUID())", sleeve, .OBJC_ASSOCIATION_RETAIN)
    }
}

// MARK: - UITableView Extensions
public extension UITableView {
    /// 注册单元格
    func register<T: UITableViewCell>(cellType: T.Type) {
        let className = String(describing: cellType)
        register(cellType, forCellReuseIdentifier: className)
    }
    
    /// 注册XIB单元格
    func registerNib<T: UITableViewCell>(cellType: T.Type) {
        let className = String(describing: cellType)
        let nib = UINib(nibName: className, bundle: nil)
        register(nib, forCellReuseIdentifier: className)
    }
    
    /// 获取重用单元格
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        let className = String(describing: T.self)
        guard let cell = dequeueReusableCell(withIdentifier: className, for: indexPath) as? T else {
            fatalError("未能从标识符 \(className) 获取到单元格")
        }
        return cell
    }
}

// MARK: - UICollectionView Extensions
public extension UICollectionView {
    /// 注册单元格
    func register<T: UICollectionViewCell>(cellType: T.Type) {
        let className = String(describing: cellType)
        register(cellType, forCellWithReuseIdentifier: className)
    }
    
    /// 注册XIB单元格
    func registerNib<T: UICollectionViewCell>(cellType: T.Type) {
        let className = String(describing: cellType)
        let nib = UINib(nibName: className, bundle: nil)
        register(nib, forCellWithReuseIdentifier: className)
    }
    
    /// 获取重用单元格
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        let className = String(describing: T.self)
        guard let cell = dequeueReusableCell(withReuseIdentifier: className, for: indexPath) as? T else {
            fatalError("未能从标识符 \(className) 获取到单元格")
        }
        return cell
    }
} 
