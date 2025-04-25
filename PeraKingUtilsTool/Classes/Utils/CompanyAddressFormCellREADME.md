# CompanyAddressFormCell 公司地址表单单元格

`CompanyAddressFormCell` 是一个用于展示和选择双行地址信息的表格单元格，基于 `CustomTextField` 构建。它专为需要输入或选择公司地址等多行信息的表单设计，提供了直观的用户界面和简单的配置方法。

## 功能特点

- 双行地址输入/选择
- 单独控制每行的内容和交互
- 简洁美观的卡片式设计
- 支持点击选择模式
- 清晰的标题和内容分离
- 自动适应内容高度
- 完整的回调机制

## 屏幕效果

表单单元格显示两行地址选择器：

![公司地址表单示例](https://your-image-url.com/company_address_form_example.png)

## 使用方法

### 1. 注册单元格

首先，在您的 `UITableView` 中注册该单元格：

```swift
tableView.register(CompanyAddressFormCell.self, forCellReuseIdentifier: CompanyAddressFormCell.reuseIdentifier)
```

### 2. 配置表格视图

设置表格视图的基本属性：

```swift
tableView.rowHeight = UITableView.automaticDimension
tableView.estimatedRowHeight = 180 // 由于是双行，需要更高的估计高度
tableView.separatorStyle = .none
tableView.backgroundColor = UIColor(red: 0.98, green: 0.96, blue: 0.94, alpha: 1.0) // 浅米色背景
```

### 3. 创建和配置单元格

在 `UITableViewDataSource` 中创建和配置单元格：

```swift
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
        address1: viewModel.companyAddress1,
        address2: viewModel.companyAddress2,
        placeholder1: "Please Select A Company Address",
        placeholder2: "Please Select A Company Address"
    )
    
    // 设置点击回调
    cell.onAddressField1Tapped = { [weak self] in
        self?.presentAddressPicker { address in
            cell.setAddress1(address)
            self?.viewModel.companyAddress1 = address
        }
    }
    
    cell.onAddressField2Tapped = { [weak self] in
        self?.presentAddressPicker { address in
            cell.setAddress2(address)
            self?.viewModel.companyAddress2 = address
        }
    }
    
    return cell
}
```

### 4. 地址选择回调处理

实现地址选择器的展示和回调处理：

```swift
private func presentAddressPicker(completion: @escaping (String) -> Void) {
    let addressPickerVC = AddressPickerViewController()
    addressPickerVC.onAddressSelected = { address in
        completion(address)
    }
    present(addressPickerVC, animated: true)
}
```

### 5. 获取地址数据

从单元格获取输入的地址数据：

```swift
func getUserInputData() -> (address1: String, address2: String) {
    guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CompanyAddressFormCell else {
        return ("", "")
    }
    
    return (cell.getAddress1(), cell.getAddress2())
}
```

## 公共方法

### 配置单元格

```swift
// 完整配置
cell.configure(
    title: "公司地址",
    address1: "总部：北京市海淀区中关村大街1号",
    address2: "分部：上海市浦东新区张江高科技园区",
    placeholder1: "请选择公司主要地址",
    placeholder2: "请选择公司次要地址"
)

// 简化配置(使用默认占位符)
cell.configure(
    title: "Company Address",
    address1: "123 Main Street",
    address2: "Suite 456"
)
```

### 设置地址值

```swift
// 单独设置各行地址
cell.setAddress1("123 Main Street, New York, NY 10001")
cell.setAddress2("Suite 200")
```

### 获取地址值

```swift
// 获取各行地址
let mainAddress = cell.getAddress1()
let secondaryAddress = cell.getAddress2()
```

## 完整示例

以下是一个完整的视图控制器示例，展示了如何使用 `CompanyAddressFormCell`：

```swift
import UIKit

class CompanyProfileViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var companyAddress1 = ""
    private var companyAddress2 = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Company Profile"
        view.backgroundColor = UIColor(red: 0.98, green: 0.96, blue: 0.94, alpha: 1.0)
        
        // 配置表格视图
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CompanyAddressFormCell.self, forCellReuseIdentifier: CompanyAddressFormCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 180
        tableView.separatorStyle = .none
        tableView.backgroundColor = view.backgroundColor
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 添加保存按钮
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc private func saveButtonTapped() {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CompanyAddressFormCell else {
            return
        }
        
        let address1 = cell.getAddress1()
        let address2 = cell.getAddress2()
        
        // 验证地址
        guard !address1.isEmpty else {
            showAlert(message: "Please select primary address")
            return
        }
        
        // 保存数据
        saveAddresses(primary: address1, secondary: address2)
    }
    
    private func saveAddresses(primary: String, secondary: String) {
        // 实现保存逻辑
        print("Saving addresses: \(primary) and \(secondary)")
        showAlert(message: "Addresses saved successfully!")
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // 打开地址选择器
    private func presentAddressPicker(completion: @escaping (String) -> Void) {
        // 实现地址选择器的展示逻辑
        let addressOptions = [
            "123 Main Street, New York, NY 10001",
            "456 Park Avenue, Chicago, IL 60601",
            "789 Market Street, San Francisco, CA 94103",
            "321 Commerce Street, Seattle, WA 98101"
        ]
        
        let alertController = UIAlertController(title: "Select Address", message: nil, preferredStyle: .actionSheet)
        
        for address in addressOptions {
            alertController.addAction(UIAlertAction(title: address, style: .default) { _ in
                completion(address)
            })
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CompanyProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CompanyAddressFormCell.reuseIdentifier, for: indexPath) as? CompanyAddressFormCell else {
            return UITableViewCell()
        }
        
        // 配置单元格
        cell.configure(
            title: "Company",
            address1: companyAddress1,
            address2: companyAddress2
        )
        
        // 设置回调
        cell.onAddressField1Tapped = { [weak self] in
            self?.presentAddressPicker { selectedAddress in
                cell.setAddress1(selectedAddress)
                self?.companyAddress1 = selectedAddress
            }
        }
        
        cell.onAddressField2Tapped = { [weak self] in
            self?.presentAddressPicker { selectedAddress in
                cell.setAddress2(selectedAddress)
                self?.companyAddress2 = selectedAddress
            }
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CompanyProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
}
```

## 自定义外观

您可以通过修改 `CompanyAddressFormCell.swift` 中的设置来自定义外观：

```swift
// 修改容器圆角
containerView.layer.cornerRadius = 16  // 默认为20

// 修改标题字体
titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)

// 修改堆栈视图间距
stackView.spacing = 16  // 默认为12

// 修改内边距
// 在setupViews()方法中调整相应约束的常量值
```

## 注意事项

1. **适当的行高**：由于组件包含两个地址字段，建议使用自动高度或提供足够高的固定高度
2. **回调处理**：使用弱引用（`[weak self]`）避免循环引用
3. **数据验证**：根据业务需求，可能需要验证地址输入的有效性
4. **可访问性**：视图支持动态字体大小调整，但可能需要针对特殊需求进行优化
5. **复用管理**：单元格的 `prepareForReuse` 方法会重置所有属性和回调，确保在每次配置单元格时设置所有必要属性 