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
    public var scrollLastOffset: CGPoint = .zero
    public var isQuickSegmentSubPage: Bool = false
    public var scrollDirection: UICollectionView.ScrollDirection = .vertical
    
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

extension QuickSegmentPageTableView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if isQuickSegmentSubPage {
            return true
        }
        return false
    }
}
