//
//  QuickSegmentPageListView.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/8/29.
//

import UIKit

public class QuickSegmentPageListView: QuickListView, QuickSegmentPageScrollViewType {
    public var scrollOffsetObserve: NSKeyValueObservation?
    public var isQuickSegmentSubPage: Bool = false
    public weak var scrollManager: QuickSegmentScrollManager?
    public weak var pageBoxView: QuickSegmentPagesListView?
    
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
            if ItemMovingHandlerMaskView._sharedInstance?.item?.isDragging == true {
                return
            }
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

extension QuickSegmentPageListView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer, otherGestureRecognizer is UIPanGestureRecognizer {
            return true
        }
        return false
    }
}
