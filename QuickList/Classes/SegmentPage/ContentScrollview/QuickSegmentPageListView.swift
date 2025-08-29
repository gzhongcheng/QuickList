//
//  QuickSegmentPageListView.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/8/29.
//

import UIKit

public class QuickSegmentPageListView: QuickListView, QuickSegmentPageScrollViewType {
    public var scrollOffsetObserve: NSKeyValueObservation?
    public var scrollLastOffset: CGPoint = .zero
    public var isQuickSegmentSubPage: Bool = false
    
    public func observeScrollViewContentOffset(to manager: QuickSegmentScrollManager) {
        scrollOffsetObserve = self.observe(\.contentOffset, options: [.initial, .new, .old], changeHandler: { [weak self] (scrollView, change) in
            guard let self = self else {
                return
            }
            guard change.newValue != change.oldValue else {
                return
            }
            manager.scrollViewDidScroll(self, from: self.scrollLastOffset)
            self.scrollLastOffset = self.contentOffset
        })
    }
    
    public func removeObserveScrollViewContentOffset() {
        scrollOffsetObserve?.invalidate()
        scrollOffsetObserve = nil
    }
}

extension QuickSegmentPageListView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        /// 如果正在滚动的过程中，强行停止滚动
        if
            gestureRecognizer.state == .possible,
            self.isDecelerating
        {
            self.setContentOffset(self.scrollLastOffset, animated: false)
        }
        
        /// 获取点击的位置所在的section
        let touchPoint = gestureRecognizer.location(in: self)
        if !self.bounds.contains(touchPoint) {
            return false
        }
        if self.isQuickSegmentSubPage {
            return true
        }
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
                return false
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
            return false
        }
        if section.otherPageGestureRecognizers.contains(otherGestureRecognizer) {
            return false
        }
        if gestureRecognizer.state == .possible {
            scrollManager.touchSection = section
        }
        return true
    }
}
