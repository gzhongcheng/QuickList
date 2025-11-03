//
//  ConcatenateListReloadAnimation.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/11/1.
//

import Foundation

// MARK: - ConcatenateAnimationType
public protocol ConcatenateAnimationType: ListReloadAnimation {
    /**
     * 在进入动画之前
     * Before entering animation
     */
    func beforeIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?)
    /**
     * 在进入动画之后
     * After entering animation
     */
    func afterIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?)

    /**
     * 在退出动画时cell的截图需要执行的动画
     * Animation to be executed during the exit animation
     */
    func outSnapshotAnimation(view: UIView, to item: Item?, at section: Section)
}

extension ConcatenateAnimationType {
    public func concatenate(with animation: ConcatenateAnimationType) -> ConcatenateListReloadAnimation {
        if let self = self as? ConcatenateListReloadAnimation {
            return self.concatenate(with: animation)
        }
        return ConcatenateListReloadAnimation(animations: [self, animation])
    }
}

// MARK: - ConcatenateListReloadAnimation
public class ConcatenateListReloadAnimation: ListReloadAnimation {
    public var animations: [ConcatenateAnimationType] = []
    public init(animations: [ConcatenateAnimationType]) {
        self.animations = animations
        super.init()
    }

    public func concatenate(with animation: ConcatenateAnimationType) -> ConcatenateListReloadAnimation {
        animations.append(animation)
        return self
    }

    public override func animateIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        for animation in animations {
            animation.beforeIn(view: view, to: item, at: section, lastAttributes: lastAttributes, targetAttributes: targetAttributes)
        }
        view.alpha = 0
        targetAttributes?.alpha = 0
        view.superview?.layoutIfNeeded()
        DispatchQueue.main.async {
            UIView.animate(withDuration: self.duration, animations: { [weak self] in
                guard let self = self else { return }
                for animation in self.animations {
                    animation.afterIn(view: view, to: item, at: section, lastAttributes: lastAttributes, targetAttributes: targetAttributes)
                }
                view.alpha = 1
                targetAttributes?.alpha = 1
            })
        }
    }
    public override func animateOut(view: UIView, to item: Item?, at section: Section) {
        addOutSnapshotAndDoAnimation(view: view, at: section, animation: { [weak self] snapshot in
            guard let self = self else { return }
            for animation in self.animations {
                animation.outSnapshotAnimation(view: snapshot, to: item, at: section)
            }
        })
    }
}
