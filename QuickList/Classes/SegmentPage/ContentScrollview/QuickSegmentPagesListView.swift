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
            self.scrollManager?.scrollViewDidScroll(self, from: oldValue)
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
        /// 如果正在滚动的过程中，强行停止滚动
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
