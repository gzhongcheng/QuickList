//
//  FadeListReloadAnimation.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/11/1.
//

import Foundation

// MARK: - FadeListReloadAnimation
/**
 * 淡入淡出动画
 * Fade in and fade out animation
 */
public class FadeListReloadAnimation: ListReloadAnimation, ConcatenateAnimationType {
    public override func animateIn(view: UIView, viewZPosition: CGFloat, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        super.animateIn(view: view, viewZPosition: viewZPosition, to: item, at: section, lastAttributes: lastAttributes, targetAttributes: targetAttributes)
        view.alpha = 0
        DispatchQueue.main.async {
            UIView.animate(withDuration: self.duration, delay: 0, options: .curveEaseInOut, animations: {
                view.alpha = 1
            })
        }
    }
    public override func animateOut(view: UIView, viewZPosition: CGFloat, to item: Item?, at section: Section) {
        addOutSnapshotAndDoAnimation(view: view, viewZPosition: viewZPosition, at: section, animation: { snapshot in
            snapshot.alpha = 0
        })
    }

    // MARK: - ConcatenateAnimationType
    public func beforeIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
    }
    public func afterIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
    }
    public func outSnapshotAnimation(view: UIView, to item: Item?, at section: Section) {
        view.alpha = 0
    }
}

