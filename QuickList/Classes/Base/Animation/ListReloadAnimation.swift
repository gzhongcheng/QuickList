//
//  ListReloadAnimation.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/10/23.
//

import Foundation

// MARK: - ListReloadAnimation
/**
 * 列表刷新动画
 * List reload animation
 */
open class ListReloadAnimation: NSObject {
    /**
     * 无动画
     * No animation
     */
    public static let none: ListReloadAnimation = ListReloadAnimation()
    
    /**
     * 淡入淡出动画
     * Fade in and fade out animation
     */
    public static let fade: FadeListReloadAnimation = FadeListReloadAnimation()
    /**
     * 缩放动画
     * Scale animation
     */
    public static let scaleX: ScaleListReloadAnimation = ScaleListReloadAnimation(scaleX: true, scaleY: false)
    public static let scaleY: ScaleListReloadAnimation = ScaleListReloadAnimation(scaleX: false, scaleY: true)
    public static let scaleXY: ScaleListReloadAnimation = ScaleListReloadAnimation(scaleX: true, scaleY: true)
    /**
     * 3D折叠动画
     * 3D fold animation
     */
    public static let threeDFold: ThreeDFoldListReloadAnimation = ThreeDFoldListReloadAnimation()

    /**
     * 从左滑入, 从左滑出动画
     * Slide from left, slide from left animation
     */
    public static let leftSlide: LeftSlideListReloadAnimation = LeftSlideListReloadAnimation()
    /**
     * 从右滑入, 从右滑出动画
     * Slide from right, slide from right animation
     */
    public static let rightSlide: RightSlideListReloadAnimation = RightSlideListReloadAnimation()
    /**
     * 从上滑入, 从上滑出动画
     * Slide from top, slide from top animation
     */
    public static let topSlide: TopSlideListReloadAnimation = TopSlideListReloadAnimation()
    /**
     * 从下滑入, 从下滑出动画
     * Slide from bottom, slide from bottom animation
     */
    public static let bottomSlide: BottomSlideListReloadAnimation = BottomSlideListReloadAnimation()
    /**
     * 从旧的cell位置移动到新的cell位置
     * Move from the old cell position to the new cell position
     */
    public static let transform: TransformListReloadAnimation = TransformListReloadAnimation()

    /**
     * 动画时长
     * Animation duration
     */
    public var duration: TimeInterval = 0.3

    /**
     * 动画进入
     * Animate in
     */
    open func animateIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        /**
         * 如果targetAttributes有frame，则设置view的frame为targetAttributes的frame, 子类重写时需要先调用此方法来设置view的frame，避免动画效果不正确
         * If targetAttributes has frame, set view's frame to targetAttributes's frame, subclasses need to call this method first to set view's frame, to avoid incorrect animation effect
         */
        if let frame = targetAttributes?.frame {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            view.frame = frame
            view.updateConstraintsIfNeeded()
            CATransaction.commit()
        }
    }

    /**
     * 动画退出，因为列表刷新后，cell就会被替换掉，因此这里需要复制一个一模一样的cell的截图出来，然后进行动画退出，可以调用addOutSnapshotAndDoAnimation方法来实现
     * Animate out, because the cell will be replaced after the list is refreshed, so here we need to copy a screenshot of a cell and then animate out, you can call addOutSnapshotAndDoAnimation method to achieve this
     */
    open func animateOut(view: UIView, to item: Item?, at section: Section) {
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
    public func addOutSnapshotAndDoAnimation(view: UIView, at section: Section, delay: TimeInterval = 0, options: UIView.AnimationOptions = [.curveEaseInOut], animation: @escaping (UIView) -> Void) {
        guard
            let snapshot = view.snapshotView(afterScreenUpdates: true),
            let targetView = section.form?.listView ?? (UIApplication.shared.windows.first { $0.isKeyWindow })
        else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        snapshot.layer.zPosition = view.layer.zPosition
        snapshot.frame = view.convert(view.bounds, to: targetView)
        view.alpha = 0
        targetView.addSubview(snapshot)
        targetView.layoutIfNeeded()
        CATransaction.commit()
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
            animation(snapshot)
        }, completion: { _ in
            snapshot.removeFromSuperview()
        })
    }
}

