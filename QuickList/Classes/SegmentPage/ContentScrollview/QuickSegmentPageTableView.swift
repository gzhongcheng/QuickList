//
//  QuickSegmentPageTableView.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/8/29.
//

import Foundation
import UIKit

public class QuickSegmentPageTableView: UITableView, QuickSegmentPageScrollViewType {
    public var scrollOffsetObserve: NSKeyValueObservation?
    public var isQuickSegmentSubPage: Bool = false
    public var scrollDirection: UICollectionView.ScrollDirection = .vertical
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

extension QuickSegmentPageTableView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer, otherGestureRecognizer is UIPanGestureRecognizer {
            return true
        }
        return false
    }
}
