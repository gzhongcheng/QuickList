//
//  QuickSegmentScrollViewType.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/8/29.
//

import UIKit

public protocol QuickSegmentScrollViewType: UIScrollView {
    /**
     * 设置contentOffsetX时和contentOffsetY时会同步更新scrollLastOffset，避免重复触发监听
     * When setting contentOffsetX and contentOffsetY, the scrollLastOffset will be updated synchronously to avoid repeated triggering of monitoring
     */
    var contentOffsetX: CGFloat { set get }
    var contentOffsetY: CGFloat { set get }
    /**
     * 是否是QuickSegment的子页面
     * Whether is QuickSegment's sub page
     */
    var isQuickSegmentSubPage: Bool { get set }
    /**
     * 滚动方向
     * Scroll direction
     */
    var scrollDirection: UICollectionView.ScrollDirection { get set }
    /**
     * 滚动管理器
     * Scroll manager
     */
    var scrollManager: QuickSegmentScrollManager? { get set }
    /// 设置内容偏移量
    /// Set content offset
    /// - Parameters:
    ///  - contentOffset: 偏移量 / Offset
    ///  - noticeManager: 是否通知管理器 / Whether to notify the manager
    func setContentOffset(_ contentOffset: CGPoint, noticeManager: Bool)
}

public protocol QuickSegmentPageScrollViewType: QuickSegmentScrollViewType {
    /**
     * 滚动管理器
     * Scroll manager
     */
    var pageBoxView: QuickSegmentPagesListView? { get set }
}

extension QuickSegmentScrollViewType {
    public var contentOffsetX: CGFloat {
        get {
            return contentOffset.x
        }
        set {
            setContentOffset(CGPoint(x: newValue, y: contentOffsetY), noticeManager: false)
        }
    }
    
    public var contentOffsetY: CGFloat {
        get {
            return contentOffset.y
        }
        set {
            setContentOffset(CGPoint(x: contentOffsetX, y: newValue), noticeManager: false)
        }
    }
    
    
    /**
     * 强制停止滚动
     * Force stop scrolling
     */
    public func forceStopScroll() {
        let offset = contentOffset
        setContentOffset(offset, animated: false)
        setContentOffset(offset, animated: false)
    }
}
