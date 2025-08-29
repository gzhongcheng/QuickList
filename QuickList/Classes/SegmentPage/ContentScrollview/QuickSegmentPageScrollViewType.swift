//
//  QuickSegmentPageScrollViewType.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/8/29.
//

import UIKit

public protocol QuickSegmentPageScrollViewType: UIScrollView {
    var scrollOffsetObserve: NSKeyValueObservation? { get set }
    var scrollLastOffset: CGPoint { get set }
    var isQuickSegmentSubPage: Bool { get set }
    var scrollDirection: UICollectionView.ScrollDirection { get set }
    
    func observeScrollViewContentOffset(to manager: QuickSegmentScrollManager)
    func removeObserveScrollViewContentOffset()
    
    func setContentOffset(_ contentOffset: CGPoint, animated: Bool)
}
