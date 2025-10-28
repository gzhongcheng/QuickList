//
//  ListReloadAnimation.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/10/23.
//

import Foundation

/**
 * 列表刷新动画
 * List reload animation
 */
open class ListReloadAnimation {
    /**
     * 淡入淡出动画
     * Fade in and fade out animation
     */
    public static let fade: ListReloadAnimation = FadeListReloadAnimation()
    /**
     * 缩放动画
     * Scale animation
     */
    public static let scale: ListReloadAnimation = ScaleListReloadAnimation()
    /**
     * 从左滑入, 从左滑出动画
     * Slide from left, slide from left animation
     */
    public static let leftSlide: ListReloadAnimation = LeftSlideListReloadAnimation()
    /**
     * 从右滑入, 从右滑出动画
     * Slide from right, slide from right animation
     */
    public static let rightSlide: ListReloadAnimation = RightSlideListReloadAnimation()
    /**
     * 从上滑入, 从上滑出动画
     * Slide from top, slide from top animation
     */
    public static let topSlide: ListReloadAnimation = TopSlideListReloadAnimation()
    /**
     * 从下滑入, 从下滑出动画
     * Slide from bottom, slide from bottom animation
     */
    public static let bottomSlide: ListReloadAnimation = BottomSlideListReloadAnimation()
    /**
     * 从旧的cell位置移动到新的cell位置
     * Move from the old cell position to the new cell position
     */
    public static let transform: ListReloadAnimation = TransformListReloadAnimation()

    /**
     * 动画时长
     * Animation duration
     */
    public var duration: TimeInterval = 0.3

    /**
     * 动画进入
     * Animate in
     */
    open func animateIn(view: UIView, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
    }

    /**
     * 动画退出，因为列表刷新后，cell就会被替换掉，因此这里需要复制一个一模一样的cell的截图出来，然后进行动画退出，可以调用addOutSnapshotAndDoAnimation方法来实现
     * Animate out, because the cell will be replaced after the list is refreshed, so here we need to copy a screenshot of a cell and then animate out, you can call addOutSnapshotAndDoAnimation method to achieve this
     */
    open func animateOut(view: UIView) {
        // For example:
        // addOutSnapshotAndDoAnimation(view: view, animation: { snapshot in
        //     snapshot.alpha = 0
        // })
    }

    /**
     * 添加截图并进行动画
     * Add snapshot and do animation
     * - Parameters:
     *   - cell: 需要进行动画的cell / The cell to animate
     *   - animation: 执行的动画回调 / Animation callback
     */
    public func addOutSnapshotAndDoAnimation(view: UIView, delay: TimeInterval = 0, options: UIView.AnimationOptions = [.curveEaseOut], animation: @escaping (UIView) -> Void) {
        guard let snapshot = view.snapshotView(afterScreenUpdates: false) else { return }
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        window?.addSubview(snapshot)
        snapshot.frame = view.convert(view.bounds, to: window)
        view.alpha = 0
        window?.layoutIfNeeded()
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
            animation(snapshot)
        }, completion: { _ in
            snapshot.removeFromSuperview()
        })
    }
}

/**
 * 淡入淡出动画
 * Fade in and fade out animation
 */
public class FadeListReloadAnimation: ListReloadAnimation {
    public override func animateIn(view: UIView, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        view.alpha = 0
        targetAttributes?.alpha = 0
        view.superview?.layoutIfNeeded()
        DispatchQueue.main.async {
            UIView.animate(withDuration: self.duration, animations: {
                view.alpha = 1
                targetAttributes?.alpha = 1
            })
        }
    }
    public override func animateOut(view: UIView) {
        addOutSnapshotAndDoAnimation(view: view, animation: { snapshot in
            snapshot.alpha = 0
        })
    }
}

/**
 * 缩放动画
 * Scale animation
 */
public class ScaleListReloadAnimation: ListReloadAnimation {
    public override func animateIn(view: UIView, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        view.transform = CGAffineTransform(scaleX: 0, y: 0)
        view.alpha = 0
        targetAttributes?.alpha = 0
        view.superview?.layoutIfNeeded()
        DispatchQueue.main.async {
            UIView.animate(withDuration: self.duration, animations: {
                view.transform = .identity
                view.alpha = 1
                targetAttributes?.alpha = 1
            })
        }
    }
    public override func animateOut(view: UIView) {
        addOutSnapshotAndDoAnimation(view: view, animation: { snapshot in
            snapshot.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            snapshot.alpha = 0
        })
    }
}

/**
 * 从左滑入, 从左滑出
 * Slide from left, slide from left animation
 */
public class LeftSlideListReloadAnimation: ListReloadAnimation {
    public override func animateIn(view: UIView, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        view.transform = CGAffineTransform(translationX: -view.bounds.width, y: 0)
        view.alpha = 0
        targetAttributes?.alpha = 0
        view.superview?.layoutIfNeeded()
        DispatchQueue.main.async {
            UIView.animate(withDuration: self.duration, animations: {
                view.transform = .identity
                view.alpha = 1
                targetAttributes?.alpha = 1
            })
        }
    }
    public override func animateOut(view: UIView) {
        addOutSnapshotAndDoAnimation(view: view, animation: { snapshot in
            snapshot.transform = CGAffineTransform(translationX: -view.bounds.width, y: 0)
            snapshot.alpha = 0
        })
    }
}

/**
 * 从右滑入, 从右滑出
 * Slide from right, slide from right animation
 */
public class RightSlideListReloadAnimation: ListReloadAnimation {
    public override func animateIn(view: UIView, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        view.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        view.alpha = 0
        targetAttributes?.alpha = 0
        view.superview?.layoutIfNeeded()
        DispatchQueue.main.async {
            UIView.animate(withDuration: self.duration, animations: {
                view.transform = .identity
                view.alpha = 1
                targetAttributes?.alpha = 1
            })
        }
    }
    public override func animateOut(view: UIView) {
        addOutSnapshotAndDoAnimation(view: view, animation: { snapshot in
            snapshot.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
            snapshot.alpha = 0
        })
    }
}

/**
 * 从上滑入, 从上滑出
 * Slide from top, slide from top animation
 */
public class TopSlideListReloadAnimation: ListReloadAnimation {
    public override func animateIn(view: UIView, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        view.transform = CGAffineTransform(translationX: 0, y: -view.bounds.height)
        view.alpha = 0
        targetAttributes?.alpha = 0
        view.superview?.layoutIfNeeded()
        DispatchQueue.main.async {
            UIView.animate(withDuration: self.duration, animations: {
                view.transform = .identity
                view.alpha = 1
                targetAttributes?.alpha = 1
            })
        }
    }
    public override func animateOut(view: UIView) {
        addOutSnapshotAndDoAnimation(view: view, animation: { snapshot in
            snapshot.transform = CGAffineTransform(translationX: 0, y: -view.bounds.height)
            snapshot.alpha = 0
        })
    }
}

/**
 * 从下滑入, 从下滑出
 * Slide from bottom, slide from bottom animation
 */
public class BottomSlideListReloadAnimation: ListReloadAnimation { 
    public override func animateIn(view: UIView, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        view.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
        view.alpha = 0
        targetAttributes?.alpha = 0
        view.superview?.layoutIfNeeded()
        DispatchQueue.main.async {
            UIView.animate(withDuration: self.duration, animations: {
                view.transform = .identity
                view.alpha = 1
                targetAttributes?.alpha = 1
            })
        }
    }
    public override func animateOut(view: UIView) {
        addOutSnapshotAndDoAnimation(view: view, animation: { snapshot in
            snapshot.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
            snapshot.alpha = 0
        })
    }
}

/**
 * 从旧的cell位置移动到新的cell位置
 * Move from the old cell position to the new cell position
 */
public class TransformListReloadAnimation: ListReloadAnimation {
    public override func animateIn(view: UIView, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        if 
            let lastAttributes = lastAttributes, 
            let targetAttributes = targetAttributes 
        {
            let transform = CGAffineTransform(translationX: lastAttributes.frame.origin.x - targetAttributes.frame.origin.x, y: lastAttributes.frame.origin.y - targetAttributes.frame.origin.y)
            view.transform = transform
        }
        view.alpha = 0
        targetAttributes?.alpha = 0
        view.superview?.layoutIfNeeded()
        DispatchQueue.main.async {
            UIView.animate(withDuration: self.duration, animations: {
                view.transform = .identity
                view.alpha = 1
                targetAttributes?.alpha = 1
            })
        }
    }
    public override func animateOut(view: UIView) {
        addOutSnapshotAndDoAnimation(view: view, animation: { snapshot in
            // 使用渐隐动画来实现
            snapshot.alpha = 0
        })
    }
}
