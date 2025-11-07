//
//  ThreeDFoldListReloadAnimation.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/11/1.
//

import Foundation

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
        super.animateIn(view: view, to: item, at: section, lastAttributes: lastAttributes, targetAttributes: targetAttributes)
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
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        targetView.addSubview(snapshot)
        snapshot.layer.zPosition = view.layer.zPosition
        snapshot.frame = view.convert(view.bounds, to: targetView)
        view.alpha = 0
        targetAttributes?.alpha = 0
        targetView.layoutIfNeeded()
        CATransaction.commit()
        
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
            startPoint = CGPoint(x: lastSkipItemBeforeTargetItemFrame.maxX + section.itemSpace, y: lastSkipItemBeforeTargetItemFrame.maxY + section.itemSpace)
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
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        snapshot.layer.zPosition = view.layer.zPosition
        snapshot.frame = view.convert(view.bounds, to: targetView)
        view.alpha = 0
        targetView.layoutIfNeeded()
        CATransaction.commit()

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
            endPoint = CGPoint(x: lastSkipItemBeforeTargetItemFrame.maxX + section.itemSpace, y: lastSkipItemBeforeTargetItemFrame.maxY + section.itemSpace)
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
    
    func setAnchorPoint(anchorPoint: CGPoint, forView view: UIView) {
        var newPoint = CGPoint(x: view.bounds.size.width * anchorPoint.x,
                               y: view.bounds.size.height * anchorPoint.y)


        var oldPoint = CGPoint(x: view.bounds.size.width * view.layer.anchorPoint.x,
                               y: view.bounds.size.height * view.layer.anchorPoint.y)

        newPoint = newPoint.applying(view.transform)
        oldPoint = oldPoint.applying(view.transform)

        var position = view.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        view.layer.position = position
        view.layer.anchorPoint = anchorPoint
    }

    func startVerticalFoldAnimation(to view: UIView, atIndex: Int, targetEndPoint: CGPoint, completion: @escaping () -> Void) {
        /**
         * 创建一个动画，用于实现3D旋转动画
         * Create a keyframe animation to implement 3D rotation animation
         */
        let transformAnimation = CABasicAnimation()
        transformAnimation.keyPath = "transform"
        var perspectiveTransform = CATransform3DIdentity
        perspectiveTransform.m34 = 2.5 / 2000
        var angle: CGFloat = CGFloat.pi * 0.5
        if atIndex % 2 == 0 {
            setAnchorPoint(anchorPoint: CGPoint(x: 0.5, y: 0), forView: view)
            /**
             * 添加一个透明度为0.6的黑色遮罩，让折叠动画看起来更立体
             * Add a black mask with an alpha of 0.6 to make the fold animation look more立体
             */
            let maskLayer = CALayer()
            maskLayer.frame = view.bounds
            maskLayer.backgroundColor = UIColor.black.withAlphaComponent(0.6).cgColor
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
        } else {
            setAnchorPoint(anchorPoint: CGPoint(x: 0.5, y: 1), forView: view)
            angle = -angle
        }
        let rotateTransform = CATransform3DRotate(perspectiveTransform, angle, 1, 0, 0)
        transformAnimation.toValue = NSValue(caTransform3D: rotateTransform)
        transformAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        /**
            *  创建一个向上平移的动画
            * Create a up translation animation
            */
        let positionAnimation = CABasicAnimation()
        positionAnimation.keyPath = "position.y"
        positionAnimation.toValue = NSNumber(value: targetEndPoint.y)
        positionAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        /**
         * 创建一个透明度动画
         * Create a alpha animation
         */
        let alphaAnimation = CABasicAnimation()
        alphaAnimation.keyPath = "opacity"
        alphaAnimation.toValue = NSNumber(value: 0)
        alphaAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        /**
         * 创建一个组合动画
         * Create a combined animation
         */
        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = duration
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = .forwards
        groupAnimation.animations = [transformAnimation, positionAnimation, alphaAnimation]
        groupAnimation.delegate = self

        animationCompletions[groupAnimation] = completion
        view.layer.add(groupAnimation, forKey: "FoldGroupAnimation")
    }

    func startVerticalUnfoldAnimation(to view: UIView, atIndex: Int, targetStartPoint: CGPoint, targetEndPoint: CGPoint, completion: @escaping () -> Void) {
        var perspectiveTransform = CATransform3DIdentity
        perspectiveTransform.m34 = 2.5 / 2000
        var startAngle: CGFloat = CGFloat.pi * 0.5
        if atIndex % 2 == 0 {
            view.layer.position = CGPoint(x: view.layer.position.x, y: targetStartPoint.y + view.bounds.height * 0.5)
            setAnchorPoint(anchorPoint: CGPoint(x: 0.5, y: 0), forView: view)
            /**
             * 添加一个透明度为0.6的黑色遮罩，让折叠动画看起来更立体
             * Add a black mask with an alpha of 0.6 to make the fold animation look more立体
             */
            let maskLayer = CALayer()
            maskLayer.frame = view.bounds
            maskLayer.backgroundColor = UIColor.black.withAlphaComponent(0.6).cgColor
            view.layer.addSublayer(maskLayer)
            let alphaAnimation = CABasicAnimation()
            alphaAnimation.keyPath = "opacity"
            alphaAnimation.toValue = NSNumber(value: 0)
            alphaAnimation.duration = duration
            alphaAnimation.isRemovedOnCompletion = false
            alphaAnimation.fillMode = .forwards
            alphaAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            maskLayer.add(alphaAnimation, forKey: "AlphaAnimation")
        } else {
            view.layer.position = CGPoint(x: view.layer.position.x, y: targetStartPoint.y - view.bounds.height * 0.5)
            startAngle = -startAngle
            setAnchorPoint(anchorPoint: CGPoint(x: 0.5, y: 1), forView: view)
        }
        let rotateTransform = CATransform3DRotate(perspectiveTransform, startAngle, 1, 0, 0)
        view.layer.transform = rotateTransform
        view.layer.opacity = 0
        
         /**
        * 创建一个动画，用于实现3D旋转动画
        * Create a keyframe animation to implement 3D rotation animation
        */
        let transformAnimation = CABasicAnimation()
        transformAnimation.keyPath = "transform"
        transformAnimation.toValue = NSValue(caTransform3D: CATransform3DIdentity)
        transformAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        /**
        *  创建一个向下平移的动画
        * Create a down translation animation
        */
        let positionAnimation = CABasicAnimation()
        positionAnimation.keyPath = "position.y"
        if atIndex % 2 == 0 {
            positionAnimation.toValue = NSNumber(value: targetEndPoint.y - view.bounds.height * 0.5)
        } else {
            positionAnimation.toValue = NSNumber(value: targetEndPoint.y + view.bounds.height * 0.5)
        }
        positionAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        /**
        * 创建一个透明度动画
        * Create a alpha animation
        */
        let alphaAnimation = CABasicAnimation()
        alphaAnimation.keyPath = "opacity"
        alphaAnimation.toValue = NSNumber(value: 1)
        alphaAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        /**
        * 创建一个组合动画
        * Create a combined animation
        */
        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = duration
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = .forwards
        groupAnimation.animations = [transformAnimation, positionAnimation, alphaAnimation]
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
            setAnchorPoint(anchorPoint: CGPoint(x: 0, y: 0.5), forView: view)
            /**
             * 添加一个透明度为0.6的黑色遮罩，让折叠动画看起来更立体
             * Add a black mask with an alpha of 0.6 to make the fold animation look more立体
             */
            let maskLayer = CALayer()
            maskLayer.frame = view.bounds
            maskLayer.backgroundColor = UIColor.black.withAlphaComponent(0.6).cgColor
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
        } else {
            angle = -angle
            setAnchorPoint(anchorPoint: CGPoint(x: 1, y: 0.5), forView: view)
        }
        let rotateTransform = CATransform3DRotate(perspectiveTransform, angle, 0, 1, 0)
        transformAnimation.toValue = NSValue(caTransform3D: rotateTransform)
        transformAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        /**
            *  创建一个向右平移的动画
            * Create a right translation animation
            */
        let positionAnimation = CABasicAnimation()
        positionAnimation.keyPath = "position.x"
        positionAnimation.toValue = NSNumber(value: targetEndPoint.x)
        positionAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        /**
         * 创建一个透明度动画
         * Create a alpha animation
         */
        let alphaAnimation = CABasicAnimation()
        alphaAnimation.keyPath = "opacity"
        alphaAnimation.toValue = NSNumber(value: 0)
        alphaAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        /**
            * 创建一个组合动画
            * Create a combined animation
            */
        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = duration
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = .forwards
        groupAnimation.animations = [transformAnimation, positionAnimation, alphaAnimation]
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
            view.layer.position = CGPoint(x: targetStartPoint.x + view.bounds.width * 0.5, y: view.layer.position.y)
            setAnchorPoint(anchorPoint: CGPoint(x: 0, y: 0.5), forView: view)
            /**
             * 添加一个透明度为0.6的黑色遮罩，让折叠动画看起来更立体
             * Add a black mask with an alpha of 0.6 to make the fold animation look more立体
             */
            let maskLayer = CALayer()
            maskLayer.frame = view.bounds
            maskLayer.backgroundColor = UIColor.black.withAlphaComponent(0.6).cgColor
            view.layer.addSublayer(maskLayer)
            let alphaAnimation = CABasicAnimation()
            alphaAnimation.keyPath = "opacity"
            alphaAnimation.toValue = NSNumber(value: 0)
            alphaAnimation.duration = duration
            alphaAnimation.isRemovedOnCompletion = false
            alphaAnimation.fillMode = .forwards
            alphaAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            maskLayer.add(alphaAnimation, forKey: "AlphaAnimation")
        } else {
            view.layer.position = CGPoint(x: targetStartPoint.x - view.bounds.width * 0.5, y: view.layer.position.y)
            setAnchorPoint(anchorPoint: CGPoint(x: 1, y: 0.5), forView: view)
            angle = -angle
        }
        let rotateTransform = CATransform3DRotate(perspectiveTransform, angle, 0, 1, 0)
        view.layer.transform = rotateTransform
        view.alpha = 0

        let transformAnimation = CABasicAnimation()
        transformAnimation.keyPath = "transform"
        transformAnimation.toValue = NSValue(caTransform3D: CATransform3DIdentity)
        transformAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        /**
            *  创建一个向左平移的动画
            * Create a left translation animation
            */
        let positionAnimation = CABasicAnimation()
        positionAnimation.keyPath = "position.x"
        if atIndex % 2 == 0 {
            positionAnimation.toValue = NSNumber(value: targetEndPoint.x - view.bounds.width * 0.5)
        } else {
            positionAnimation.toValue = NSNumber(value: targetEndPoint.x + view.bounds.width * 0.5)
        }
        positionAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        /**
         * 创建一个透明度动画
         * Create a alpha animation
         */
        let alphaAnimation = CABasicAnimation()
        alphaAnimation.keyPath = "opacity"
        alphaAnimation.toValue = NSNumber(value: 1)
        alphaAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        /**
         * 创建一个组合动画
         * Create a combined animation
         */
        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = duration
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = .forwards
        groupAnimation.animations = [transformAnimation, positionAnimation, alphaAnimation]
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
