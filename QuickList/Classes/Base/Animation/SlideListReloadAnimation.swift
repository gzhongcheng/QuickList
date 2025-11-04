//
//  SlideListReloadAnimation.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/11/1.
//

import Foundation

// MARK: - LeftSlideListReloadAnimation
/**
 * 从左滑入, 从左滑出
 * Slide from left, slide from left animation
 */
public class LeftSlideListReloadAnimation: ListReloadAnimation, ConcatenateAnimationType {
    public override func animateIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        super.animateIn(view: view, to: item, at: section, lastAttributes: lastAttributes, targetAttributes: targetAttributes)
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

    // MARK: - ConcatenateAnimationType
    public func beforeIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        if view.transform != .identity {
            view.transform = view.transform.translatedBy(x: -view.bounds.width, y: 0)
        } else {
            view.transform = CGAffineTransform(translationX: -view.bounds.width, y: 0)
        }
    }
    public func afterIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        view.transform = .identity
    }
    public func outSnapshotAnimation(view: UIView, to item: Item?, at section: Section) {
        if view.transform != .identity {
            view.transform = view.transform.translatedBy(x: -view.bounds.width, y: 0)
        } else {
            view.transform = CGAffineTransform(translationX: -view.bounds.width, y: 0)
        }
    }
}

// MARK: - RightSlideListReloadAnimation
/**
 * 从右滑入, 从右滑出
 * Slide from right, slide from right animation
 */
public class RightSlideListReloadAnimation: ListReloadAnimation, ConcatenateAnimationType {
    public override func animateIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        super.animateIn(view: view, to: item, at: section, lastAttributes: lastAttributes, targetAttributes: targetAttributes)
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

    // MARK: - ConcatenateAnimationType
    public func beforeIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        if view.transform != .identity {
            view.transform = view.transform.translatedBy(x: view.bounds.width, y: 0)
        } else {
            view.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        }
    }
    public func afterIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        view.transform = .identity
    }
    public func outSnapshotAnimation(view: UIView, to item: Item?, at section: Section) {
        if view.transform != .identity {
            view.transform = view.transform.translatedBy(x: view.bounds.width, y: 0)
        } else {
            view.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        }
    }
}

// MARK: - TopSlideListReloadAnimation
/**
 * 从上滑入, 从上滑出
 * Slide from top, slide from top animation
 */
public class TopSlideListReloadAnimation: ListReloadAnimation, ConcatenateAnimationType {
    public override func animateIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        super.animateIn(view: view, to: item, at: section, lastAttributes: lastAttributes, targetAttributes: targetAttributes)
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

    // MARK: - ConcatenateAnimationType
    public func beforeIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        if view.transform != .identity {
            view.transform = view.transform.translatedBy(x: 0, y: -view.bounds.height)
        } else {
            view.transform = CGAffineTransform(translationX: 0, y: -view.bounds.height)
        }
    }
    public func afterIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        view.transform = .identity
    }
    public func outSnapshotAnimation(view: UIView, to item: Item?, at section: Section) {
        if view.transform != .identity {
            view.transform = view.transform.translatedBy(x: 0, y: -view.bounds.height)
        } else {
            view.transform = CGAffineTransform(translationX: 0, y: -view.bounds.height)
        }
    }
}

// MARK: - BottomSlideListReloadAnimation
/**
 * 从下滑入, 从下滑出
 * Slide from bottom, slide from bottom animation
 */
public class BottomSlideListReloadAnimation: ListReloadAnimation, ConcatenateAnimationType {
    public override func animateIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        super.animateIn(view: view, to: item, at: section, lastAttributes: lastAttributes, targetAttributes: targetAttributes)
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

    // MARK: - ConcatenateAnimationType
    public func beforeIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        if view.transform != .identity {
            view.transform = view.transform.translatedBy(x: 0, y: view.bounds.height)
        } else {
            view.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
        }
    }
    public func afterIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        view.transform = .identity
    }
    public func outSnapshotAnimation(view: UIView, to item: Item?, at section: Section) {
        if view.transform != .identity {
            view.transform = view.transform.translatedBy(x: 0, y: view.bounds.height)
        } else {
            view.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
        }
    }
}
