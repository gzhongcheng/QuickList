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
open class ListReloadAnimation: NSObject {
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
     * 3D折叠动画
     * 3D fold animation
     */
    public static let threeDFold: ListReloadAnimation = ThreeDFoldListReloadAnimation()

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
    public var duration: TimeInterval = 3

    /**
     * 动画进入
     * Animate in
     */
    open func animateIn(view: UIView, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
    }

    /**
     * 动画退出，因为列表刷新后，cell就会被替换掉，因此这里需要复制一个一模一样的cell的截图出来，然后进行动画退出，可以调用addOutSnapshotAndDoAnimation方法来实现
     * Animate out, because the cell will be replaced after the list is refreshed, so here we need to copy a screenshot of a cell and then animate out, you can call addOutSnapshotAndDoAnimation method to achieve this
     */
    open func animateOut(view: UIView, at section: Section) {
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
    public func addOutSnapshotAndDoAnimation(view: UIView, at section: Section, delay: TimeInterval = 0, options: UIView.AnimationOptions = [.curveEaseOut], animation: @escaping (UIView) -> Void) {
        guard
            let snapshot = view.snapshotView(afterScreenUpdates: true),
            let targetView = section.form?.listView ?? (UIApplication.shared.windows.first { $0.isKeyWindow })
        else { return }
        targetView.addSubview(snapshot)
        snapshot.layer.zPosition = view.layer.zPosition
        snapshot.frame = view.convert(view.bounds, to: targetView)
        view.alpha = 0
        targetView.layoutIfNeeded()
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
            animation(snapshot)
        }, completion: { _ in
            snapshot.removeFromSuperview()
        })
    }
}

// MARK: - UIView + extension
private extension UIView {
    func takeSnapshot(_ frame: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.translateBy(x: frame.origin.x * -1, y: frame.origin.y * -1)
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

// MARK: - FadeListReloadAnimation
/**
 * 淡入淡出动画
 * Fade in and fade out animation
 */
public class FadeListReloadAnimation: ListReloadAnimation {
    public override func animateIn(view: UIView, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
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
    public override func animateOut(view: UIView, at section: Section) {
        addOutSnapshotAndDoAnimation(view: view, at: section, animation: { snapshot in
            snapshot.alpha = 0
        })
    }
}

// MARK: - ScaleListReloadAnimation
/**
 * 缩放动画
 * Scale animation
 */
public class ScaleListReloadAnimation: ListReloadAnimation {
    public override func animateIn(view: UIView, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
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
    public override func animateOut(view: UIView, at section: Section) {
        addOutSnapshotAndDoAnimation(view: view, at: section, animation: { snapshot in
            snapshot.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            snapshot.alpha = 0
        })
    }
}

// MARK: - LeftSlideListReloadAnimation
/**
 * 从左滑入, 从左滑出
 * Slide from left, slide from left animation
 */
public class LeftSlideListReloadAnimation: ListReloadAnimation {
    public override func animateIn(view: UIView, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
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
    public override func animateOut(view: UIView, at section: Section) {
        addOutSnapshotAndDoAnimation(view: view, at: section, animation: { snapshot in
            snapshot.transform = CGAffineTransform(translationX: -view.bounds.width, y: 0)
            snapshot.alpha = 0
        })
    }
}

// MARK: - RightSlideListReloadAnimation
/**
 * 从右滑入, 从右滑出
 * Slide from right, slide from right animation
 */
public class RightSlideListReloadAnimation: ListReloadAnimation {
    public override func animateIn(view: UIView, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
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
    public override func animateOut(view: UIView, at section: Section) {
        addOutSnapshotAndDoAnimation(view: view, at: section, animation: { snapshot in
            snapshot.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
            snapshot.alpha = 0
        })
    }
}

// MARK: - TopSlideListReloadAnimation
/**
 * 从上滑入, 从上滑出
 * Slide from top, slide from top animation
 */
public class TopSlideListReloadAnimation: ListReloadAnimation {
    public override func animateIn(view: UIView, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
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
    public override func animateOut(view: UIView, at section: Section) {
        addOutSnapshotAndDoAnimation(view: view, at: section, animation: { snapshot in
            snapshot.transform = CGAffineTransform(translationX: 0, y: -view.bounds.height)
            snapshot.alpha = 0
        })
    }
}

// MARK: - BottomSlideListReloadAnimation
/**
 * 从下滑入, 从下滑出
 * Slide from bottom, slide from bottom animation
 */
public class BottomSlideListReloadAnimation: ListReloadAnimation { 
    public override func animateIn(view: UIView, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
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
    public override func animateOut(view: UIView, at section: Section) {
        addOutSnapshotAndDoAnimation(view: view, at: section, animation: { snapshot in
            snapshot.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
            snapshot.alpha = 0
        })
    }
}

// MARK: - TransformListReloadAnimation
/**
 * 从旧的cell位置移动到新的cell位置
 * Move from the old cell position to the new cell position
 */
public class TransformListReloadAnimation: ListReloadAnimation {
    public override func animateIn(view: UIView, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
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
    public override func animateOut(view: UIView, at section: Section) {
        addOutSnapshotAndDoAnimation(view: view, at: section, animation: { snapshot in
            // 使用渐隐动画来实现
            snapshot.alpha = 0
        })
    }
}

// MARK: - ThreeDFoldListReloadAnimation
/**
 * 3D折叠动画
 * 3D fold animation
 */
public class ThreeDFoldListReloadAnimation: ListReloadAnimation {
    
    public override func animateIn(view: UIView, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        var targetItemIndex: Int = 0
        for (index, item) in section.items.enumerated() {
            if view == item.cell {
                targetItemIndex = index
                break
            }
        }
        guard
            let snapshot = view.snapshotView(afterScreenUpdates: true),
            let targetView = section.form?.listView ?? (UIApplication.shared.windows.first { $0.isKeyWindow })
        else { return }
        targetView.addSubview(snapshot)
        snapshot.layer.zPosition = view.layer.zPosition
        snapshot.frame = view.convert(view.bounds, to: targetView)
        snapshot.alpha = 0
        view.alpha = 0
        targetAttributes?.alpha = 0
        targetView.layoutIfNeeded()
        switch section.form?.delegate?.scrollDirection {
        case .vertical:
            startVerticalUnfoldAnimation(to: snapshot, attributes: targetAttributes, atIndex: targetItemIndex) {
                snapshot.removeFromSuperview()
                view.alpha = 1
                targetAttributes?.alpha = 1
            }
        case .horizontal:
            startHorizontalUnfoldAnimation(to: snapshot, attributes: targetAttributes, atIndex: targetItemIndex) {
                snapshot.removeFromSuperview()
                view.alpha = 1
                targetAttributes?.alpha = 1
            }
        default:
            break
        }
    }
    public override func animateOut(view: UIView, at section: Section) {
        var targetItemIndex: Int = 0
        for (index, item) in section.items.enumerated() {
            if view == item.cell {
                targetItemIndex = index
                break
            }
        }
        guard
            let snapshot = view.snapshotView(afterScreenUpdates: true),
            let targetView = section.form?.listView ?? (UIApplication.shared.windows.first { $0.isKeyWindow })
        else { return }
        targetView.addSubview(snapshot)
        snapshot.layer.zPosition = view.layer.zPosition
        snapshot.frame = view.convert(view.bounds, to: targetView)
        view.alpha = 0
        targetView.layoutIfNeeded()
        DispatchQueue.main.async {
            switch section.form?.delegate?.scrollDirection {
            case .vertical:
                self.startVerticalFoldAnimation(to: snapshot, atIndex: targetItemIndex) {
                    snapshot.removeFromSuperview()
                }
            case .horizontal:
                self.startHorizontalFoldAnimation(to: snapshot, atIndex: targetItemIndex) {
                    snapshot.removeFromSuperview()
                }
            default:
                break
            }
        }
    }

    func startVerticalFoldAnimation(to view: UIView, atIndex: Int, completion: @escaping () -> Void) {
        /**
         * 单数往上翻出，使用3D旋转加透明度1到0的动画，动画的centerPoint为view的顶部中心
         * 双数往下翻出，使用3D旋转加透明度1到0的动画加上平移动画移动到view的顶部做组合动画，动画的centerPoint为view的底部中心
         * Odd index up, use 3D rotation animation plus alpha 1 to 0 animation
         * Even index down, use 3D rotation animation plus alpha 1 to 0 animation plus translation animation move to the top of the view to do a combined animation
         */
        if atIndex % 2 == 1 {
            let centerPoint = CGPoint(x: view.bounds.width / 2, y: 0)
            view.layer.anchorPoint = centerPoint
            UIView.animate(withDuration: duration, animations: {
                view.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
                view.alpha = 0
            }, completion: { _ in
                view.removeFromSuperview()
            })
        } else {
            let centerPoint = CGPoint(x: view.bounds.width / 2, y: view.bounds.height)
            view.layer.anchorPoint = centerPoint
            UIView.animate(withDuration: duration, animations: {
                view.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2).translatedBy(x: 0, y: view.bounds.height)
                view.alpha = 0
            }, completion: { _ in
                view.removeFromSuperview()
            })
        }
    }

    func startVerticalUnfoldAnimation(to view: UIView, attributes: UICollectionViewLayoutAttributes?, atIndex: Int, completion: @escaping () -> Void) {
        /**
         * 单数往下翻出，使用3D旋转加透明度从0到1的动画，动画的centerPoint为view的顶部中心
         * 双数往上翻出，使用3D旋转加透明度从0到1的动画加上平移动动画移动到view的底部做组合动画，动画的centerPoint为view的底部中心
         * Odd index down, use 3D rotation animation plus alpha from 0 to 1 animation, animation's centerPoint is the top center of the view
         * Even index up, use 3D rotation animation plus alpha from 0 to 1 animation plus translation animation move to the bottom of the view to do a combined animation, animation's centerPoint is the bottom center of the view
         * Odd index down, use 3D rotation animation, animation's centerPoint is the top center of the view
         * Even index up, use 3D rotation animation plus translation animation move to the bottom of the view to do a combined animation, animation's centerPoint is the bottom center of the view
         */
        if atIndex % 2 == 1 {
            let centerPoint = CGPoint(x: view.bounds.width / 2, y: 0)
            view.layer.anchorPoint = centerPoint
            view.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
            UIView.animate(withDuration: duration, animations: {
                view.transform = .identity
                view.alpha = 1
                attributes?.alpha = 1
            }, completion: { _ in
                completion()
            })
        } else {
            let centerPoint = CGPoint(x: view.bounds.width / 2, y: view.bounds.height)
            view.layer.anchorPoint = centerPoint
            view.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2).translatedBy(x: 0, y: view.bounds.height)
            UIView.animate(withDuration: duration, animations: {
                view.transform = .identity
                view.alpha = 1
            }, completion: { _ in
                completion()
            })
        }
    }

    func startHorizontalFoldAnimation(to view: UIView, atIndex: Int, completion: @escaping () -> Void) {
        /**
         * 单数往左滑出，使用3D旋转加透明度1到0的动画，动画的centerPoint为view的左中心
         * 双数往右滑出，使用3D旋转加透明度1到0的动画加上平移动画移动到view的左做组合动画，动画的centerPoint为view的右中心
         * Odd index left, use 3D rotation animation plus alpha 1 to 0 animation
         * Even index right, use 3D rotation animation plus alpha 1 to 0 animation plus translation animation move to the left of the view to do a combined animation
         */
        if atIndex % 2 == 1 {
            let centerPoint = CGPoint(x: 0, y: view.bounds.height / 2)
            view.layer.anchorPoint = centerPoint
            UIView.animate(withDuration: duration, animations: {
                view.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
                view.alpha = 0
            }, completion: { _ in
                completion()
            })
        } else {
            let centerPoint = CGPoint(x: view.bounds.width, y: view.bounds.height / 2)
            view.layer.anchorPoint = centerPoint
            UIView.animate(withDuration: duration, animations: {
                view.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2).translatedBy(x: 0, y: -view.bounds.width)
                view.alpha = 0
            }, completion: { _ in
                completion()
            })
        }
    }

    func startHorizontalUnfoldAnimation(to view: UIView, attributes: UICollectionViewLayoutAttributes?, atIndex: Int, completion: @escaping () -> Void) {
        /**
         * 单数往右滑出，使用3D旋转加透明度从0到1的动画，动画的centerPoint为view的右中心
         * 双数往左滑出，使用3D旋转加透明度从0到1的动画加上平移动动画移动到view的右做组合动画，动画的centerPoint为view的左中心
         * Odd index right, use 3D rotation animation plus alpha from 0 to 1 animation
         * Even index left, use 3D rotation animation plus alpha from 0 to 1 animation plus translation animation move to the right of the view to do a combined animation
         */
        if atIndex % 2 == 1 {
            let centerPoint = CGPoint(x: 0, y: view.bounds.height / 2)
            view.layer.anchorPoint = centerPoint
            view.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
            UIView.animate(withDuration: duration, animations: {
                view.transform = .identity
                view.alpha = 1
                attributes?.alpha = 1
            }, completion: { _ in
                completion()
            })
        } else {
            let centerPoint = CGPoint(x: view.bounds.width, y: view.bounds.height / 2)
            view.layer.anchorPoint = centerPoint
            view.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2).translatedBy(x: 0, y: view.bounds.width)
            UIView.animate(withDuration: duration, animations: {
                view.transform = .identity
                view.alpha = 1
                attributes?.alpha = 1
            }, completion: { _ in
                completion()
            })
        }
    }
}
