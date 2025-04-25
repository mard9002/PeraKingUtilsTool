# StepProgressView 步骤进度指示器

`StepProgressView` 是一个轻量级的步骤进度指示器组件，用于显示多步流程中的当前进度。组件由一系列圆形指示点和连接线构成，通过颜色区分已完成步骤和未完成步骤。

## 功能特点

- 自定义步骤数量
- 支持动态更新当前步骤
- 完全可自定义的外观（圆点大小、线条高度、颜色等）
- 自适应布局，适合各种屏幕尺寸
- 简单易用的API
- 支持Interface Builder和代码创建

## 使用方法

### 基础用法

#### 通过代码创建

```swift
// 1. 初始化步骤指示器
let frame = CGRect(x: 0, y: 0, width: view.bounds.width - 40, height: 50)
let stepProgressView = StepProgressView(frame: frame, numberOfSteps: 5)

// 2. 添加到视图
view.addSubview(stepProgressView)

// 3. 设置布局约束（如果使用Auto Layout）
stepProgressView.translatesAutoresizingMaskIntoConstraints = false
NSLayoutConstraint.activate([
    stepProgressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
    stepProgressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
    stepProgressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
    stepProgressView.heightAnchor.constraint(equalToConstant: 50)
])

// 4. 设置当前步骤（从0开始）
stepProgressView.setCurrentStep(0)
```

#### 通过Interface Builder创建

1. 在Interface Builder中添加一个UIView
2. 在Identity Inspector中将Class设置为`StepProgressView`
3. 通过代码配置属性：

```swift
@IBOutlet weak var stepProgressView: StepProgressView!

override func viewDidLoad() {
    super.viewDidLoad()
    
    // 设置步骤数量和初始步骤
    stepProgressView.configure(stepSize: 24, lineHeight: 3)
    stepProgressView.setCurrentStep(0)
}
```

### 更新当前步骤

```swift
// 设置特定步骤
stepProgressView.setCurrentStep(2)

// 进入下一步
stepProgressView.nextStep()

// 返回上一步
stepProgressView.previousStep()
```

### 自定义外观

```swift
// 自定义外观
stepProgressView.configure(
    stepSize: 30,                // 圆点大小
    lineHeight: 4,               // 线条高度
    activeColor: .systemBlue,    // 已完成步骤颜色
    inactiveColor: .lightGray    // 未完成步骤颜色
)
```

## 完整示例

以下是一个在`UIViewController`中使用`StepProgressView`的完整示例：

```swift
import UIKit

class StepsViewController: UIViewController {
    
    private var stepProgressView: StepProgressView!
    private var nextButton: UIButton!
    private var prevButton: UIButton!
    private var stepLabel: UILabel!
    
    // 步骤标题
    private let stepTitles = [
        "个人信息",
        "联系方式",
        "地址信息",
        "认证资料",
        "完成注册"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // 创建步骤指示器
        stepProgressView = StepProgressView(frame: .zero, numberOfSteps: stepTitles.count)
        stepProgressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stepProgressView)
        
        // 创建步骤标签
        stepLabel = UILabel()
        stepLabel.translatesAutoresizingMaskIntoConstraints = false
        stepLabel.textAlignment = .center
        stepLabel.font = .systemFont(ofSize: 18, weight: .medium)
        view.addSubview(stepLabel)
        
        // 创建按钮
        nextButton = UIButton(type: .system)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setTitle("下一步", for: .normal)
        nextButton.addTarget(self, action: #selector(nextStepTapped), for: .touchUpInside)
        
        prevButton = UIButton(type: .system)
        prevButton.translatesAutoresizingMaskIntoConstraints = false
        prevButton.setTitle("上一步", for: .normal)
        prevButton.addTarget(self, action: #selector(prevStepTapped), for: .touchUpInside)
        
        let buttonStack = UIStackView(arrangedSubviews: [prevButton, nextButton])
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 20
        view.addSubview(buttonStack)
        
        // 设置约束
        NSLayoutConstraint.activate([
            stepProgressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stepProgressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stepProgressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stepProgressView.heightAnchor.constraint(equalToConstant: 50),
            
            stepLabel.topAnchor.constraint(equalTo: stepProgressView.bottomAnchor, constant: 30),
            stepLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
        
        // 初始化第一步
        stepProgressView.setCurrentStep(0)
        updateStepLabel()
        updateButtonState()
    }
    
    @objc private func nextStepTapped() {
        stepProgressView.nextStep()
        updateStepLabel()
        updateButtonState()
    }
    
    @objc private func prevStepTapped() {
        stepProgressView.previousStep()
        updateStepLabel()
        updateButtonState()
    }
    
    private func updateStepLabel() {
        let currentIndex = min(stepTitles.count - 1, stepProgressView.currentStep)
        stepLabel.text = "\(currentIndex + 1). \(stepTitles[currentIndex])"
    }
    
    private func updateButtonState() {
        prevButton.isEnabled = stepProgressView.currentStep > 0
        nextButton.isEnabled = stepProgressView.currentStep < (stepTitles.count - 1)
    }
}
```

## 自定义和扩展

### 1. 添加数字标签

如果您需要在步骤圆点中显示数字，可以扩展 `StepProgressView` 类：

```swift
extension StepProgressView {
    
    func addStepLabels() {
        for (index, stepPoint) in stepPoints.enumerated() {
            let label = UILabel()
            label.text = "\(index + 1)"
            label.textColor = .white
            label.textAlignment = .center
            label.font = .systemFont(ofSize: stepPointSize / 2, weight: .bold)
            label.frame = stepPoint.bounds
            stepPoint.addSubview(label)
        }
    }
}
```

### 2. 添加步骤标题

要在步骤点下方显示标题，可以修改视图布局：

```swift
extension StepProgressView {
    
    func addStepTitles(_ titles: [String]) {
        // 移除旧标题
        subviews.forEach { if $0 is UILabel { $0.removeFromSuperview() } }
        
        // 添加新标题
        for (index, stepPoint) in stepPoints.enumerated() {
            let label = UILabel()
            label.text = index < titles.count ? titles[index] : ""
            label.textColor = .darkGray
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 12)
            label.frame = CGRect(
                x: stepPoint.frame.minX - 20,
                y: stepPoint.frame.maxY + 8,
                width: stepPoint.frame.width + 40,
                height: 20
            )
            addSubview(label)
        }
    }
}
```

## 注意事项

1. **用法和布局**
   - 为确保良好的显示效果，请为视图提供足够的宽度，特别是当步骤数量较多时
   - 步骤圆点间距会根据控件宽度和步骤数量自动计算，若步骤过多可能导致过于拥挤
   - 建议将此控件放置在界面顶部，并为其提供充足的高度（推荐至少50点）
   - 如需下方显示标题文字，高度需要相应增加

2. **性能考虑**
   - 该组件已针对性能优化，仅在必要时重绘视图
   - 在滚动视图中使用时，如果频繁触发布局变化，可能影响性能，建议使用固定大小

3. **数据相关**
   - 步骤从0开始计数，所以第一个步骤是0，最后一个步骤是`numberOfSteps - 1`
   - 步骤数量最小为2，如果传入的值小于2，将自动调整为2

4. **适配和兼容**
   - 视图会自动调整大小以适应其父视图的变化
   - 支持深色模式，但颜色需要手动适配
   - 支持RTL布局，无需额外配置

5. **常见问题解决**
   - 如果颜色显示不正确，请确认是否正确设置了`activeColor`和`inactiveColor`
   - 当状态变化但视图未更新时，可以尝试调用`setNeedsLayout()`
   - 如需动画效果，可在状态切换前后手动添加过渡动画 