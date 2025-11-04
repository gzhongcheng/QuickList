//
//  TransformListReloadAnimation.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/11/1.
//

import Foundation

// MARK: - TransformListReloadAnimation
/**
 * 从旧的cell位置移动到新的cell位置
 * Move from the old cell position to the new cell position
 */
public class TransformListReloadAnimation: ListReloadAnimation, ConcatenateAnimationType {
    public override func animateIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        super.animateIn(view: view, to: item, at: section, lastAttributes: lastAttributes, targetAttributes: targetAttributes)
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

    // MARK: - ConcatenateAnimationType
    public func beforeIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        if
            let lastAttributes = lastAttributes,
            let targetAttributes = targetAttributes
        {
            if view.transform != .identity {
                view.transform = view.transform.translatedBy(x: lastAttributes.frame.origin.x - targetAttributes.frame.origin.x, y: lastAttributes.frame.origin.y - targetAttributes.frame.origin.y)
            } else {
                view.transform = CGAffineTransform(translationX: lastAttributes.frame.origin.x - targetAttributes.frame.origin.x, y: lastAttributes.frame.origin.y - targetAttributes.frame.origin.y)
            }
        }
    }
    public func afterIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        view.transform = .identity
    }
    public func outSnapshotAnimation(view: UIView, to item: Item?, at section: Section) {
    }
}
