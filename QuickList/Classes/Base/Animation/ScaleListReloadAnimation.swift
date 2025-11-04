//
//  ScaleListReloadAnimation.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/11/1.
//

import Foundation

// MARK: - ScaleListReloadAnimation
/**
 * 缩放动画
 * Scale animation
 */
public class ScaleListReloadAnimation: ListReloadAnimation, ConcatenateAnimationType {
    public var scaleX: Bool = true
    public var scaleY: Bool = true
    public init(scaleX: Bool = true, scaleY: Bool = true) {
        self.scaleX = scaleX
        self.scaleY = scaleY
        super.init()
    }

    public override func animateIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        super.animateIn(view: view, to: item, at: section, lastAttributes: lastAttributes, targetAttributes: targetAttributes)
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
            // snapshot.alpha = 0
        })
    }

    // MARK: - ConcatenateAnimationType
    public func beforeIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        if view.transform != .identity {
            view.transform = view.transform.scaledBy(x: scaleX ? 0 : 1, y: scaleY ? 0 : 1)
        } else {
            view.transform = CGAffineTransform(scaleX: scaleX ? 0 : 1, y: scaleY ? 0 : 1)
        }
    }
    public func afterIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
            view.transform = .identity
    }

    public func outSnapshotAnimation(view: UIView, to item: Item?, at section: Section) {
        if view.transform != .identity {
            view.transform = view.transform.scaledBy(x: self.scaleX ? 0.01 : 1, y: self.scaleY ? 0.01 : 1)
        } else {
            view.transform = CGAffineTransform(scaleX: self.scaleX ? 0.01 : 1, y: self.scaleY ? 0.01 : 1)
        }
    }
}

