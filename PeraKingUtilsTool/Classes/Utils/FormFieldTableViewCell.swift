import UIKit

// 字段类型枚举
public enum FieldType {
    case selectable  // 可选择的字段（如职业选择器）
    case editable    // 可编辑的字段（如公司名称输入）
}

public class FormFieldTableViewCell: UITableViewCell {
    
    // MARK: - 常量
    public static let reuseIdentifier = "FormFieldTableViewCell"
    
    // MARK: - 属性
    private let containerView = UIView()
    private let customTextField = CustomTextField()
    
    // 回调闭包
    public var onFieldTapped: (() -> Void)?
    public var onTextChanged: ((String) -> Void)?
    
    public var isNumber: Bool = false {
        didSet {
            customTextField.isNumber = isNumber
        }
    }
    
    public var contentBg: UIColor? {
        didSet {
            customTextField.contentBg = contentBg
        }
    }
    
    // MARK: - 初始化
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 视图设置
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .clear // 浅米色背景
        
        // 设置容器视图
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 20
        contentView.addSubview(containerView)
        
        // 设置自定义文本字段
        customTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(customTextField)
        
        // 设置自定义文本字段事件
        customTextField.onTap = { [weak self] in
            self?.onFieldTapped?()
        }
        
        // 设置文本变化回调
        customTextField.onTextChanged = { [weak self] newText in
            self?.onTextChanged?(newText)
        }
        
        // 设置约束
        NSLayoutConstraint.activate([
            // 容器视图约束
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // 自定义文本字段约束
            customTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            customTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            customTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            customTextField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
        ])
    }
    
    // MARK: - 公共配置方法
    
    /// 配置可选择字段
    /// - Parameters:
    ///   - title: 字段标题
    ///   - value: 当前值
    ///   - placeholder: 占位符文本
    public func configureAsSelectable(title: String, value: String = "", placeholder: String = "Please Select") {
        customTextField.title = title
        customTextField.value = value
        customTextField.placeholder = placeholder
        customTextField.isEditable = false
        customTextField.rightImage = UIImage(systemName: "chevron.right")
    }
    
    /// 配置可编辑字段
    /// - Parameters:
    ///   - title: 字段标题
    ///   - value: 当前值
    ///   - placeholder: 占位符文本
    public func configureAsEditable(title: String, value: String = "", placeholder: String) {
        customTextField.title = title
        customTextField.value = value
        customTextField.placeholder = placeholder
        customTextField.isEditable = true
        customTextField.rightImage = nil
    }
    
    /// 根据字段类型配置单元格
    /// - Parameters:
    ///   - type: 字段类型
    ///   - title: 字段标题
    ///   - value: 当前值
    ///   - placeholder: 占位符文本
    public func configure(type: FieldType, title: String, value: String = "", placeholder: String) {
        switch type {
        case .selectable:
            configureAsSelectable(title: title, value: value, placeholder: placeholder)
        case .editable:
            configureAsEditable(title: title, value: value, placeholder: placeholder)
        }
    }
    
    /// 获取当前输入值
    public func getValue() -> String {
        return customTextField.getInputValue()
    }
    
    // MARK: - 重置
    public override func prepareForReuse() {
        super.prepareForReuse()
        customTextField.value = ""
        customTextField.title = ""
        customTextField.placeholder = ""
        onFieldTapped = nil
        onTextChanged = nil
    }
}

// MARK: - 使用示例
class FormFieldTableViewExample {
    
    public func setupTableView(_ tableView: UITableView) {
        // 注册单元格
        tableView.register(FormFieldTableViewCell.self, forCellReuseIdentifier: FormFieldTableViewCell.reuseIdentifier)
        
        // 设置行高
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 0.98, green: 0.96, blue: 0.94, alpha: 1.0) // 浅米色背景
    }
    
    // UITableViewDataSource示例方法
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FormFieldTableViewCell.reuseIdentifier, for: indexPath) as? FormFieldTableViewCell else {
            return UITableViewCell()
        }
        
        return cell
    }
} 
