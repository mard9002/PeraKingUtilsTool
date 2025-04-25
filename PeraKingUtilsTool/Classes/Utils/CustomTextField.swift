import UIKit

public class CustomTextField: UIView {
    
    // MARK: - Properties
    private let titleLabel = UILabel()
    private let contentView = UIView()
    private let textField = UITextField()
    private let rightImageView = UIImageView()
    
    public var placeholder: String = "" {
        didSet {
            textField.placeholder = placeholder
        }
    }
    
    public var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    public var value: String = "" {
        didSet {
            textField.text = value
        }
    }
    
    public var rightImage: UIImage? = UIImage(systemName: "chevron.right") {
        didSet {
            rightImageView.image = rightImage
            rightImageView.isHidden = rightImage == nil
        }
    }
    public var contentBg: UIColor? {
        didSet {
            contentView.backgroundColor = contentBg
        }
    }
    // 点击回调
    public var onTap: (() -> Void)?
    
    // 文本变化回调
    public var onTextChanged: ((String) -> Void)?
    
    // 是否为可输入模式
    public var isEditable: Bool = false {
        didSet {
            updateMode()
        }
    }
    
    public var isNumber: Bool = false {
        didSet {
            if isNumber {
                self.textField.keyboardType = .numberPad
            } else {
                self.textField.keyboardType = .default
            }
        }
    }
    
    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        setupTitleLabel()
        setupContentView()
        setupTextField()
        setupRightImageView()
        setupGestureRecognizer()
        
        // 初始更新模式
        updateMode()
    }
    
    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        titleLabel.textColor = .black
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func setupContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 33)
        ])
    }
    
    private func setupTextField() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.textColor = .black
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.delegate = self
        // 添加文本变化事件监听
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        contentView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textField.heightAnchor.constraint(equalToConstant: 33)
        ])
    }
    
    private func setupRightImageView() {
        rightImageView.translatesAutoresizingMaskIntoConstraints = false
        rightImageView.contentMode = .scaleAspectFit
        rightImageView.tintColor = .gray
        rightImageView.image = UIImage(systemName: "chevron.right")
        contentView.addSubview(rightImageView)
        
        NSLayoutConstraint.activate([
            rightImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rightImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rightImageView.widthAnchor.constraint(equalToConstant: 20),
            rightImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        contentView.addGestureRecognizer(tapGesture)
        contentView.isUserInteractionEnabled = true
    }
    
    // 更新UI模式（可点击或可输入）
    private func updateMode() {
        if isEditable {
            // 输入模式
            textField.isUserInteractionEnabled = true
            textField.isEnabled = true
            rightImageView.isHidden = true
            contentView.gestureRecognizers?.forEach { contentView.removeGestureRecognizer($0) }
        } else {
            // 点击模式 - 使用textField但禁用输入
            textField.isUserInteractionEnabled = false
            textField.isEnabled = false
            rightImageView.isHidden = false
            
            // 确保手势识别器已添加
            if contentView.gestureRecognizers?.isEmpty ?? true {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
                contentView.addGestureRecognizer(tapGesture)
            }
        }
    }
    
    // MARK: - Actions
    @objc private func viewTapped() {
        if !isEditable {
            onTap?()
        }
    }
    
    // 文本字段文本变化处理
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let newText = textField.text ?? ""
        value = newText
        // 触发文本变化回调
        onTextChanged?(newText)
    }
    
    // 提供获取输入值的方法
    func getInputValue() -> String {
        return textField.text ?? ""
    }
    
    // 设置文本框代理
    func setTextFieldDelegate(_ delegate: UITextFieldDelegate) {
        textField.delegate = delegate
    }
}

// MARK: - UITextFieldDelegate
extension CustomTextField: UITextFieldDelegate {
    public func textFieldDidEndEditing(_ textField: UITextField) {
        value = textField.text ?? ""
        // 结束编辑时也触发回调
        onTextChanged?(value)
    }
}

// MARK: - Usage Example
class ExampleUsage {
    func setupTextFields() {
        // 点击模式 - 姓名字段
        let nameField = CustomTextField()
        nameField.title = "Real name"
        nameField.value = "NDARU KRIST BHRAMANTYAKUSUMO"
        nameField.rightImage = UIImage(systemName: "chevron.right")
        nameField.isEditable = false // 点击模式
        nameField.onTap = {
            print("Name field tapped")
            // 处理导航或编辑
        }
        
        // 点击模式 - 生日字段
        let birthdayField = CustomTextField()
        birthdayField.title = "Birthday"
        birthdayField.value = "23/03/2077"
        birthdayField.rightImage = UIImage(systemName: "chevron.right")
        birthdayField.isEditable = false // 点击模式
        birthdayField.onTap = {
            print("Birthday field tapped")
            // 显示日期选择器或导航到编辑屏幕
        }
        
        // 输入模式 - 邮箱字段
        let emailField = CustomTextField()
        emailField.title = "Email"
        emailField.value = "example@email.com"
        emailField.isEditable = true // 输入模式
        emailField.onTextChanged = { newText in
            print("Email changed to: \(newText)")
            // 处理邮箱验证或保存
        }
    }
} 
