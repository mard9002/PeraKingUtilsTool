# AuthenticationStepCell 认证步骤单元格

`AuthenticationStepCell` A 是一个自定义的 UITableViewCell，专为显示认证步骤状态设计。它采用现代化的卡片式布局，包含左侧图标、中间标题和右侧状态指示器，完美匹配身份验证或分步流程界面。

## 特性

- 简洁美观的卡片式布局
- 自定义图标支持
- 状态指示器（已完成/未完成）
- 轻微阴影效果增强视觉层次
- 圆角设计符合现代UI趋势
- 完全自定义的外观和行为

## 截图预览

![预览图](https://your-image-url.com/authentication_step_cell_preview.png)

(注：实际使用时请替换为真实的预览图URL)

## 使用方法

### 基本设置

首先，需要注册单元格并配置表格视图：

```swift
// 1. 注册单元格
tableView.register(AuthenticationStepCell.self, forCellReuseIdentifier: AuthenticationStepCell.reuseIdentifier)

// 2. 配置表格视图外观
tableView.rowHeight = 80  // 推荐高度
tableView.separatorStyle = .none  // 移除分隔线
tableView.backgroundColor = UIColor(red: 0.98, green: 0.96, blue: 0.94, alpha: 1.0)  // 设置背景色
```

### 在UITableView数据源中使用

在`UITableViewDataSource`的`cellForRowAt`方法中使用：

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: AuthenticationStepCell.reuseIdentifier, for: indexPath) as? AuthenticationStepCell else {
        return UITableViewCell()
    }
    
    // 配置单元格
    // 方法1: 使用图片名称
    cell.configure(withIconName: "icon_verify_identity", title: "Verify identity", isCompleted: true)
    
    // 或 方法2: 直接使用UIImage对象
    let icon = UIImage(named: "icon_personal_info")
    cell.configure(with: icon, title: "Personal Information", isCompleted: false)
    
    return cell
}
```

### 完整示例

以下是在视图控制器中实现的完整示例：

```swift
import UIKit

class AuthenticationStepsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView = UITableView()
    
    // 存储认证步骤数据
    private let authSteps = [
        (iconName: "icon_verify_identity", title: "Verify identity", isCompleted: true),
        (iconName: "icon_personal_info", title: "Personal Information", isCompleted: false),
        (iconName: "icon_address", title: "Address Information", isCompleted: false),
        (iconName: "icon_documents", title: "Upload Documents", isCompleted: false)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Authentication Steps"
        view.backgroundColor = UIColor(red: 0.98, green: 0.96, blue: 0.94, alpha: 1.0)
        
        // 配置表格视图
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AuthenticationStepCell.self, forCellReuseIdentifier: AuthenticationStepCell.reuseIdentifier)
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        tableView.backgroundColor = view.backgroundColor
        
        view.addSubview(tableView)
        
        // 设置约束
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return authSteps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AuthenticationStepCell.reuseIdentifier, for: indexPath) as? AuthenticationStepCell else {
            return UITableViewCell()
        }
        
        let step = authSteps[indexPath.row]
        cell.configure(withIconName: step.iconName, title: step.title, isCompleted: step.isCompleted)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 处理单元格选择
        let step = authSteps[indexPath.row]
        print("Selected step: \(step.title)")
        
        // 在这里处理导航到相应步骤的逻辑
    }
}
```

## 自定义外观

您可以通过修改`AuthenticationStepCell`中的属性来自定义单元格外观：

### 自定义卡片样式

```swift
// 调整卡片圆角
containerView.layer.cornerRadius = 12  // 默认为16

// 修改卡片背景色
containerView.backgroundColor = .systemBackground

// 调整阴影效果
containerView.layer.shadowColor = UIColor.black.cgColor
containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
containerView.layer.shadowRadius = 2
containerView.layer.shadowOpacity = 0.1
```

### 自定义文本和图标

```swift
// 修改标题字体
titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)

// 修改标题颜色
titleLabel.textColor = .darkText

// 调整状态图标大小
// 在setupUI()方法中调整约束
statusImageView.widthAnchor.constraint(equalToConstant: 24)
statusImageView.heightAnchor.constraint(equalToConstant: 24)
```

### 自定义状态指示器图标

如果您想要使用自定义图标而不是系统的图标，可以修改`configure`方法：

```swift
func configure(with icon: UIImage?, title: String, isCompleted: Bool) {
    iconImageView.image = icon
    titleLabel.text = title
    
    if isCompleted {
        // 使用自定义完成图标
        statusImageView.image = UIImage(named: "custom_checkmark")
        statusImageView.tintColor = .systemGreen
    } else {
        // 使用自定义未完成图标
        statusImageView.image = UIImage(named: "custom_circle")
        statusImageView.tintColor = .systemGray
    }
}
```

## 注意事项

1. 请确保在项目中添加了相应的图标资源，或使用系统图标
2. 调整行高以适应您的设计需求，默认建议为80点
3. 为获得最佳效果，建议将表格视图的分隔线样式设置为`.none` 