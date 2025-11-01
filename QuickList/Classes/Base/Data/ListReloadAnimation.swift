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
    public static let scaleX: ListReloadAnimation = ScaleListReloadAnimation(scaleX: true, scaleY: false)
    public static let scaleY: ListReloadAnimation = ScaleListReloadAnimation(scaleX: false, scaleY: true)
    public static let scaleXY: ListReloadAnimation = ScaleListReloadAnimation(scaleX: true, scaleY: true)
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
    public var duration: TimeInterval = 0.3

    /**
     * 动画进入
     * Animate in
     */
    open func animateIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
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

// MARK: - FadeListReloadAnimation
/**
 * 淡入淡出动画
 * Fade in and fade out animation
 */
public class FadeListReloadAnimation: ListReloadAnimation {
    public override func animateIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        view.alpha = 0
        targetAttributes?.alpha = 0
        view.superview?.layoutIfNeeded()
        DispatchQueue.main.async {
            UIView.animate(withDuration: self.duration, delay: 0, options: .curveEaseInOut, animations: {
                view.alpha = 1
                targetAttributes?.alpha = 1
            })
        }
    }
    public override func animateOut(view: UIView, to item: Item?, at section: Section) {
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
    public var scaleX: Bool = true
    public var scaleY: Bool = true
    public init(scaleX: Bool = true, scaleY: Bool = true) {
        self.scaleX = scaleX
        self.scaleY = scaleY
        super.init()
    }

    public override func animateIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        view.transform = CGAffineTransform(scaleX: scaleX ? 0 : 1, y: scaleY ? 0 : 1)
        view.alpha = 0
        targetAttributes?.alpha = 0
        view.superview?.layoutIfNeeded()
        DispatchQueue.main.async {
            UIView.animate(withDuration: self.duration, delay: 0, options: .curveEaseInOut, animations: {
                view.transform = .identity
                view.alpha = 1
                targetAttributes?.alpha = 1
            })
        }
    }
    public override func animateOut(view: UIView, to item: Item?, at section: Section) {
        addOutSnapshotAndDoAnimation(view: view, at: section, animation: { snapshot in
            snapshot.transform = CGAffineTransform(scaleX: self.scaleX ? 0.01 : 1, y: self.scaleY ? 0.01 : 1)
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
    public override func animateIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        view.transform = CGAffineTransform(translationX: -view.bounds.width, y: 0)
        view.alpha = 0
        targetAttributes?.alpha = 0
        view.superview?.layoutIfNeeded()
        DispatchQueue.main.async {
            UIView.animate(withDuration: self.duration, delay: 0, options: .curveEaseInOut, animations: {
                view.transform = .identity
                view.alpha = 1
                targetAttributes?.alpha = 1
            })
        }
    }
    public override func animateOut(view: UIView, to item: Item?, at section: Section) {
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
    public override func animateIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        view.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        view.alpha = 0
        targetAttributes?.alpha = 0
        view.superview?.layoutIfNeeded()
        DispatchQueue.main.async {
            UIView.animate(withDuration: self.duration, delay: 0, options: .curveEaseInOut, animations: {
                view.transform = .identity
                view.alpha = 1
                targetAttributes?.alpha = 1
            })
        }
    }
    public override func animateOut(view: UIView, to item: Item?, at section: Section) {
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
    public override func animateIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
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
    public override func animateOut(view: UIView, to item: Item?, at section: Section) {
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
    public override func animateIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        view.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
        view.alpha = 0
        targetAttributes?.alpha = 0
        view.superview?.layoutIfNeeded()
        DispatchQueue.main.async {
            UIView.animate(withDuration: self.duration, delay: 0, options: .curveEaseInOut, animations: {
                view.transform = .identity
                view.alpha = 1
                targetAttributes?.alpha = 1
            })
        }
    }
    public override func animateOut(view: UIView, to item: Item?, at section: Section) {
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
    public override func animateIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
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
    public override func animateOut(view: UIView, to item: Item?, at section: Section) {
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
public class ThreeDFoldListReloadAnimation: ListReloadAnimation, CAAnimationDelegate {
    
    /**
     * 折叠时跳过的item(仅针对单Section的折叠动画有效)
     * Items to skip during folding (only effective for single section fold animation)
     */
    public func setSkipItems(items: [Item], at section: Section) {
        var sectionLayout: QuickListBaseLayout? = section.layout
        if sectionLayout == nil {
            sectionLayout = section.form?.layout
        }
        if sectionLayout == nil {
            sectionLayout = section.form?.listLayout?.defaultLayout
        }
        guard let sectionLayout = sectionLayout else { 
            self.itemTargetFrames = [:]
            return
        }
        self.itemTargetFrames = sectionLayout.calculateItemsFrameWhenOthersFolded(items: items, at: section)
    }

    private var itemTargetFrames: [Item: CGRect] = [:]
    
    public override func animateIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        if item == nil {
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
                UIView.animate(withDuration: self.duration, delay: 0, options: .curveEaseInOut, animations: {
                    view.transform = .identity
                    view.alpha = 1
                    targetAttributes?.alpha = 1
                })
            }
            return
        }
        
        let targetItemIndex: Int = item?.indexPath?.row ?? -1
        view.alpha = 1
        targetAttributes?.alpha = 1
        guard
            let snapshotImage = view.takeSnapshot(view.bounds),
            let targetView = section.form?.listView ?? (UIApplication.shared.windows.first { $0.isKeyWindow })
        else { return }
        let snapshot = UIImageView(image: snapshotImage)
        targetView.addSubview(snapshot)
        snapshot.layer.zPosition = view.layer.zPosition
        snapshot.frame = view.convert(view.bounds, to: targetView)
        view.alpha = 0
        targetAttributes?.alpha = 0
        targetView.layoutIfNeeded()
        
        var finalPoint = targetAttributes?.frame.origin ?? CGPoint.zero
        finalPoint.x += view.frame.width * 0.5
        finalPoint.y += view.frame.height * 0.5
        var startPoint = view.frame.origin
        var lastSkipItemBeforeTargetItem: Item? = nil
        for i in itemTargetFrames.keys {
            if i.indexPath?.row ?? -1 < targetItemIndex, lastSkipItemBeforeTargetItem?.indexPath?.row ?? -1 < i.indexPath?.row ?? -1 {
                lastSkipItemBeforeTargetItem = i
            }
        }
        if 
            let lastSkipItemBeforeTargetItem = lastSkipItemBeforeTargetItem,
            let lastSkipItemBeforeTargetItemFrame = itemTargetFrames[lastSkipItemBeforeTargetItem]
        {
            startPoint = CGPoint(x: lastSkipItemBeforeTargetItemFrame.maxX, y: lastSkipItemBeforeTargetItemFrame.maxY)
        } else if
            let sectionIndex = section.index,
            let sectionAttr = section.form?.listLayout?.sectionAttributes[sectionIndex]
        {
            startPoint = CGPoint(x: sectionAttr.startPoint.x + (sectionAttr.headerAttributes?.frame.width ?? 0) + section.contentInset.left, y: sectionAttr.startPoint.y + (sectionAttr.headerAttributes?.frame.height ?? 0) + section.contentInset.top)
        }

        switch section.form?.delegate?.scrollDirection {
        case .vertical:
            startVerticalUnfoldAnimation(to: snapshot, atIndex: targetItemIndex, targetStartPoint: startPoint, targetEndPoint: finalPoint) {
                snapshot.removeFromSuperview()
                view.alpha = 1
                targetAttributes?.alpha = 1
            }
        case .horizontal:
            startHorizontalUnfoldAnimation(to: snapshot, atIndex: targetItemIndex, targetStartPoint: startPoint, targetEndPoint: finalPoint) {
                snapshot.removeFromSuperview()
                view.alpha = 1
                targetAttributes?.alpha = 1
            }
        default:
            break
        }
    }
    public override func animateOut(view: UIView, to item: Item?, at section: Section) {
        guard
            let snapshotImage = view.takeSnapshot(view.bounds),
            let targetView = section.form?.listView ?? (UIApplication.shared.windows.first { $0.isKeyWindow })
        else { return }
        let snapshot = UIImageView(image: snapshotImage)
        targetView.addSubview(snapshot)
        snapshot.layer.zPosition = view.layer.zPosition
        snapshot.frame = view.convert(view.bounds, to: targetView)
        view.alpha = 0
        targetView.layoutIfNeeded()
        

        let targetItemIndex: Int = item?.indexPath?.row ?? -1
        var lastSkipItemBeforeTargetItem: Item? = nil
        for i in itemTargetFrames.keys {
            if i.indexPath?.row ?? -1 < targetItemIndex, lastSkipItemBeforeTargetItem?.indexPath?.row ?? -1 < i.indexPath?.row ?? -1 {
                lastSkipItemBeforeTargetItem = i
            }
        }
        var endPoint = snapshot.frame.origin
        if 
            let lastSkipItemBeforeTargetItem = lastSkipItemBeforeTargetItem,
            let lastSkipItemBeforeTargetItemFrame = itemTargetFrames[lastSkipItemBeforeTargetItem]
        {
            endPoint = CGPoint(x: lastSkipItemBeforeTargetItemFrame.maxX, y: lastSkipItemBeforeTargetItemFrame.maxY)
        } else if
            let sectionIndex = section.index,
            let sectionAttr = section.form?.listLayout?.sectionAttributes[sectionIndex]
        {
            endPoint = CGPoint(x: sectionAttr.startPoint.x + (sectionAttr.headerAttributes?.frame.width ?? 0) + section.contentInset.left, y: sectionAttr.startPoint.y + (sectionAttr.headerAttributes?.frame.height ?? 0) + section.contentInset.top)
        }
        DispatchQueue.main.async {
            switch section.form?.delegate?.scrollDirection {
            case .vertical:
                self.startVerticalFoldAnimation(to: snapshot, atIndex: targetItemIndex, targetEndPoint: endPoint) {
                    snapshot.removeFromSuperview()
                }
            case .horizontal:
                self.startHorizontalFoldAnimation(to: snapshot, atIndex: targetItemIndex, targetEndPoint: endPoint) {
                    snapshot.removeFromSuperview()
                }
            default:
                break
            }
        }
    }

    func startVerticalFoldAnimation(to view: UIView, atIndex: Int, targetEndPoint: CGPoint, completion: @escaping () -> Void) {
        /**
         * 创建一个动画，用于实现3D旋转动画
         * Create a keyframe animation to implement 3D rotation animation
         */
        let transformAnimation = CABasicAnimation()
        transformAnimation.keyPath = "transform"
        var perspectiveTransform = CATransform3DIdentity
        perspectiveTransform.m34 = -2.5 / 2000
        var angle: CGFloat = CGFloat.pi * 0.5
        if atIndex % 2 == 1 {
            angle = -angle
            /**
             * 添加一个透明度为0.3的黑色遮罩，让折叠动画看起来更立体
             * Add a black mask with an alpha of 0.3 to make the fold animation look more立体
             */
            let maskLayer = CALayer()
            maskLayer.frame = view.bounds
            maskLayer.backgroundColor = UIColor.black.withAlphaComponent(0.1).cgColor
            maskLayer.opacity = 0
            view.layer.addSublayer(maskLayer)
            let alphaAnimation = CABasicAnimation()
            alphaAnimation.keyPath = "opacity"
            alphaAnimation.toValue = NSNumber(value: 1)
            alphaAnimation.duration = duration
            alphaAnimation.isRemovedOnCompletion = false
            alphaAnimation.fillMode = .forwards
            alphaAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            maskLayer.add(alphaAnimation, forKey: "AlphaAnimation")
        }
        let rotateTransform = CATransform3DRotate(perspectiveTransform, angle, 1, 0, 0)
        transformAnimation.toValue = NSValue(caTransform3D: rotateTransform)
        /**
            *  创建一个向上平移的动画
            * Create a up translation animation
            */
        let positionAnimation = CABasicAnimation()
        positionAnimation.keyPath = "position.y"
        positionAnimation.toValue = NSNumber(value: targetEndPoint.y)
        /**
         * 创建一个透明度动画
         * Create a alpha animation
         */
        let alphaAnimation = CABasicAnimation()
        alphaAnimation.keyPath = "opacity"
        alphaAnimation.toValue = NSNumber(value: 0)
        /**
         * 创建一个组合动画
         * Create a combined animation
         */
        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = duration
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = .forwards
        groupAnimation.animations = [transformAnimation, positionAnimation, alphaAnimation]
        groupAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        groupAnimation.delegate = self

        animationCompletions[groupAnimation] = completion
        view.layer.add(groupAnimation, forKey: "FoldGroupAnimation")
    }

    func startVerticalUnfoldAnimation(to view: UIView, atIndex: Int, targetStartPoint: CGPoint, targetEndPoint: CGPoint, completion: @escaping () -> Void) {
        var perspectiveTransform = CATransform3DIdentity
        perspectiveTransform.m34 = -2.5 / 2000
        var angle: CGFloat = CGFloat.pi * 0.5
        if atIndex % 2 == 1 {
            angle = -angle
            /**
             * 添加一个透明度为0.3的黑色遮罩，让折叠动画看起来更立体
             * Add a black mask with an alpha of 0.3 to make the fold animation look more立体
             */
            let maskLayer = CALayer()
            maskLayer.frame = view.bounds
            maskLayer.backgroundColor = UIColor.black.withAlphaComponent(0.1).cgColor
            view.layer.addSublayer(maskLayer)
            let alphaAnimation = CABasicAnimation()
            alphaAnimation.keyPath = "opacity"
            alphaAnimation.toValue = NSNumber(value: 0)
            alphaAnimation.duration = duration
            alphaAnimation.isRemovedOnCompletion = false
            alphaAnimation.fillMode = .forwards
            alphaAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            maskLayer.add(alphaAnimation, forKey: "AlphaAnimation")
        }
        let rotateTransform = CATransform3DRotate(perspectiveTransform, angle, 1, 0, 0)
        view.layer.transform = rotateTransform
        view.layer.position = CGPoint(x: view.layer.position.x, y: targetStartPoint.y)
        view.alpha = 0
        view.layoutIfNeeded()
        
         /**
        * 创建一个动画，用于实现3D旋转动画
        * Create a keyframe animation to implement 3D rotation animation
        */
        let transformAnimation = CABasicAnimation()
        transformAnimation.keyPath = "transform"
        transformAnimation.toValue = NSValue(caTransform3D: CATransform3DIdentity)
        /**
        *  创建一个向下平移的动画
        * Create a down translation animation
        */
        let positionAnimation = CABasicAnimation()
        positionAnimation.keyPath = "position.y"
        positionAnimation.toValue = NSNumber(value: targetEndPoint.y)
        /**
        * 创建一个透明度动画
        * Create a alpha animation
        */
        let alphaAnimation = CABasicAnimation()
        alphaAnimation.keyPath = "opacity"
        alphaAnimation.toValue = NSNumber(value: 1)
        /**
        * 创建一个组合动画
        * Create a combined animation
        */
        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = duration
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = .forwards
        groupAnimation.animations = [transformAnimation, positionAnimation, alphaAnimation]
        groupAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        groupAnimation.delegate = self

        animationCompletions[groupAnimation] = completion
        view.layer.add(groupAnimation, forKey: "UnfoldGroupAnimation")
    }

    func startHorizontalFoldAnimation(to view: UIView, atIndex: Int, targetEndPoint: CGPoint, completion: @escaping () -> Void) {
        /**
         * 创建一个动画，用于实现3D旋转动画
         * Create a keyframe animation to implement 3D rotation animation
         */
        let transformAnimation = CABasicAnimation()
        transformAnimation.keyPath = "transform"
        var perspectiveTransform = CATransform3DIdentity
        perspectiveTransform.m34 = -2.5 / 2000
        var angle: CGFloat = CGFloat.pi * 0.5
        if atIndex % 2 == 0 {
            angle = -angle
            /**
             * 添加一个透明度为0.3的黑色遮罩，让折叠动画看起来更立体
             * Add a black mask with an alpha of 0.3 to make the fold animation look more立体
             */
            let maskLayer = CALayer()
            maskLayer.frame = view.bounds
            maskLayer.backgroundColor = UIColor.black.withAlphaComponent(0.1).cgColor
            view.layer.addSublayer(maskLayer)
            let alphaAnimation = CABasicAnimation()
            alphaAnimation.keyPath = "opacity"
            alphaAnimation.toValue = NSNumber(value: 0)
            alphaAnimation.duration = duration
            alphaAnimation.isRemovedOnCompletion = false
            alphaAnimation.fillMode = .forwards
            alphaAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            maskLayer.add(alphaAnimation, forKey: "AlphaAnimation")
        }
        let rotateTransform = CATransform3DRotate(perspectiveTransform, angle, 0, 1, 0)
        transformAnimation.toValue = NSValue(caTransform3D: rotateTransform)
        /**
            *  创建一个向右平移的动画
            * Create a right translation animation
            */
        let positionAnimation = CABasicAnimation()
        positionAnimation.keyPath = "position.x"
        positionAnimation.toValue = NSNumber(value: targetEndPoint.x)
        /**
         * 创建一个透明度动画
         * Create a alpha animation
         */
        let alphaAnimation = CABasicAnimation()
        alphaAnimation.keyPath = "opacity"
        alphaAnimation.toValue = NSNumber(value: 0)
        /**
            * 创建一个组合动画
            * Create a combined animation
            */
        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = duration
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = .forwards
        groupAnimation.animations = [transformAnimation, positionAnimation, alphaAnimation]
        groupAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        groupAnimation.delegate = self

        animationCompletions[groupAnimation] = completion
        view.layer.add(groupAnimation, forKey: "FoldGroupAnimation")
    }

    func startHorizontalUnfoldAnimation(to view: UIView, atIndex: Int, targetStartPoint: CGPoint, targetEndPoint: CGPoint, completion: @escaping () -> Void) {
        /**
         * 单数往右滑出，使用3D旋转加透明度从0到1的动画，动画的centerPoint为view的右中心
         * 双数往左滑出，使用3D旋转加透明度从0到1的动画加上平移动动画移动到view的右做组合动画，动画的centerPoint为view的左中心
         * Odd index right, use 3D rotation animation plus alpha from 0 to 1 animation
         * Even index left, use 3D rotation animation plus alpha from 0 to 1 animation plus translation animation move to the right of the view to do a combined animation
         */

        /**
         * 创建一个动画，用于实现3D旋转动画
         * Create a keyframe animation to implement 3D rotation animation
         */
        var perspectiveTransform = CATransform3DIdentity
        perspectiveTransform.m34 = -2.5 / 2000
        var angle: CGFloat = CGFloat.pi * 0.5
        if atIndex % 2 == 0 {
            angle = -angle
            /**
             * 添加一个透明度为0.3的黑色遮罩，让折叠动画看起来更立体
             * Add a black mask with an alpha of 0.3 to make the fold animation look more立体
             */
            let maskLayer = CALayer()
            maskLayer.frame = view.bounds
            maskLayer.backgroundColor = UIColor.black.withAlphaComponent(0.1).cgColor
            view.layer.addSublayer(maskLayer)
            let alphaAnimation = CABasicAnimation()
            alphaAnimation.keyPath = "opacity"
            alphaAnimation.toValue = NSNumber(value: 0)
            alphaAnimation.duration = duration
            alphaAnimation.isRemovedOnCompletion = false
            alphaAnimation.fillMode = .forwards
            alphaAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            maskLayer.add(alphaAnimation, forKey: "AlphaAnimation")
        }
        let rotateTransform = CATransform3DRotate(perspectiveTransform, angle, 0, 1, 0)
        view.layer.transform = rotateTransform
        view.layer.position = CGPoint(x: targetStartPoint.x, y: view.layer.position.y)
        view.alpha = 0
        view.layoutIfNeeded()

        let transformAnimation = CABasicAnimation()
        transformAnimation.keyPath = "transform"
        transformAnimation.toValue = NSValue(caTransform3D: CATransform3DIdentity)

        /**
            *  创建一个向左平移的动画
            * Create a left translation animation
            */
        let positionAnimation = CABasicAnimation()
        positionAnimation.keyPath = "position.x"
        positionAnimation.toValue = NSNumber(value: targetEndPoint.x)
        /**
         * 创建一个透明度动画
         * Create a alpha animation
         */
        let alphaAnimation = CABasicAnimation()
        alphaAnimation.keyPath = "opacity"
        alphaAnimation.toValue = NSNumber(value: 1)
        /**
         * 创建一个组合动画
         * Create a combined animation
         */
        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = duration
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = .forwards
        groupAnimation.animations = [transformAnimation, positionAnimation, alphaAnimation]
        groupAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        groupAnimation.delegate = self
        view.layer.add(groupAnimation, forKey: "UnfoldGroupAnimation")

        animationCompletions[groupAnimation] = completion
    }

    // MARK: CAAnimationDelegate
    private var animationCompletions: [CAAnimationGroup: () -> Void] = [:]
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag, let animationGroup = anim as? CAAnimationGroup {
            for (key, completion) in animationCompletions {
                if key.animations == animationGroup.animations {
                    completion()
                    animationCompletions.removeValue(forKey: key)
                    break
                }
            }
        }
    }
}
