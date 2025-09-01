//
//  QuickSegmentDefaultScrollManager.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/8/29.
//

import Foundation

/// 分段页面滚动管理器
/// 对应的总表的滚动方向为竖直
/// 对应bouncesType为.root
class QuickSegmentVerticalRootScrollManager: QuickSegmentScrollManager {
    /// 重置标志位状态
    override func resetStatus(for rootScrollView: QuickSegmentPageListView) {
        let contentOffsetY = rootScrollView.contentOffset.y + rootScrollView.adjustedContentInset.top
        
        if let scrollableSection = self.scrollableSection {
            if contentOffsetY <= scrollableSection.sectionStartPoint.y || contentOffsetY + rootScrollView.bounds.height - rootScrollView.adjustedContentInset.bottom >= scrollableSection.sectionEndPoint.y {
                canRootScroll = true
                canPageScroll = false
            } else {
                canRootScroll = false
                canPageScroll = true
            }
            return
        }
        
        guard let firstSection = visibleSections.first, let lastSection = visibleSections.last else {
            canRootScroll = true
            canPageScroll = false
            return
        }
        if contentOffsetY <= firstSection.sectionStartPoint.y || contentOffsetY + rootScrollView.bounds.height - rootScrollView.adjustedContentInset.bottom >= lastSection.sectionEndPoint.y {
            canRootScroll = true
            canPageScroll = false
        } else {
            canRootScroll = false
            canPageScroll = true
        }
    }
    
    /// 查找目标滚动Section
    override func findScrollableView(to rootView: QuickSegmentPageListView, from lastOffset: CGPoint) {
        let contentOffsetY = rootView.contentOffset.y + rootView.adjustedContentInset.top
        
        let visibleRect = CGRect(
            x: rootView.contentOffset.x + rootView.adjustedContentInset.left,
            y: rootView.contentOffset.y + rootView.adjustedContentInset.top,
            width: rootView.bounds.width - rootView.adjustedContentInset.left - rootView.adjustedContentInset.right,
            height: rootView.bounds.height - rootView.adjustedContentInset.top - rootView.adjustedContentInset.bottom
        )
        
        visibleSections = []
        for i in 0 ..< rootView.handler.layout.sectionAttributes.count {
            guard let attr = rootView.handler.layout.sectionAttributes[i] else { continue }
            let sectionRect = CGRect(
                x: attr.startPoint.x,
                y: attr.startPoint.y,
                width: rootView.bounds.width,
                height: attr.endPoint.y - attr.startPoint.y
            )
            if
                visibleRect.intersects(sectionRect),
                let section = rootView.form[i] as? QuickSegmentSection
            {
                visibleSections.append(section)
            }
        }
        if
            let touchSection = touchSection,
            let sectionScrollView = touchSection.currentPageScrollView
        {
            if
                lastOffset.y < rootView.contentOffset.y,
                sectionScrollView.contentOffset.y >= (sectionScrollView.contentSize.height - sectionScrollView.bounds.height - sectionScrollView.adjustedContentInset.top - sectionScrollView.adjustedContentInset.bottom)
            {
                /// 上拉，且当前触摸的section已经滚动到底部，就需要切换到下一个section
                let currentIndex = allScrollableSections.firstIndex(of: touchSection) ?? 0
                if currentIndex + 1 < allScrollableSections.count {
                    let targetSection = allScrollableSections[currentIndex + 1]
                    /// 如果下一个section没有可滚动的子列表，或者还没有完全展示出来，就不切换
                    if
                        targetSection.currentPageScrollView != nil,
                        targetSection.sectionEndPoint.y <= contentOffsetY + rootView.bounds.height - rootView.adjustedContentInset.bottom
                    {
                        self.scrollableSection = targetSection
                    } else {
                        self.scrollableSection = touchSection
                    }
                } else {
                    self.scrollableSection = touchSection
                }
            } else if
                lastOffset.y > rootView.contentOffset.y,
                sectionScrollView.contentOffset.y <= 0
            {
                /// 下拉，且当前触摸的section已经滚动到顶部，就需要切换到上一个section
                let currentIndex = allScrollableSections.firstIndex(of: touchSection) ?? 0
                if currentIndex - 1 >= 0 {
                    let targetSection = allScrollableSections[currentIndex - 1]
                    /// 如果上一个section没有可滚动的子列表，或者还没有完全展示出来，就不切换
                    if
                        targetSection.currentPageScrollView != nil,
                        targetSection.sectionStartPoint.y >= contentOffsetY
                    {
                        self.scrollableSection = targetSection
                    } else {
                        self.scrollableSection = touchSection
                    }
                } else {
                    self.scrollableSection = touchSection
                }
            } else {
                self.scrollableSection = touchSection
            }
        } else {
            self.scrollableSection = touchSection
        }
        
        if scrollableSection?.currentPageScrollView == nil {
            self.scrollableSection = nil
        }
    }
    
    /// 处理总列表视图滚动
    override func rootScrollViewDidScroll(_ scrollView: QuickSegmentPageScrollViewType, from lastOffset: CGPoint) {
        guard scrollView.scrollDirection == currentScrollDirection else {
            scrollView.contentOffset = lastOffset
            return
        }
        guard let rootScrollView = self.rootScrollView else { return }
        let contentOffsetY = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
        let oldContentOffsetY = lastOffset.y + scrollView.adjustedContentInset.top
        
        findScrollableView(to: rootScrollView, from: lastOffset)
        if scrollableSection == nil {
            self.canRootScroll = true
            self.canPageScroll = false
        }
        if !canRootScroll {
            if
                lastOffset.y < scrollView.contentOffset.y,
                let section = scrollableSection,
                contentOffsetY >= section.sectionStartPoint.y,
                let sectionScrollView = section.currentPageScrollView,
                sectionScrollView.contentOffset.y < (sectionScrollView.contentSize.height - sectionScrollView.bounds.height - sectionScrollView.adjustedContentInset.top - sectionScrollView.adjustedContentInset.bottom)
            {
                /// 上拉，目标值大于等于pageStartOffset，且当前可滚动的section还没滚动到底时，不能再滚动了
                scrollView.contentOffset.y = section.sectionStartPoint.y - scrollView.adjustedContentInset.top
            } else if
                lastOffset.y > scrollView.contentOffset.y,
                let section = scrollableSection,
                oldContentOffsetY <= section.sectionEndPoint.y - scrollView.bounds.height + scrollView.adjustedContentInset.bottom + scrollView.adjustedContentInset.top,
                let sectionScrollView = section.currentPageScrollView,
                sectionScrollView.contentOffset.y > 0
            {
                /// 下拉，原值小于等于pageEndOffset时，且当前可滚动的section还没滚动到顶部时，不能再滚动了
                let targetOffsetY = section.sectionEndPoint.y - scrollView.bounds.height + scrollView.adjustedContentInset.bottom + scrollView.adjustedContentInset.top
                scrollView.contentOffset.y = targetOffsetY
            } else {
                scrollView.contentOffset.y = lastOffset.y
            }
        } else if
            lastOffset.y < scrollView.contentOffset.y,
            let section = scrollableSection,
            contentOffsetY >= section.sectionEndPoint.y - scrollView.bounds.height + scrollView.adjustedContentInset.bottom + scrollView.adjustedContentInset.top,
            let sectionScrollView = section.currentPageScrollView,
            sectionScrollView.contentOffset.y < (sectionScrollView.contentSize.height - sectionScrollView.bounds.height - sectionScrollView.adjustedContentInset.top - sectionScrollView.adjustedContentInset.bottom)
        {
            /// 上拉，目标section已完全展示，且当前可滚动的section还没滚动到底时，不能再滚动了
            let targetOffsetY = section.sectionStartPoint.y - scrollView.adjustedContentInset.top
            canRootScroll = false
            canPageScroll = true
            scrollView.contentOffset.y = targetOffsetY
        } else if
            lastOffset.y > scrollView.contentOffset.y,
            let section = scrollableSection,
            let sectionScrollView = section.currentPageScrollView,
            contentOffsetY <= section.sectionStartPoint.y,
            sectionScrollView.contentOffset.y > 0
        {
            /// 下拉，目标section已完全展示，且当前可滚动的section还没滚动到顶部时，不能再滚动了
            let targetOffsetY = section.sectionEndPoint.y - scrollView.bounds.height + scrollView.adjustedContentInset.bottom + scrollView.adjustedContentInset.top
            canRootScroll = false
            canPageScroll = true
            scrollView.contentOffset.y = targetOffsetY
        }
    }
    
    /// 处理子列表滚动
    override func scrollablePageScrollViewDidScroll(_ scrollView: QuickSegmentPageScrollViewType, from lastOffset: CGPoint) {
        guard scrollView.scrollDirection == currentScrollDirection else {
            scrollView.contentOffset = lastOffset
            return
        }
        guard let rootScrollView = self.rootScrollView else {
            return
        }
        let rootContentOffsetY = rootScrollView.contentOffset.y + rootScrollView.adjustedContentInset.top
        
        let targetOffset = scrollView.contentOffset
        if !canPageScroll {
            if targetOffset.y <= 0 {
                scrollView.contentOffset.y = 0
            } else if targetOffset.y >= (scrollView.contentSize.height - scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom) {
                scrollView.contentOffset.y = scrollView.contentSize.height - scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom
            } else if
                lastOffset.y == 0,
                targetOffset.y > 0
            {
                if
                    let currentSection = self.scrollableSection,
                    rootContentOffsetY >= currentSection.sectionStartPoint.y
                {
                    canRootScroll = false
                } else {
                    scrollView.contentOffset.y = 0
                }
            } else if
                lastOffset.y == (scrollView.contentSize.height - scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom),
                targetOffset.y < lastOffset.y
            {
                if
                    let currentSection = self.scrollableSection,
                    rootContentOffsetY <= currentSection.sectionStartPoint.y
                {
                    canRootScroll = false
                    canPageScroll = true
                } else {
                    scrollView.contentOffset.y = lastOffset.y
                }
            }
            return
        }
        if targetOffset.y <= 0, lastOffset.y > targetOffset.y {
            /// 下拉，目标值小于0时，不能再滚动了
            scrollView.contentOffset.y = 0
            canRootScroll = true
            canPageScroll = false
            return
        }
        if
            targetOffset.y >= (scrollView.contentSize.height - scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom),
            lastOffset.y < targetOffset.y
        {
            /// 上拉，到底时，不能再滚动
            scrollView.contentOffset.y = scrollView.contentSize.height - scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom
            canRootScroll = true
            canPageScroll = false
            return
        }
    }
}

