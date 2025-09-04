//
//  QuickSegmentScrollViewType.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/8/29.
//

import UIKit

public protocol QuickSegmentScrollViewType: UIScrollView {
    /// 设置contentOffsetX时和contentOffsetY时会同步更新scrollLastOffset，避免重复触发监听
    var contentOffsetX: CGFloat { set get }
    var contentOffsetY: CGFloat { set get }
    /// 是否是QuickSegment的子页面
    var isQuickSegmentSubPage: Bool { get set }
    /// 滚动方向
    var scrollDirection: UICollectionView.ScrollDirection { get set }
    /// 滚动管理器
    var scrollManager: QuickSegmentScrollManager? { get set }
    /// 设置内容偏移量
    /// - Parameters:
    ///  - contentOffset: 偏移量
    ///  - noticeManager: 是否通知管理器
    func setContentOffset(_ contentOffset: CGPoint, noticeManager: Bool)
}

public protocol QuickSegmentPageScrollViewType: QuickSegmentScrollViewType {
    /// 滚动管理器
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
    
    
    /// 强制停止滚动
    public func forceStopScroll() {
        let offset = contentOffset
        setContentOffset(offset, animated: false)
        setContentOffset(offset, animated: false)
    }
}
