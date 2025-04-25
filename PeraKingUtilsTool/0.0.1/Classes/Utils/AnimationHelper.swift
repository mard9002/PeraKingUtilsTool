import UIKit
import QuartzCore
import Foundation

/// 动画辅助类 - 提供常用的UI动画效果
@objc public  final class AnimationHelper: NSObject {
    
    /// 基本淡入淡出动画
    /// - Parameters:
    ///   - view: 需要动画的视图
    ///   - duration: 动画持续时间
    ///   - delay: 延迟时间
    ///   - fadeIn: 是否为淡入(true)或淡出(false)
    ///   - completion: 完成回调
    public static func fade(
        view: UIView,
        duration: TimeInterval = 0.3,
        delay: TimeInterval = 0,
        fadeIn: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) {
        view.alpha = fadeIn ? 0 : 1
        
        UIView.animate(
            withDuration: duration,
            delay: delay,
            options: .curveEaseInOut,
            animations: {
                view.alpha = fadeIn ? 1 : 0
            },
            completion: completion
        )
    }
    
    /// 缩放动画
    /// - Parameters:
    ///   - view: 需要动画的视图
    ///   - duration: 动画持续时间
    ///   - delay: 延迟时间
    ///   - scaleFrom: 起始缩放比例
    ///   - scaleTo: 目标缩放比例
    ///   - completion: 完成回调
    public static func scale(
        view: UIView,
        duration: TimeInterval = 0.3,
        delay: TimeInterval = 0,
        scaleFrom: CGFloat = 0.5,
        scaleTo: CGFloat = 1.0,
        completion: ((Bool) -> Void)? = nil
    ) {
        view.transform = CGAffineTransform(scaleX: scaleFrom, y: scaleFrom)
        
        UIView.animate(
            withDuration: duration,
            delay: delay,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: .curveEaseInOut,
            animations: {
                view.transform = CGAffineTransform(scaleX: scaleTo, y: scaleTo)
            },
            completion: completion
        )
    }
    
    /// 移动动画
    /// - Parameters:
    ///   - view: 需要动画的视图
    ///   - duration: 动画持续时间
    ///   - delay: 延迟时间
    ///   - fromX: X轴起始位置偏移
    ///   - fromY: Y轴起始位置偏移
    ///   - toX: X轴目标位置偏移
    ///   - toY: Y轴目标位置偏移
    ///   - completion: 完成回调
    public static func move(
        view: UIView,
        duration: TimeInterval = 0.3,
        delay: TimeInterval = 0,
        fromX: CGFloat = 0,
        fromY: CGFloat = 0,
        toX: CGFloat = 0,
        toY: CGFloat = 0,
        completion: ((Bool) -> Void)? = nil
    ) {
        view.transform = CGAffineTransform(translationX: fromX, y: fromY)
        
        UIView.animate(
            withDuration: duration,
            delay: delay,
            options: .curveEaseInOut,
            animations: {
                view.transform = CGAffineTransform(translationX: toX, y: toY)
            },
            completion: completion
        )
    }
    
    /// 旋转动画
    /// - Parameters:
    ///   - view: 需要动画的视图
    ///   - duration: 动画持续时间
    ///   - delay: 延迟时间
    ///   - fromAngle: 起始角度(弧度)
    ///   - toAngle: 目标角度(弧度)
    ///   - completion: 完成回调
    public static func rotate(
        view: UIView,
        duration: TimeInterval = 0.3,
        delay: TimeInterval = 0,
        fromAngle: CGFloat = 0,
        toAngle: CGFloat = .pi * 2,
        completion: ((Bool) -> Void)? = nil
    ) {
        view.transform = CGAffineTransform(rotationAngle: fromAngle)
        
        UIView.animate(
            withDuration: duration,
            delay: delay,
            options: .curveLinear,
            animations: {
                view.transform = CGAffineTransform(rotationAngle: toAngle)
            },
            completion: completion
        )
    }
    
    /// 弹跳动画
    /// - Parameters:
    ///   - view: 需要动画的视图
    ///   - duration: 动画持续时间
    ///   - delay: 延迟时间
    ///   - completion: 完成回调
    public static func bounce(
        view: UIView,
        duration: TimeInterval = 0.5,
        delay: TimeInterval = 0,
        completion: ((Bool) -> Void)? = nil
    ) {
        UIView.animate(
            withDuration: duration / 4,
            delay: delay,
            options: .curveEaseOut,
            animations: {
                view.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            },
            completion: { _ in
                UIView.animate(
                    withDuration: duration / 4,
                    delay: 0,
                    usingSpringWithDamping: 0.5,
                    initialSpringVelocity: 0.5,
                    options: .curveEaseInOut,
                    animations: {
                        view.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                    },
                    completion: { _ in
                        UIView.animate(
                            withDuration: duration / 4,
                            delay: 0,
                            usingSpringWithDamping: 0.5,
                            initialSpringVelocity: 0.5,
                            options: .curveEaseInOut,
                            animations: {
                                view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                            },
                            completion: { _ in
                                UIView.animate(
                                    withDuration: duration / 4,
                                    delay: 0,
                                    usingSpringWithDamping: 0.5,
                                    initialSpringVelocity: 0.5,
                                    options: .curveEaseInOut,
                                    animations: {
                                        view.transform = CGAffineTransform.identity
                                    },
                                    completion: completion
                                )
                            }
                        )
                    }
                )
            }
        )
    }
    
    /// 抖动动画
    /// - Parameters:
    ///   - view: 需要动画的视图
    ///   - duration: 动画持续时间
    ///   - delay: 延迟时间
    ///   - completion: 完成回调
//    public static func shake(
//        view: UIView,
//        duration: TimeInterval = 0.6,
//        delay: TimeInterval = 0,
//        completion: ((Bool) -> Void)? = nil
//    ) {
//        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
//        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
//        animation.duration = duration
//        animation.values = [-12, 12, -8, 8, -4, 4, 0]
//        view.layer.add(animation, forKey: "shake")
//        
//        // 为了支持completion回调
//        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
//            completion?(true)
//        }
//    }
    
    /// 闪烁动画
    /// - Parameters:
    ///   - view: 需要动画的视图
    ///   - duration: 动画持续时间
    ///   - delay: 延迟时间
    ///   - repeatCount: 重复次数
    public static func flash(
        view: UIView,
        duration: TimeInterval = 0.3,
        delay: TimeInterval = 0,
        repeatCount: Float = 3
    ) {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = duration
        animation.fromValue = 1
        animation.toValue = 0.3
        animation.autoreverses = true
        animation.repeatCount = repeatCount
        animation.beginTime = CACurrentMediaTime() + delay
        
        view.layer.add(animation, forKey: "flash")
    }
    
    /// 脉冲动画
    /// - Parameters:
    ///   - view: 需要动画的视图
    ///   - duration: 动画持续时间
    ///   - delay: 延迟时间
    ///   - repeatCount: 重复次数
    public static func pulse(
        view: UIView,
        duration: TimeInterval = 0.5,
        delay: TimeInterval = 0,
        repeatCount: Float = HUGE
    ) {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.duration = duration
        animation.fromValue = 1.0
        animation.toValue = 1.1
        animation.autoreverses = true
        animation.repeatCount = repeatCount
        animation.beginTime = CACurrentMediaTime() + delay
//        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        view.layer.add(animation, forKey: "pulse")
    }
    
    /// 自定义路径动画
    /// - Parameters:
    ///   - view: 需要动画的视图
    ///   - path: 路径
    ///   - duration: 动画持续时间
    ///   - delay: 延迟时间
    ///   - completion: 完成回调
    public static func animateAlongPath(
        view: UIView,
        path: UIBezierPath,
        duration: TimeInterval = 1.5,
        delay: TimeInterval = 0,
        completion: ((Bool) -> Void)? = nil
    ) {
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path.cgPath
        animation.duration = duration
        animation.beginTime = CACurrentMediaTime() + delay
//        animation.calculationMode = CAAnimationCalculationMode.paced
//        animation.fillMode = CAAnimationCalculationMode.forwards
        animation.isRemovedOnCompletion = false
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            view.layer.position = path.currentPoint
            completion?(true)
        }
        
        view.layer.add(animation, forKey: "moveAlongPath")
        
        CATransaction.commit()
    }
    
    /// 翻转动画
    /// - Parameters:
    ///   - view: 需要动画的视图
    ///   - duration: 动画持续时间
    ///   - direction: 翻转方向
    ///   - completion: 完成回调
    public static func flip(
        view: UIView,
        duration: TimeInterval = 0.6,
        direction: UIView.AnimationOptions = .transitionFlipFromRight,
        completion: ((Bool) -> Void)? = nil
    ) {
        UIView.transition(
            with: view,
            duration: duration,
            options: direction,
            animations: nil,
            completion: completion
        )
    }
    
    /// 创建一个CAGradientLayer并添加到视图
    /// - Parameters:
    ///   - view: 需要添加渐变的视图
    ///   - colors: 渐变颜色数组
    ///   - startPoint: 渐变起点
    ///   - endPoint: 渐变终点
    ///   - locations: 颜色位置数组
    /// - Returns: 创建的CAGradientLayer
    @discardableResult
    public static func addGradient(
        to view: UIView,
        colors: [UIColor],
        startPoint: CGPoint = CGPoint(x: 0, y: 0),
        endPoint: CGPoint = CGPoint(x: 1, y: 1),
        locations: [NSNumber]? = nil
    ) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        if let locations = locations {
            gradientLayer.locations = locations
        }
        
        view.layer.insertSublayer(gradientLayer, at: 0)
        return gradientLayer
    }
} 
