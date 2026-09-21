//
//  QuickSegmentPagesListView.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/9/4.
//

import Foundation

public class QuickSegmentPagesListView: QuickListView, QuickSegmentScrollViewType {
    public var scrollOffsetObserve: NSKeyValueObservation?
    public var isQuickSegmentSubPage: Bool = false
    public var pageScrollEnable: Bool = true
    public weak var scrollManager: QuickSegmentScrollManager?

    weak var pagesItem: QuickSegmentPagesItem? {
        didSet {
            if oldValue !== pagesItem {
                lastMacPageSize = .zero
                setNeedsLayout()
            }
        }
    }
    private var lastMacPageSize: CGSize = .zero
    private(set) var isRestoringPageAfterResize = false

    public override func layoutSubviews() {
        let size = bounds.size
        guard usesMacWindowLayout, !isRestoringPageAfterResize,
              size.width.isFinite, size.height.isFinite,
              size.width > 0, size.height > 0, size != lastMacPageSize,
              let pagesItem = pagesItem,
              let section = pagesItem.section as? QuickSegmentSection,
              pagesItem.pageViewControllers.indices.contains(section.currentPageIndex) else {
            super.layoutSubviews()
            return
        }

        isRestoringPageAfterResize = true
        defer { isRestoringPageAfterResize = false }
        UIView.performWithoutAnimation {
            // Refresh cached item frames before UIKit lays out visible cells;
            // otherwise the old offset can briefly expose a different page.
            handler.updateLayout()
            let indexPath = IndexPath(item: section.currentPageIndex, section: 0)
            if let attributes = collectionViewLayout.layoutAttributesForItem(at: indexPath) {
                lastMacPageSize = size
                contentSize = collectionViewLayout.collectionViewContentSize
                let offset: CGPoint
                switch scrollDirection {
                case .horizontal:
                    offset = CGPoint(x: attributes.frame.minX, y: contentOffset.y)
                case .vertical:
                    offset = CGPoint(x: contentOffset.x, y: attributes.frame.minY)
                @unknown default:
                    offset = contentOffset
                }
                // Resizing is not a page switch or a nested scrolling gesture.
                super.setContentOffset(offset, animated: false)
            }
            super.layoutSubviews()
        }
    }
    
    public override var contentOffset: CGPoint {
        get {
            return super.contentOffset
        }
        set {
            if super.contentOffset == newValue {
                return
            }
            let oldValue = super.contentOffset
            super.contentOffset = newValue
            if !isRestoringPageAfterResize {
                self.scrollManager?.scrollViewDidScroll(self, from: oldValue)
            }
        }
    }
    
    public func setContentOffset(_ contentOffset: CGPoint, noticeManager: Bool) {
        if noticeManager {
            self.contentOffset = contentOffset
        } else {
            super.contentOffset = contentOffset
        }
    }
}

extension QuickSegmentPagesListView: UIGestureRecognizerDelegate {
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer, gestureRecognizer.view == self {
            if !self.pageScrollEnable {
                return false
            }
            let velocity = (gestureRecognizer as! UIPanGestureRecognizer).velocity(in: self)
            if self.scrollDirection == .horizontal {
                if abs(velocity.y) > abs(velocity.x) {
                    return false
                }
            } else {
                if abs(velocity.x) > abs(velocity.y) {
                    return false
                }
            }
        }
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        /**
         * 如果正在滚动的过程中，强行停止滚动
         * If the scrolling is in progress, forcibly stop scrolling
         */
        if
            gestureRecognizer.state == .possible,
            self.isDecelerating
        {
            self.forceStopScroll()
        }
        if gestureRecognizer is UIPanGestureRecognizer, otherGestureRecognizer is UIPanGestureRecognizer {
            return true
        }
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if
            let swipe = gestureRecognizer as? UISwipeGestureRecognizer,
            swipe.view == self,
            otherGestureRecognizer is UIPanGestureRecognizer
        {
            return self.needIgnoreSwipe(swipe)
        }
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if
            let swipe = otherGestureRecognizer as? UISwipeGestureRecognizer,
            swipe.view == self,
            gestureRecognizer is UIPanGestureRecognizer
        {
            return self.needIgnoreSwipe(swipe)
        }
        return false
    }
    
    func needIgnoreSwipe(_ swipe: UISwipeGestureRecognizer) -> Bool {
        if self.scrollDirection == .horizontal {
            if
                self.contentOffset.x <= 0,
                swipe.direction == .left
            {
                return true
            }
            if
                self.contentOffsetX >= (self.contentSize.width - self.bounds.width),
                swipe.direction == .right
            {
                return true
            }
        } else {
            if
                self.contentOffset.y <= 0,
                swipe.direction == .up
            {
                return true
            }
            if
                self.contentOffsetY >= (self.contentSize.height - self.bounds.height),
                swipe.direction == .down
            {
                return true
            }
        }
        return false
    }
}
