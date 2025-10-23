//
//  QuickSegmentScrollManager.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/8/27.
//

import Foundation

public class QuickSegmentScrollManager {
    /**
     * 阻尼效果
     * Bounces effect
     */
    public enum BouncesType {
        /**
         * 总列表
         * Total list
         */
        case root
        /**
         * 子列表（当总列表滚动到顶部/底部后，子列表可以继续滚动）
         * Sub list (when the total list scrolls to the top/bottom, the sub list can continue to scroll)
         */
        case page
    }
    public var bouncesType: BouncesType = .root
    
    /**
     * 当前触摸的Section
     * Current touched section
     */
    var touchSection: QuickSegmentSection? {
        didSet {
            currentScrollDirection = nil
            resetStatus()
        }
    }
    /**
     * 当前滚动方向
     * Current scroll direction
     */
    var currentScrollDirection: UICollectionView.ScrollDirection?
    /**
     * 所有的可滚动的Section
     * All scrollable sections
     */
    var allScrollableSections: [QuickSegmentSection] = []
    /**
     * 当前展示区域的可滚动的Section
     * Current visible area scrollable sections
     */
    var visibleSections: [QuickSegmentSection] = []
    /**
     * 当前可滚动的目标Section
     * Current scrollable target section
     */
    var scrollableSection: QuickSegmentSection?
    
    /**
     * 总列表
     * Total list
     */
    public weak var rootScrollView: QuickSegmentRootListView?
    /**
     * 总表的滚动方向
     * Total list scroll direction
     */
    public var rootDirection: UICollectionView.ScrollDirection = .vertical
    
    /**
     * 标记位
     * Marking bits
     */
    var canRootScroll: Bool = true
    var canPagesBoxScroll: Bool = false
    var canPageScroll: Bool = false
    
    public static func create(
        rootScrollView: QuickSegmentRootListView? = nil,
        bouncesType: BouncesType = .root
    ) -> QuickSegmentScrollManager {
        switch rootScrollView?.scrollDirection {
        case .vertical:
            switch bouncesType {
            case .root:
                return QuickSegmentVerticalRootScrollManager(rootScrollView: rootScrollView)
            case .page:
                return QuickSegmentVerticalPageScrollManager(rootScrollView: rootScrollView)
            }
        case .horizontal:
            switch bouncesType {
            case .root:
                return QuickSegmentHorizontalRootScrollManager(rootScrollView: rootScrollView)
            case .page:
                return QuickSegmentHorizontalPageScrollManager(rootScrollView: rootScrollView)
            }
        default:
            return QuickSegmentScrollManager(rootScrollView: rootScrollView)
        }
    }
    
    private init() {
    }
    
    /// 初始化
    /// Initialize
    /// - Parameters:
    ///  - rootScrollView: 总列表 / Root scroll view
    internal init(
        rootScrollView: QuickSegmentRootListView? = nil
    ) {
        guard let rootScrollView = rootScrollView else {
            assertionFailure("必须传入rootScrollView")
            return
        }
        self.rootScrollView = rootScrollView
        self.rootDirection = rootScrollView.scrollDirection
        rootScrollView.handler.layout.add(self)
        rootScrollView.scrollManager = self
    }
    
    
    /**
     * 重置标志位状态
     * Reset the flag status
     */
    private func resetStatus() {
        guard let rootScrollView = self.rootScrollView else { return }
        self.findScrollableView(to: rootScrollView, from: rootScrollView.contentOffset)
        resetStatus(for: rootScrollView)
    }
    
    /**
     * 重置标志位状态
     * Reset the flag status
     */
    func resetStatus(for rootScrollView: QuickSegmentRootListView) {
        assertionFailure("必须在子类中重写此方法")
    }
    
    /**
     * 处理滚动事件
     * Handle the scrolling event
     */
    func scrollViewDidScroll(_ scrollView: QuickSegmentScrollViewType, from lastOffset: CGPoint) {
        if currentScrollDirection == nil {
            let xD = abs(scrollView.contentOffset.x - lastOffset.x)
            let yD = abs(scrollView.contentOffset.y - lastOffset.y)
            if xD == yD {
                /**
                 * 优先以总表滚动方向为准
                 * Prioritize the root scroll view scroll direction
                 */
                currentScrollDirection = rootDirection
            } else {
                currentScrollDirection = xD > yD ? .horizontal : .vertical
            }
        }
        
        if scrollView == rootScrollView {
            rootScrollViewDidScroll(scrollView, from: lastOffset)
            return
        }
        
        for section in allScrollableSections {
            if
                let currentPageScrollView = section.currentPageScrollView,
                scrollView == currentPageScrollView
            {
                if section == scrollableSection {
                    scrollablePageScrollViewDidScroll(scrollView, from: lastOffset)
                } else {
                    unScrollablePageScrollViewDidScroll(scrollView, from: lastOffset)
                }
                return
            }
            if
                let pagesBoxScrollView = section.pagesItem.currentListView,
                scrollView == pagesBoxScrollView
            {
                pagesBoxScrollViewDidScroll(pagesBoxScrollView, at: section, from: lastOffset)
                return
            }
        }
    }
    
    /**
     * 查找目标滚动Section
     * Find the target scroll section
     */
    func findScrollableView(to rootView: QuickSegmentRootListView, from lastOffset: CGPoint) {
        assertionFailure("必须在子类中重写此方法")
    }
    
    /**
     * 总列表滚动
     * Root scroll view scroll
     */
    func rootScrollViewDidScroll(_ scrollView: QuickSegmentScrollViewType, from lastOffset: CGPoint) {
        assertionFailure("必须在子类中重写此方法")
    }
    
    /**
     * 子页面切换
     * Sub page switch
     */
    func pageDidChanged(in section: QuickSegmentSection, fromMenu: Bool) {
        guard let rootScrollView = self.rootScrollView else { return }
        switch rootDirection {
        case .vertical:
            if section.shouldScrollToTopWhenSelectedTab {
                if fromMenu {
                    UIView.animate(withDuration: 0.25) {
                        rootScrollView.contentOffsetY = section.sectionStartPoint.y - rootScrollView.adjustedContentInset.top
                    }
                    return
                }
                if rootScrollView.contentOffset.y > section.sectionStartPoint.y - rootScrollView.adjustedContentInset.top {
                    rootScrollView.contentOffsetY = section.sectionStartPoint.y - rootScrollView.adjustedContentInset.top
                }
            } else if
                (section.currentPageScrollView?.contentOffset.y ?? 0) > 0,
                rootScrollView.contentOffset.y < section.sectionStartPoint.y - rootScrollView.adjustedContentInset.top
            {
                rootScrollView.contentOffsetY = section.sectionStartPoint.y - rootScrollView.adjustedContentInset.top
            }
        case .horizontal:
            if section.shouldScrollToTopWhenSelectedTab {
                if fromMenu {
                    UIView.animate(withDuration: 0.25) {
                        rootScrollView.contentOffsetX = section.sectionStartPoint.x - rootScrollView.adjustedContentInset.left
                    }
                    return
                }
                if rootScrollView.contentOffset.x > section.sectionStartPoint.x - rootScrollView.adjustedContentInset.left {
                    rootScrollView.contentOffsetX = section.sectionStartPoint.x - rootScrollView.adjustedContentInset.left
                }
            } else if
                (section.currentPageScrollView?.contentOffset.x ?? 0) > 0,
                rootScrollView.contentOffset.x < section.sectionStartPoint.x - rootScrollView.adjustedContentInset.left
            {
                rootScrollView.contentOffsetX = section.sectionStartPoint.x - rootScrollView.adjustedContentInset.left
            }
        default:
            break
        }
    }
    
    /**
     * 当前可滚动的子列表滚动
     * Current scrollable sub list scroll
     */
    func scrollablePageScrollViewDidScroll(_ scrollView: QuickSegmentScrollViewType, from lastOffset: CGPoint) {
        assertionFailure("必须在子类中重写此方法")
    }
    
    /**
     * 非当前可滚动的子列表滚动
     * Non-current scrollable sub list scroll
     */
    func unScrollablePageScrollViewDidScroll(_ scrollView: QuickSegmentScrollViewType, from lastOffset: CGPoint) {
        /**
         * 当前子列表不允许滚动
         * The current sub list is not allowed to scroll
         */
        switch rootDirection {
        case .vertical:
            scrollView.contentOffsetY = lastOffset.y
        case .horizontal:
            scrollView.contentOffsetX = lastOffset.x
        @unknown default:
            break
        }
    }
    
    /**
     * 子列表容器滚动
     * Sub list container scroll
     */
    func pagesBoxScrollViewDidScroll(_ scrollView: QuickSegmentPagesListView, at section: QuickSegmentSection, from lastOffset: CGPoint) {
        assertionFailure("必须在子类中重写此方法")
    }
    
    /**
     * 当前滚动的页面是否是最后一个可滚动的页面
     * Whether the current scrollable page is the last scrollable page
     */
    func isCurrentPageLast() -> Bool {
        if
            let scrollableSection = self.scrollableSection,
            self.allScrollableSections.last == scrollableSection
        {
            if scrollableSection.pagesItem.pagesScrollDirection != rootDirection {
                return true
            }
            return scrollableSection.currentPageIndex == scrollableSection.pageViewControllers.count - 1
        }
        return false
    }
    
    /**
     * 当前可滚动的页面是否是第一个可滚动的页面
     * Whether the current scrollable page is the first scrollable page
     */
    func isCurrentPageFirst() -> Bool {
        if
            let scrollableSection = self.scrollableSection,
            self.allScrollableSections.first == scrollableSection
        {
            if scrollableSection.pagesItem.pagesScrollDirection != rootDirection {
                return true
            }
            return scrollableSection.currentPageIndex == 0
        }
        return false
    }
}

extension QuickSegmentScrollManager: QuickListCollectionLayoutDelegate {
    public func collectionLayoutDidFinishLayout(_ layout: QuickListCollectionLayout) {
        guard let rootScrollView = self.rootScrollView else { return }
        allScrollableSections = []
        for i in 0 ..< rootScrollView.form.count {
            guard let section = rootScrollView.form[i] as? QuickSegmentSection else { continue }
            allScrollableSections.append(section)
        }
    }
}
