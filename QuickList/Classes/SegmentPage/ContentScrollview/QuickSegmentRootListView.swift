//
//  QuickSegmentRootListView.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/9/2.
//

import Foundation

public class QuickSegmentRootListView: QuickListView, QuickSegmentScrollViewType {
    public var scrollOffsetObserve: NSKeyValueObservation?
    public var isQuickSegmentSubPage: Bool = false
    public var scrollManager: QuickSegmentScrollManager?
    
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

extension QuickSegmentRootListView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        /// 如果正在滚动的过程中，强行停止滚动
        if
            gestureRecognizer.state == .possible,
            self.isDecelerating
        {
            self.forceStopScroll()
        }
        
        /// 获取点击的位置所在的section
        let touchPoint = gestureRecognizer.location(in: self)
        var touchSectionIndex: Int?
        for (i, attr) in self.handler.layout.sectionAttributes {
            switch self.scrollDirection {
            case .vertical:
                if attr.startPoint.y <= touchPoint.y, touchPoint.y <= attr.endPoint.y {
                    touchSectionIndex = i
                }
            case .horizontal:
                if attr.startPoint.x <= touchPoint.x, touchPoint.x <= attr.endPoint.x {
                    touchSectionIndex = i
                }
            @unknown default:
                return true
            }
            if touchSectionIndex != nil {
                break
            }
        }
        guard
            let sectionIndex = touchSectionIndex,
            sectionIndex < self.form.count,
            let section = self.form[sectionIndex] as? QuickSegmentSection,
            let scrollManager = section.scrollManager
        else {
            if gestureRecognizer is UIPanGestureRecognizer, otherGestureRecognizer is UIPanGestureRecognizer {
                return true
            }
            return false
        }
        if gestureRecognizer.state == .possible {
            scrollManager.touchSection = section
        }
        if gestureRecognizer is UIPanGestureRecognizer, otherGestureRecognizer is UIPanGestureRecognizer {
            return true
        }
        return false
    }
}
