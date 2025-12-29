//
//  QuickScrollViewAnimator.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/12/29.
//

import UIKit

/// 动画配置
/// Animation configuration
public struct QuickScrollViewAnimationConfig {
    /// 动画时长
    /// Animation duration
    public var duration: TimeInterval = 0.3
    
    /// 动画选项
    /// Animation options
    public var options: UIView.AnimationOptions = [.curveEaseInOut]
    
    /// 弹簧阻尼（用于弹簧动画）
    /// Spring damping (for spring animation)
    public var springDamping: CGFloat = 0.7
    
    /// 初始弹簧速度
    /// Initial spring velocity
    public var initialSpringVelocity: CGFloat = 0.5
    
    /// 是否使用弹簧动画
    /// Whether to use spring animation
    public var useSpringAnimation: Bool = false
    
    public init() {}
}

/// 动画器基类
/// Base animator class
open class QuickScrollViewAnimator: QuickScrollViewAnimationDelegate {
    
    /// 动画配置
    /// Animation configuration
    public var config = QuickScrollViewAnimationConfig()
    
    /// 进入动画类型
    /// Enter animation type
    public var enterAnimation: ListReloadAnimation?
    
    /// 退出动画类型
    /// Exit animation type
    public var exitAnimation: ListReloadAnimation?
    
    /// 当前正在更新的 Sections
    /// Currently updating sections
    public var updatingSections: [Section]?
    
    /// 其他 Sections 的进入动画
    /// Enter animation for other sections
    public var otherSectionsEnterAnimation: ListReloadAnimation?
    
    public init() {}
    
    // MARK: - QuickScrollViewAnimationDelegate
    
    public func scrollView(_ scrollView: QuickScrollView, animateIn cell: QuickScrollViewCell, at indexPath: IndexPath, from initialAttributes: QuickScrollViewLayoutAttributes?, to finalAttributes: QuickScrollViewLayoutAttributes?) {
        
        guard let finalAttr = finalAttributes else { return }
        
        // 获取关联的 Item 和 Section
        // Get associated Item and Section
        var targetItem: Item?
        var targetSection: Section?
        
        if let itemCell = cell as? ItemCell {
            targetItem = itemCell.item
            targetSection = targetItem?.section
        }
        
        // 判断是否为当前更新的 Section
        // Determine if it's currently updating section
        let isUpdatingSection = targetSection != nil && (updatingSections?.contains(targetSection!) ?? false)
        let animation = isUpdatingSection ? enterAnimation : otherSectionsEnterAnimation
        
        guard let animation = animation else {
            // 无动画，直接设置最终状态
            // No animation, set final state directly
            applyFinalAttributes(finalAttr, to: cell)
            return
        }
        
        // 使用 ListReloadAnimation 进行动画
        // Use ListReloadAnimation for animation
        if let targetItem = targetItem, let targetSection = targetSection {
            let oldAttr = initialAttributes?.toCollectionViewLayoutAttributes()
            let newAttr = finalAttr.toCollectionViewLayoutAttributes()
            animation.animateIn(view: cell, to: targetItem, at: targetSection, lastAttributes: oldAttr, targetAttributes: newAttr)
        } else {
            // 回退到默认动画
            // Fallback to default animation
            performDefaultEnterAnimation(for: cell, from: initialAttributes, to: finalAttr)
        }
    }
    
    public func scrollView(_ scrollView: QuickScrollView, animateOut cell: QuickScrollViewCell, at indexPath: IndexPath, from initialAttributes: QuickScrollViewLayoutAttributes?, to finalAttributes: QuickScrollViewLayoutAttributes?) {
        
        guard let exitAnimation = exitAnimation else {
            // 无动画，直接移除
            // No animation, remove directly
            return
        }
        
        // 获取关联的 Item 和 Section
        // Get associated Item and Section
        if let itemCell = cell as? ItemCell,
           let targetItem = itemCell.item,
           let targetSection = targetItem.section {
            exitAnimation.animateOut(view: cell, to: targetItem, at: targetSection)
        }
    }
    
    public func scrollView(_ scrollView: QuickScrollView, animateInSupplementaryView view: QuickScrollViewReusableView, ofKind kind: String, at indexPath: IndexPath, from initialAttributes: QuickScrollViewLayoutAttributes?, to finalAttributes: QuickScrollViewLayoutAttributes?) {
        
        guard let finalAttr = finalAttributes else { return }
        
        let animation = enterAnimation ?? otherSectionsEnterAnimation
        
        guard animation != nil else {
            applyFinalAttributes(finalAttr, to: view)
            return
        }
        
        // 补充视图使用简单的淡入动画
        // Supplementary views use simple fade-in animation
        performDefaultEnterAnimation(for: view, from: initialAttributes, to: finalAttr)
    }
    
    public func scrollView(_ scrollView: QuickScrollView, animateOutSupplementaryView view: QuickScrollViewReusableView, ofKind kind: String, at indexPath: IndexPath, from initialAttributes: QuickScrollViewLayoutAttributes?, to finalAttributes: QuickScrollViewLayoutAttributes?) {
        // 补充视图使用简单的淡出动画
        // Supplementary views use simple fade-out animation
    }
    
    // MARK: - Private Methods
    
    private func applyFinalAttributes(_ attr: QuickScrollViewLayoutAttributes, to view: UIView) {
        view.frame = attr.frame
        view.alpha = attr.alpha
        view.transform = attr.transform
        view.layer.zPosition = CGFloat(attr.zIndex)
        view.isHidden = attr.isHidden
    }
    
    private func performDefaultEnterAnimation(for view: UIView, from initialAttr: QuickScrollViewLayoutAttributes?, to finalAttr: QuickScrollViewLayoutAttributes) {
        // 设置初始状态
        // Set initial state
        if let initialAttr = initialAttr {
            view.frame = initialAttr.frame
            view.alpha = initialAttr.alpha
            view.transform = initialAttr.transform
        } else {
            view.alpha = 0
        }
        
        // 动画到最终状态
        // Animate to final state
        if config.useSpringAnimation {
            UIView.animate(
                withDuration: config.duration,
                delay: 0,
                usingSpringWithDamping: config.springDamping,
                initialSpringVelocity: config.initialSpringVelocity,
                options: config.options,
                animations: {
                    self.applyFinalAttributes(finalAttr, to: view)
                },
                completion: nil
            )
        } else {
            UIView.animate(
                withDuration: config.duration,
                delay: 0,
                options: config.options,
                animations: {
                    self.applyFinalAttributes(finalAttr, to: view)
                },
                completion: nil
            )
        }
    }
}

// MARK: - Preset Animators

/// 淡入淡出动画器
/// Fade animator
public class QuickScrollViewFadeAnimator: QuickScrollViewAnimator {
    
    public override func scrollView(_ scrollView: QuickScrollView, animateIn cell: QuickScrollViewCell, at indexPath: IndexPath, from initialAttributes: QuickScrollViewLayoutAttributes?, to finalAttributes: QuickScrollViewLayoutAttributes?) {
        
        guard let finalAttr = finalAttributes else { return }
        
        // 设置初始状态：透明
        // Set initial state: transparent
        cell.frame = finalAttr.frame
        cell.alpha = 0
        cell.transform = finalAttr.transform
        cell.layer.zPosition = CGFloat(finalAttr.zIndex)
        
        // 动画淡入
        // Animate fade in
        UIView.animate(withDuration: config.duration, delay: 0, options: config.options) {
            cell.alpha = finalAttr.alpha
        }
    }
    
    public override func scrollView(_ scrollView: QuickScrollView, animateOut cell: QuickScrollViewCell, at indexPath: IndexPath, from initialAttributes: QuickScrollViewLayoutAttributes?, to finalAttributes: QuickScrollViewLayoutAttributes?) {
        
        // 动画淡出
        // Animate fade out
        UIView.animate(withDuration: config.duration, delay: 0, options: config.options) {
            cell.alpha = 0
        }
    }
}

/// 缩放动画器
/// Scale animator
public class QuickScrollViewScaleAnimator: QuickScrollViewAnimator {
    
    /// 初始缩放比例
    /// Initial scale
    public var initialScale: CGFloat = 0.5
    
    public override func scrollView(_ scrollView: QuickScrollView, animateIn cell: QuickScrollViewCell, at indexPath: IndexPath, from initialAttributes: QuickScrollViewLayoutAttributes?, to finalAttributes: QuickScrollViewLayoutAttributes?) {
        
        guard let finalAttr = finalAttributes else { return }
        
        // 设置初始状态：缩小
        // Set initial state: scaled down
        cell.frame = finalAttr.frame
        cell.alpha = 0
        cell.transform = CGAffineTransform(scaleX: initialScale, y: initialScale)
        cell.layer.zPosition = CGFloat(finalAttr.zIndex)
        
        // 动画放大
        // Animate scale up
        UIView.animate(withDuration: config.duration, delay: 0, options: config.options) {
            cell.alpha = finalAttr.alpha
            cell.transform = finalAttr.transform
        }
    }
    
    public override func scrollView(_ scrollView: QuickScrollView, animateOut cell: QuickScrollViewCell, at indexPath: IndexPath, from initialAttributes: QuickScrollViewLayoutAttributes?, to finalAttributes: QuickScrollViewLayoutAttributes?) {
        
        // 动画缩小消失
        // Animate scale down and disappear
        UIView.animate(withDuration: config.duration, delay: 0, options: config.options) {
            cell.alpha = 0
            cell.transform = CGAffineTransform(scaleX: self.initialScale, y: self.initialScale)
        }
    }
}

/// 滑入动画器
/// Slide animator
public class QuickScrollViewSlideAnimator: QuickScrollViewAnimator {
    
    /// 滑动方向
    /// Slide direction
    public enum SlideDirection {
        case left
        case right
        case top
        case bottom
    }
    
    /// 进入方向
    /// Enter direction
    public var enterDirection: SlideDirection = .bottom
    
    /// 退出方向
    /// Exit direction
    public var exitDirection: SlideDirection = .left
    
    /// 滑动距离
    /// Slide distance
    public var slideDistance: CGFloat = 100
    
    public override func scrollView(_ scrollView: QuickScrollView, animateIn cell: QuickScrollViewCell, at indexPath: IndexPath, from initialAttributes: QuickScrollViewLayoutAttributes?, to finalAttributes: QuickScrollViewLayoutAttributes?) {
        
        guard let finalAttr = finalAttributes else { return }
        
        // 计算初始偏移
        // Calculate initial offset
        var initialFrame = finalAttr.frame
        switch enterDirection {
        case .left:
            initialFrame.origin.x -= slideDistance
        case .right:
            initialFrame.origin.x += slideDistance
        case .top:
            initialFrame.origin.y -= slideDistance
        case .bottom:
            initialFrame.origin.y += slideDistance
        }
        
        // 设置初始状态
        // Set initial state
        cell.frame = initialFrame
        cell.alpha = 0
        cell.layer.zPosition = CGFloat(finalAttr.zIndex)
        
        // 动画滑入
        // Animate slide in
        if config.useSpringAnimation {
            UIView.animate(
                withDuration: config.duration,
                delay: 0,
                usingSpringWithDamping: config.springDamping,
                initialSpringVelocity: config.initialSpringVelocity,
                options: config.options
            ) {
                cell.frame = finalAttr.frame
                cell.alpha = finalAttr.alpha
            }
        } else {
            UIView.animate(withDuration: config.duration, delay: 0, options: config.options) {
                cell.frame = finalAttr.frame
                cell.alpha = finalAttr.alpha
            }
        }
    }
    
    public override func scrollView(_ scrollView: QuickScrollView, animateOut cell: QuickScrollViewCell, at indexPath: IndexPath, from initialAttributes: QuickScrollViewLayoutAttributes?, to finalAttributes: QuickScrollViewLayoutAttributes?) {
        
        // 计算最终偏移
        // Calculate final offset
        var targetFrame = cell.frame
        switch exitDirection {
        case .left:
            targetFrame.origin.x -= slideDistance
        case .right:
            targetFrame.origin.x += slideDistance
        case .top:
            targetFrame.origin.y -= slideDistance
        case .bottom:
            targetFrame.origin.y += slideDistance
        }
        
        // 动画滑出
        // Animate slide out
        UIView.animate(withDuration: config.duration, delay: 0, options: config.options) {
            cell.frame = targetFrame
            cell.alpha = 0
        }
    }
}

/// 3D 翻转动画器
/// 3D Flip animator
public class QuickScrollViewFlipAnimator: QuickScrollViewAnimator {
    
    /// 翻转轴
    /// Flip axis
    public enum FlipAxis {
        case x
        case y
    }
    
    /// 翻转轴
    /// Flip axis
    public var axis: FlipAxis = .y
    
    public override func scrollView(_ scrollView: QuickScrollView, animateIn cell: QuickScrollViewCell, at indexPath: IndexPath, from initialAttributes: QuickScrollViewLayoutAttributes?, to finalAttributes: QuickScrollViewLayoutAttributes?) {
        
        guard let finalAttr = finalAttributes else { return }
        
        // 设置初始状态：翻转90度
        // Set initial state: flipped 90 degrees
        cell.frame = finalAttr.frame
        cell.alpha = 0
        cell.layer.zPosition = CGFloat(finalAttr.zIndex)
        
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 500.0
        switch axis {
        case .x:
            transform = CATransform3DRotate(transform, .pi / 2, 1, 0, 0)
        case .y:
            transform = CATransform3DRotate(transform, .pi / 2, 0, 1, 0)
        }
        cell.layer.transform = transform
        
        // 动画翻转回来
        // Animate flip back
        UIView.animate(withDuration: config.duration, delay: 0, options: config.options) {
            cell.alpha = finalAttr.alpha
            cell.layer.transform = CATransform3DIdentity
        }
    }
    
    public override func scrollView(_ scrollView: QuickScrollView, animateOut cell: QuickScrollViewCell, at indexPath: IndexPath, from initialAttributes: QuickScrollViewLayoutAttributes?, to finalAttributes: QuickScrollViewLayoutAttributes?) {
        
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 500.0
        switch axis {
        case .x:
            transform = CATransform3DRotate(transform, -.pi / 2, 1, 0, 0)
        case .y:
            transform = CATransform3DRotate(transform, -.pi / 2, 0, 1, 0)
        }
        
        // 动画翻转消失
        // Animate flip and disappear
        UIView.animate(withDuration: config.duration, delay: 0, options: config.options) {
            cell.alpha = 0
            cell.layer.transform = transform
        }
    }
}
