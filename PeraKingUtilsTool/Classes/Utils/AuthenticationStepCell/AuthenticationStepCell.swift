import UIKit
import Kingfisher

@objc public class AuthenticationStepCell: UITableViewCell {
    
    // MARK: - 常量
    public static let reuseIdentifier = "AuthenticationStepCell"
    
    // MARK: - UI 组件
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 14
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - 初始化
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局和配置
    private func setupUI() {
        backgroundColor = .clear // 浅米色背景
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(statusImageView)
        
        NSLayoutConstraint.activate([
            // 容器视图约束
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 13),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -13),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // 图标约束
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 51),
            iconImageView.heightAnchor.constraint(equalToConstant: 51),
            
            // 标题约束
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 13),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusImageView.leadingAnchor, constant: -16),
            
            // 状态图标约束
            statusImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -34),
            statusImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            statusImageView.widthAnchor.constraint(equalToConstant: 24),
            statusImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // 添加阴影效果
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.masksToBounds = false
    }
    
    // MARK: - 配置方法
    
    /// 配置单元格显示
    /// - Parameters:
    ///   - icon: 步骤图标
    ///   - title: 步骤标题
    ///   - isCompleted: 是否已完成 (true: 显示对勾, false: 显示圆形)
    public func configure(with icon: UIImage?, title: String, isCompleted: Bool) {
        iconImageView.image = icon
        titleLabel.text = title
        
        if isCompleted {
            // 已完成状态 - 黑色对勾
            statusImageView.image = UIImage(systemName: "checkmark.circle.fill")
            statusImageView.tintColor = .black
        } else {
            // 未完成状态 - 灰色圆圈
            statusImageView.image = UIImage(systemName: "circle")
            statusImageView.tintColor = .lightGray
        }
    }
    
    /// 配置单元格显示（使用图片名称）
    /// - Parameters:
    ///   - iconName: 步骤图标名称
    ///   - title: 步骤标题
    ///   - isCompleted: 是否已完成
    public func configure(withIconName iconName: String, title: String, isCompleted: Bool) {
        configure(with: UIImage(named: iconName), title: title, isCompleted: isCompleted)
    }
    
    public func configure(withIconUrl iconUrl: String, title: String, isCompleted: Bool) {
        iconImageView.kf.setImage(with: URL(string: iconUrl))
        titleLabel.text = title
        
        if isCompleted {
            // 已完成状态 - 黑色对勾
            statusImageView.image = UIImage(systemName: "checkmark.circle.fill")
            statusImageView.tintColor = .black
        } else {
            // 未完成状态 - 灰色圆圈
            statusImageView.image = UIImage(systemName: "circle")
            statusImageView.tintColor = .lightGray
        }
    }
    
    
    // 重置复用时的状态
    public override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        titleLabel.text = nil
        statusImageView.image = nil
    }
}

// MARK: - 使用示例
// 在ViewController中的使用示例
class AuthenticationStepsExample {
    
    func configureTableView(_ tableView: UITableView) {
        // 注册Cell
        tableView.register(AuthenticationStepCell.self, forCellReuseIdentifier: AuthenticationStepCell.reuseIdentifier)
        
        // 设置行高
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 0.98, green: 0.96, blue: 0.94, alpha: 1.0) // 浅米色背景
    }
    
    // UITableViewDataSource示例方法
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AuthenticationStepCell.reuseIdentifier, for: indexPath) as? AuthenticationStepCell else {
            return UITableViewCell()
        }
        
        // 示例数据
        let steps = [
            (iconName: "icon_verify_identity", title: "Verify identity", isCompleted: true),
            (iconName: "icon_personal_info", title: "Personal Information", isCompleted: false)
        ]
        
        if indexPath.row < steps.count {
            let step = steps[indexPath.row]
            cell.configure(withIconName: step.iconName, title: step.title, isCompleted: step.isCompleted)
        }
        
        return cell
    }
} 
