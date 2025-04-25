# FormFieldTableViewCell 表单输入单元格

`FormFieldTableViewCell` 是一个基于 `CustomTextField` 的表格单元格，为表单输入提供了一致性强、视觉效果好的UI组件。它支持两种主要输入类型：可选择项（如职业选择器）和可编辑项（如公司名称输入），使表单数据的收集更加直观和用户友好。

## 特点

- 两种输入模式：可选择式（带右箭头图标）和可编辑式
- 美观的圆角卡片式设计
- 简洁的标题和内容布局
- 支持占位文本
- 完善的回调机制
- 自动适应内容高度

## 屏幕截图示例

左侧为可选择式字段（点击跳转到选择界面），右侧为可编辑式字段（可直接输入）：

![表单字段示例](https://your-image-url.com/form_field_cell_example.png)

## 使用方法

### 1. 注册单元格

首先，在您的`UITableView`中注册该单元格：

```swift
tableView.register(FormFieldTableViewCell.self, forCellReuseIdentifier: FormFieldTableViewCell.reuseIdentifier)
```

### 2. 配置表格视图

设置表格视图的基本属性：

```swift
tableView.rowHeight = UITableView.automaticDimension
tableView.estimatedRowHeight = 100
tableView.separatorStyle = .none
tableView.backgroundColor = UIColor(red: 0.98, green: 0.96, blue: 0.94, alpha: 1.0) // 浅米色背景
```

### 3. 实现数据源方法

在`UITableViewDataSource`中创建和配置单元格：

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
        withIdentifier: FormFieldTableViewCell.reuseIdentifier, 
        for: indexPath
    ) as? FormFieldTableViewCell else {
        return UITableViewCell()
    }
    
    // 根据索引配置不同类型的字段
    switch indexPath.row {
    case 0:
        // 配置可选择式字段（如职业选择）
        cell.configureAsSelectable(
            title: "Occupation",
            value: viewModel.occupation,
            placeholder: "Please Select Profession"
        )
        
        // 设置点击回调
        cell.onFieldTapped = { [weak self] in
            // 处理选择器弹出或导航
            self?.presentOccupationPicker()
        }
        
    case 1:
        // 配置可编辑式字段（如公司名称）
        cell.configureAsEditable(
            title: "Company",
            value: viewModel.company,
            placeholder: "Please Enter The company Name"
        )
        
        // 设置文本变更回调
        cell.onTextChanged = { [weak self] newValue in
            self?.viewModel.company = newValue
        }
        
    default:
        break
    }
    
    return cell
}
```

### 4. 配置单元格类型

您可以使用两种方式配置单元格，根据具体类型分别调用：

```swift
// 方式1: 使用特定类型的配置方法
cell.configureAsSelectable(title: "Occupation", placeholder: "Please Select")
cell.configureAsEditable(title: "Company", placeholder: "Enter company name")

// 方式2: 使用通用配置方法
cell.configure(
    type: .selectable,
    title: "Occupation",
    value: currentValue,
    placeholder: "Please Select"
)
```

### 5. 处理回调

设置回调以响应用户交互：

```swift
// 选择类型字段的点击处理
cell.onFieldTapped = {
    // 显示选择器或导航到选择界面
    let pickerVC = OccupationPickerViewController()
    pickerVC.onSelect = { [weak self] occupation in
        self?.updateOccupation(occupation)
    }
    self.present(pickerVC, animated: true)
}

// 编辑类型字段的文本变化处理
cell.onTextChanged = { newValue in
    // 更新数据模型
    viewModel.updateCompany(newValue)
}
```

## 完整示例

以下是一个完整的表单视图控制器示例，展示了如何使用 `FormFieldTableViewCell`：

```swift
import UIKit

class ProfileFormViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    // 表单数据
    private var formData = [
        (field: "Occupation", type: FormFieldTableViewCell.FieldType.selectable, value: "", placeholder: "Please Select Profession"),
        (field: "Company", type: FormFieldTableViewCell.FieldType.editable, value: "", placeholder: "Please Enter The company Name")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Profile Information"
        view.backgroundColor = UIColor(red: 0.98, green: 0.96, blue: 0.94, alpha: 1.0)
        
        // 配置表格视图
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FormFieldTableViewCell.self, forCellReuseIdentifier: FormFieldTableViewCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
        tableView.backgroundColor = view.backgroundColor
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // 处理职业选择
    private func presentOccupationPicker() {
        // 这里实现职业选择器的展示逻辑
        print("Showing occupation picker")
    }
    
    // 更新表单数据
    private func updateFormField(at index: Int, with value: String) {
        guard index < formData.count else { return }
        formData[index].value = value
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }
}

// MARK: - UITableViewDataSource
extension ProfileFormViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FormFieldTableViewCell.reuseIdentifier, for: indexPath) as? FormFieldTableViewCell else {
            return UITableViewCell()
        }
        
        let fieldData = formData[indexPath.row]
        
        // 配置单元格
        cell.configure(
            type: fieldData.type,
            title: fieldData.field,
            value: fieldData.value,
            placeholder: fieldData.placeholder
        )
        
        // 设置回调
        cell.onFieldTapped = { [weak self] in
            if fieldData.type == .selectable {
                if fieldData.field == "Occupation" {
                    self?.presentOccupationPicker()
                }
            }
        }
        
        cell.onTextChanged = { [weak self] newValue in
            self?.updateFormField(at: indexPath.row, with: newValue)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ProfileFormViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView() // 空白头部视图
    }
}
```

## 自定义外观

您可以通过修改 `FormFieldTableViewCell.swift` 中的以下属性来自定义单元格外观：

```swift
// 修改容器圆角
containerView.layer.cornerRadius = 12  // 默认为16

// 修改容器背景色
containerView.backgroundColor = .systemBackground

// 修改背景色
backgroundColor = .systemGroupedBackground

// 修改内边距
// 在setupViews()方法中修改相应约束的常量值
```

## 注意事项

1. **单元格复用**：确保在复用单元格时正确配置所有属性，`prepareForReuse`方法已实现基本的重置功能
2. **自适应高度**：为获得最佳效果，建议使用`UITableView.automaticDimension`设置行高
3. **回调处理**：使用弱引用（`[weak self]`）避免循环引用
4. **键盘处理**：对于可编辑字段，可能需要添加键盘处理逻辑，如滚动到可见区域或添加键盘隐藏手势
5. **表单验证**：该组件不包含内置的表单验证，需要在回调中自行实现 