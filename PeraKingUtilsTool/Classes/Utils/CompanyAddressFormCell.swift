import UIKit
import Foundation

/// 公司地址选择器表单单元格，支持两行地址输入/选择
public class CompanyAddressFormCell: UITableViewCell {
    
    // MARK: - 常量
    public static let reuseIdentifier = "CompanyAddressFormCell"
    
    // MARK: - 属性
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let addressField1 = CustomTextField()
    private let addressField2 = CustomTextField()
    private let stackView = UIStackView()
    
    // 回调闭包
    public var onAddressField1Tapped: (() -> Void)?
    public var onAddressField2Tapped: (() -> Void)?
    
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
        backgroundColor = .clear
        
        // 设置容器视图
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 20
        contentView.addSubview(containerView)
        
        // 设置标题标签
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.text = "Company"
        containerView.addSubview(titleLabel)
        
        // 设置堆栈视图
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        containerView.addSubview(stackView)
        
        // 配置第一个地址字段
        setupAddressField1()
        
        // 配置第二个地址字段
        setupAddressField2()
        
        // 添加地址字段到堆栈视图
        stackView.addArrangedSubview(addressField1)
        stackView.addArrangedSubview(addressField2)
        
        // 设置约束
        NSLayoutConstraint.activate([
            // 容器视图约束
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // 标题标签约束
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // 堆栈视图约束
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupAddressField1() {
        addressField1.translatesAutoresizingMaskIntoConstraints = false
        addressField1.placeholder = "Please Select A Company Address"
        addressField1.isEditable = false
        addressField1.rightImage = UIImage(systemName: "chevron.right")
        addressField1.contentBg = UIColor(hex: "#F9F9F9")
        // 设置点击回调
        addressField1.onTap = { [weak self] in
            self?.onAddressField1Tapped?()
        }
    }
    
    private func setupAddressField2() {
        addressField2.translatesAutoresizingMaskIntoConstraints = false
        addressField2.placeholder = "PPlease Select A Company Address"
        addressField2.isEditable = false
        addressField2.rightImage = UIImage()
        addressField2.contentBg = UIColor(hex: "#F9F9F9")
        // 设置点击回调
        addressField2.onTap = { [weak self] in
            self?.onAddressField2Tapped?()
        }
    }
    
    // MARK: - 公共配置方法
    
    /// 配置地址选择器
    /// - Parameters:
    ///   - title: 表单标题
    ///   - address1: 第一行地址
    ///   - address2: 第二行地址
    ///   - placeholder1: 第一行占位符文本
    ///   - placeholder2: 第二行占位符文本
    public func configure(
        title: String,
        address1: String = "",
        address2: String = "",
        placeholder1: String = "Please Select A Company Address",
        placeholder2: String = "Please Select A Company Address"
    ) {
        titleLabel.text = title
        addressField1.value = address1
        addressField2.value = address2
        addressField1.placeholder = placeholder1
        addressField2.placeholder = placeholder2
    }
    
    /// 获取第一行地址值
    public func getAddress1() -> String {
        return addressField1.getInputValue()
    }
    
    /// 获取第二行地址值
    public func getAddress2() -> String {
        return addressField2.getInputValue()
    }
    
    /// 设置第一行地址值
    public func setAddress1(_ address: String) {
        addressField1.value = address
    }
    
    /// 设置第二行地址值
    public func setAddress2(_ address: String) {
        addressField2.value = address
    }
    
    // MARK: - 重置
    public override func prepareForReuse() {
        super.prepareForReuse()
        addressField1.value = ""
        addressField2.value = ""
        titleLabel.text = "Company"
        onAddressField1Tapped = nil
        onAddressField2Tapped = nil
    }
}

// MARK: - 使用示例
class CompanyAddressFormExample {
    
    func setupTableView(_ tableView: UITableView) {
        // 注册单元格
        tableView.register(CompanyAddressFormCell.self, forCellReuseIdentifier: CompanyAddressFormCell.reuseIdentifier)
        
        // 设置行高
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 180
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 0.98, green: 0.96, blue: 0.94, alpha: 1.0) // 浅米色背景
    }
    
    // UITableViewDataSource示例方法
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CompanyAddressFormCell.reuseIdentifier,
            for: indexPath
        ) as? CompanyAddressFormCell else {
            return UITableViewCell()
        }
        
        // 配置单元格
        cell.configure(
            title: "Company",
            address1: "",
            address2: ""
        )
        
        // 设置地址1点击回调
        cell.onAddressField1Tapped = {
            print("Address Field 1 tapped")
            // 打开地址选择器
            self.presentAddressPicker { selectedAddress in
                cell.setAddress1(selectedAddress)
            }
        }
        
        // 设置地址2点击回调
        cell.onAddressField2Tapped = {
            print("Address Field 2 tapped")
            // 打开地址选择器
            self.presentAddressPicker { selectedAddress in
                cell.setAddress2(selectedAddress)
            }
        }
        
        return cell
    }
    
    // 示例方法 - 打开地址选择器
    private func presentAddressPicker(completion: @escaping (String) -> Void) {
        // 这里实现地址选择器的展示逻辑
        print("Showing address picker")
        
        // 模拟选择地址后的回调
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion("123 Main Street, New York, NY 10001")
        }
    }
} 
