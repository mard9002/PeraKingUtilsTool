import UIKit

public class StepProgressView: UIView {
    
    // MARK: - 属性
    
    /// 流程步骤的总数
    private var numberOfSteps: Int = 5
    
    /// 当前处于的步骤 (从0开始)
    private var currentStep: Int = 0
    
    /// 步骤圆点的大小
    private var stepPointSize: CGFloat = 26
    
    /// 连接线的高度
    private var lineHeight: CGFloat = 3
    
    /// 当前步骤的颜色
    private var activeColor: UIColor = UIColor(red: 62/255, green: 96/255, blue: 111/255, alpha: 1.0)
    
    /// 未完成步骤的颜色
    private var inactiveColor: UIColor = UIColor(red: 182/255, green: 196/255, blue: 198/255, alpha: 1.0)
    
    /// 存储所有步骤圆点的数组
    private var stepPoints: [UIView] = []
    
    /// 存储所有连接线的数组
    private var stepLines: [UIView] = []
    
    // MARK: - 初始化
    
    /// 使用指定的步骤数量初始化
    /// - Parameters:
    ///   - frame: 视图框架
    ///   - numberOfSteps: 步骤总数量
    public init(frame: CGRect, numberOfSteps: Int) {
        self.numberOfSteps = max(2, numberOfSteps) // 至少需要2个步骤
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - 视图设置
    
    private func setupView() {
        backgroundColor = .clear
        
        // 创建步骤点和连接线
        createStepPointsAndLines()
        
        // 更新当前状态
        updateStepStatus()
    }
    
    /// 创建步骤圆点和连接线
    private func createStepPointsAndLines() {
        // 清除现有的视图
        stepPoints.forEach { $0.removeFromSuperview() }
        stepLines.forEach { $0.removeFromSuperview() }
        stepPoints.removeAll()
        stepLines.removeAll()
        
        // 计算间距
        let totalWidth = bounds.width
        var stepSpacing: CGFloat = 0
        
        if numberOfSteps > 1 {
            stepSpacing = (totalWidth - CGFloat(numberOfSteps) * stepPointSize) / CGFloat(numberOfSteps - 1)
        }
        
        // 创建步骤点和连接线
        for i in 0..<numberOfSteps {
            // 创建步骤圆点
            let stepPoint = createStepPoint()
            
            // 步骤点位置
            let xPosition = (CGFloat(i) * (stepPointSize + stepSpacing))
            stepPoint.frame = CGRect(
                x: xPosition,
                y: (bounds.height - stepPointSize) / 2,
                width: stepPointSize,
                height: stepPointSize
            )
            
            addSubview(stepPoint)
            stepPoints.append(stepPoint)
            
            // 创建连接线（除了最后一个步骤点）
            if i < numberOfSteps - 1 {
                let line = createLine()
                
                // 线位置
                let lineXPosition = xPosition + stepPointSize
                let lineWidth = stepSpacing
                line.frame = CGRect(
                    x: lineXPosition,
                    y: (bounds.height - lineHeight) / 2,
                    width: lineWidth,
                    height: lineHeight
                )
                
                addSubview(line)
                stepLines.append(line)
            }
        }
    }
    
    /// 创建单个步骤圆点
    private func createStepPoint() -> UIView {
        let view = UIView()
        view.backgroundColor = inactiveColor
        view.layer.cornerRadius = stepPointSize / 2
        return view
    }
    
    /// 创建连接线
    private func createLine() -> UIView {
        let view = UIView()
        view.backgroundColor = inactiveColor
        return view
    }
    
    // MARK: - 更新视图
    
    /// 更新所有步骤点和连接线的状态
    private func updateStepStatus() {
        for i in 0..<stepPoints.count {
            if i <= currentStep {
                stepPoints[i].backgroundColor = activeColor
            } else {
                stepPoints[i].backgroundColor = inactiveColor
            }
        }
        
        for i in 0..<stepLines.count {
            if i < currentStep {
                stepLines[i].backgroundColor = activeColor
            } else {
                stepLines[i].backgroundColor = inactiveColor
            }
        }
    }
    
    // MARK: - 布局
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // 重新创建布局，以适应大小变化
        createStepPointsAndLines()
        updateStepStatus()
    }
    
    // MARK: - 公共方法
    
    /// 设置当前完成的步骤
    /// - Parameter step: 当前步骤（从0开始）
    func setCurrentStep(_ step: Int) {
        currentStep = max(0, min(step, numberOfSteps - 1))
        updateStepStatus()
    }
    
    /// 进入下一步
    func nextStep() {
        if currentStep < numberOfSteps - 1 {
            currentStep += 1
            updateStepStatus()
        }
    }
    
    /// 返回上一步
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
            updateStepStatus()
        }
    }
    
    /// 配置步骤指示器的外观
    /// - Parameters:
    ///   - stepSize: 步骤圆点大小
    ///   - lineHeight: 连接线高度
    ///   - activeColor: 激活状态颜色
    ///   - inactiveColor: 未激活状态颜色
    public func configure(stepSize: CGFloat? = nil, lineHeight: CGFloat? = nil, activeColor: UIColor? = nil, inactiveColor: UIColor? = nil) {
        
        if let stepSize = stepSize {
            self.stepPointSize = stepSize
        }
        
        if let lineHeight = lineHeight {
            self.lineHeight = lineHeight
        }
        
        if let activeColor = activeColor {
            self.activeColor = activeColor
        }
        
        if let inactiveColor = inactiveColor {
            self.inactiveColor = inactiveColor
        }
        
        // 重新创建视图
        setNeedsLayout()
    }
}

// MARK: - 使用示例
class StepProgressExample {
    func setupStepProgressView() -> StepProgressView {
        let frame = CGRect(x: 0, y: 0, width: 300, height: 50)
        let stepProgressView = StepProgressView(frame: frame, numberOfSteps: 5)
        
        // 配置外观（可选）
        stepProgressView.configure(
            stepSize: 24,
            lineHeight: 3,
            activeColor: UIColor(red: 62/255, green: 96/255, blue: 111/255, alpha: 1.0),
            inactiveColor: UIColor(red: 182/255, green: 196/255, blue: 198/255, alpha: 1.0)
        )
        
        // 设置当前步骤
        stepProgressView.setCurrentStep(0)
        
        return stepProgressView
    }
} 
