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
        
        if let section = self.scrollableSection {
            if contentOffsetY <= section.sectionStartPoint.y || contentOffsetY + rootScrollView.bounds.height - rootScrollView.adjustedContentInset.bottom >= section.sectionEndPoint.y {
                canRootScroll = true
                canPagesBoxScroll = false
                canPageScroll = false
            } else {
                /// 判断pages容器的滚动方向
                switch section.pagesItem.pagesScrollDirection {
                case .vertical:
                    guard let currentPage = section.currentPageScrollView else {
                        canRootScroll = false
                        canPagesBoxScroll = true
                        canPageScroll = false
                        return
                    }
                    switch currentPage.scrollDirection {
                    case .vertical:
                        canRootScroll = false
                        canPagesBoxScroll = false
                        canPageScroll = true
                    default:
                        canRootScroll = false
                        canPagesBoxScroll = true
                        canPageScroll = false
                    }
                default:
                    canRootScroll = false
                    canPagesBoxScroll = false
                    canPageScroll = true
                }
            }
            return
        }
        
        guard let firstSection = visibleSections.first, let lastSection = visibleSections.last else {
            canRootScroll = true
            canPagesBoxScroll = false
            canPageScroll = false
            return
        }
        if contentOffsetY <= firstSection.sectionStartPoint.y || contentOffsetY + rootScrollView.bounds.height - rootScrollView.adjustedContentInset.bottom >= lastSection.sectionEndPoint.y {
            canRootScroll = true
            canPagesBoxScroll = false
            canPageScroll = false
        } else {
            canRootScroll = false
            canPagesBoxScroll = false
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
            let pagesBox = touchSection.pagesItem.currentListView
        {
            let findLastSection: () -> QuickSegmentSection? = {
                let currentIndex = self.allScrollableSections.firstIndex(of: touchSection) ?? 0
                if currentIndex - 1 >= 0 {
                    let targetSection = self.allScrollableSections[currentIndex - 1]
                    /// 如果上一个section没有可滚动的子列表，或者还没有完全展示出来，或者已经滚动到顶了，就不切换
                    if
                        targetSection.sectionStartPoint.y >= contentOffsetY,
                        targetSection.currentPageScrollView != nil,
                        let targetPagesBox = targetSection.pagesItem.currentListView,
                        targetPagesBox.contentOffset.y <= 0
                    {
                        return targetSection
                    }
                }
                return nil
            }
            
            let findNextSection: () -> QuickSegmentSection? = {
                let currentIndex = self.allScrollableSections.firstIndex(of: touchSection) ?? 0
                if currentIndex + 1 < self.allScrollableSections.count {
                    let targetSection = self.allScrollableSections[currentIndex + 1]
                    /// 如果下一个section没有可滚动的子列表，或者还没有完全展示出来，或者已经滚动到底了，就不切换
                    if
                        targetSection.sectionEndPoint.y <= contentOffsetY + rootView.bounds.height - rootView.adjustedContentInset.bottom,
                        targetSection.currentPageScrollView != nil,
                        let targetPagesBox = targetSection.pagesItem.currentListView,
                        targetPagesBox.contentOffset.y >= (targetPagesBox.contentSize.height - targetPagesBox.bounds.height - targetPagesBox.adjustedContentInset.top - targetPagesBox.adjustedContentInset.bottom)
                    {
                        return targetSection
                    }
                }
                return nil
            }
            
            if let sectionScrollView = touchSection.currentPageScrollView {
                if
                    lastOffset.y < rootView.contentOffset.y,
                    sectionScrollView.contentOffset.y >= (sectionScrollView.contentSize.height - sectionScrollView.bounds.height - sectionScrollView.adjustedContentInset.top - sectionScrollView.adjustedContentInset.bottom),
                    pagesBox.contentOffset.y >= (pagesBox.contentSize.height - pagesBox.bounds.height - pagesBox.adjustedContentInset.top - pagesBox.adjustedContentInset.bottom)
                {
                    /// 上拉，且当前触摸的section已经滚动到底部，就需要切换到下一个section
                    if let nextSection = findNextSection() {
                        self.scrollableSection = nextSection
                    } else {
                        self.scrollableSection = touchSection
                    }
                } else if
                    lastOffset.y > rootView.contentOffset.y,
                    sectionScrollView.contentOffset.y <= 0,
                    pagesBox.contentOffset.y <= 0
                {
                    /// 下拉，且当前触摸的section已经滚动到顶部，就需要切换到上一个section
                    if let lastSection = findLastSection() {
                        self.scrollableSection = lastSection
                    } else {
                        self.scrollableSection = touchSection
                    }
                } else {
                    self.scrollableSection = touchSection
                }
            } else if
                lastOffset.y < rootView.contentOffset.y,
                pagesBox.contentOffset.y >= (pagesBox.contentSize.height - pagesBox.bounds.height - pagesBox.adjustedContentInset.top - pagesBox.adjustedContentInset.bottom)
            {
                /// 上拉，且当前触摸的section已经滚动到底部，就需要切换到下一个section
                if let nextSection = findNextSection() {
                    self.scrollableSection = nextSection
                } else {
                    self.scrollableSection = touchSection
                }
            } else if
                lastOffset.y > rootView.contentOffset.y,
                pagesBox.contentOffset.y <= 0
            {
                /// 下拉，且当前触摸的section已经滚动到顶部，就需要切换到上一个section
                if let lastSection = findLastSection() {
                    self.scrollableSection = lastSection
                } else {
                    self.scrollableSection = touchSection
                }
            } else {
                self.scrollableSection = touchSection
            }
        } else {
            self.scrollableSection = nil
        }
    }
    
    /// 处理总列表视图滚动
    override func rootScrollViewDidScroll(_ scrollView: QuickSegmentPageScrollViewType, from lastOffset: CGPoint) {
        guard scrollView.scrollDirection == currentScrollDirection else {
            scrollView.contentOffset = lastOffset
            if !canPageScroll && !canPagesBoxScroll {
                if let scrollableSection = scrollableSection {
                    if scrollableSection.pagesItem.pagesScrollDirection == currentScrollDirection {
                        self.canRootScroll = false
                        self.canPagesBoxScroll = true
                        self.canPageScroll = false
                    } else if
                        let sectionScrollView = scrollableSection.currentPageScrollView,
                        sectionScrollView.scrollDirection == currentScrollDirection
                    {
                        self.canRootScroll = false
                        self.canPagesBoxScroll = false
                        self.canPageScroll = true
                    }
                }
            }
            return
        }
        guard let rootScrollView = self.rootScrollView else { return }
        let contentOffsetY = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
        
        findScrollableView(to: rootScrollView, from: lastOffset)
        if scrollableSection == nil {
            self.canRootScroll = true
            self.canPageScroll = false
        }
        if !canRootScroll {
            guard let section = scrollableSection else {
                scrollView.contentOffset.y = lastOffset.y
                return
            }
            let handleScrollPage = { (sectionScrollView: QuickSegmentPageScrollViewType) in
                if
                    lastOffset.y < scrollView.contentOffset.y,
                    contentOffsetY >= section.sectionStartPoint.y,
                    sectionScrollView.contentOffset.y < (sectionScrollView.contentSize.height - sectionScrollView.bounds.height - sectionScrollView.adjustedContentInset.top - sectionScrollView.adjustedContentInset.bottom)
                {
                    /// 上拉，目标section已完全展示，且当前可滚动的section还没滚动到底时，不能再滚动了
                    scrollView.contentOffset.y = section.sectionStartPoint.y - scrollView.adjustedContentInset.top
                    return true
                }
                if
                    lastOffset.y > scrollView.contentOffset.y,
                    contentOffsetY <= section.sectionStartPoint.y,
                    sectionScrollView.contentOffset.y > 0
                {
                    /// 下拉，目标section已完全展示，且当前可滚动的section还没滚动到顶部时，不能再滚动了
                    let targetOffsetY = section.sectionStartPoint.y - scrollView.adjustedContentInset.top
                    scrollView.contentOffset.y = targetOffsetY
                    return true
                }
                return false
            }
            
            let handleScrollPagesBox = { (pagesBox: QuickSegmentPageListView) in
                if
                    lastOffset.y < scrollView.contentOffset.y,
                    contentOffsetY >= section.sectionStartPoint.y,
                    pagesBox.contentOffset.y < (pagesBox.contentSize.height - pagesBox.bounds.height - pagesBox.adjustedContentInset.top - pagesBox.adjustedContentInset.bottom)
                {
                    /// 上拉，目标section已完全展示，且当前可滚动的section还没滚动到底时，不能再滚动了
                    let targetY = section.sectionStartPoint.y - scrollView.adjustedContentInset.top
                    self.canPagesBoxScroll = true
                    self.canPageScroll = false
                    scrollView.contentOffset.y = targetY
                    return true
                }
                if
                    lastOffset.y > scrollView.contentOffset.y,
                    contentOffsetY <= section.sectionStartPoint.y,
                    pagesBox.contentOffset.y > 0
                {
                    /// 下拉，目标section已完全展示，且当前可滚动的section还没滚动到顶部时，不能再滚动了
                    let targetOffsetY = section.sectionStartPoint.y - scrollView.adjustedContentInset.top
                    self.canPagesBoxScroll = true
                    self.canPageScroll = false
                    scrollView.contentOffset.y = targetOffsetY
                    return true
                }
                return false
            }
            
            /// 判断pages容器的滚动方向
            switch section.pagesItem.pagesScrollDirection {
            case .vertical:
                guard let sectionScrollView = section.currentPageScrollView else {
                    guard let pagesBox = section.pagesItem.currentListView else {
                        scrollView.contentOffset.y = lastOffset.y
                        return
                    }
                    if !handleScrollPagesBox(pagesBox) {
                        scrollView.contentOffset.y = lastOffset.y
                    }
                    return
                }
                switch sectionScrollView.scrollDirection {
                case .vertical:
                    /// 容器是竖直滚动，且当前page是竖直滚动，则需要处理
                    if !handleScrollPage(sectionScrollView) {
                        guard let pagesBox = section.pagesItem.currentListView else {
                            scrollView.contentOffset.x = lastOffset.x
                            return
                        }
                        if !handleScrollPagesBox(pagesBox) {
                            scrollView.contentOffset.x = lastOffset.x
                        }
                    }
                    return
                case .horizontal:
                    guard let pagesBox = section.pagesItem.currentListView else {
                        scrollView.contentOffset.y = lastOffset.y
                        return
                    }
                    /// pages容器是竖直滚动，且当前page是水平滚动，则需要处理，让它可以滚动到上/下一个page
                    if !handleScrollPagesBox(pagesBox) {
                        scrollView.contentOffset.y = lastOffset.y
                    }
                    return
                @unknown default:
                    scrollView.contentOffset.x = lastOffset.x
                    return
                }
            case .horizontal:
                guard
                    let sectionScrollView = section.currentPageScrollView,
                    sectionScrollView.scrollDirection == .vertical
                else {
                    scrollView.contentOffset.y = lastOffset.y
                    return
                }
                /// pages容器是竖直滚动，且当前page是水平滚动，则需要处理
                if !handleScrollPage(sectionScrollView) {
                    scrollView.contentOffset.y = lastOffset.y
                }
                return
            default:
                scrollView.contentOffset.y = lastOffset.y
                return
            }
        }
        
        guard let section = scrollableSection else {
            return
        }
        let handleScrollPage = { (sectionScrollView: QuickSegmentPageScrollViewType) in
            if
                lastOffset.y < scrollView.contentOffset.y,
                contentOffsetY >= section.sectionStartPoint.y,
                sectionScrollView.contentOffset.y < (sectionScrollView.contentSize.height - sectionScrollView.bounds.height - sectionScrollView.adjustedContentInset.top - sectionScrollView.adjustedContentInset.bottom)
            {
                /// 上拉，目标section已完全展示，且当前可滚动的section还没滚动到底时，不能再滚动了
                let targetOffsetY = section.sectionStartPoint.y - scrollView.adjustedContentInset.top
                self.canRootScroll = false
                self.canPageScroll = false
                self.canPageScroll = true
                scrollView.contentOffset.y = targetOffsetY
                return true
            } else if
                lastOffset.y > scrollView.contentOffset.y,
                contentOffsetY <= section.sectionStartPoint.y,
                sectionScrollView.contentOffset.y > 0
            {
                /// 下拉，目标section已完全展示，且当前可滚动的section还没滚动到顶部时，不能再滚动了
                let targetOffsetY = section.sectionStartPoint.y - scrollView.adjustedContentInset.top
                self.canRootScroll = false
                self.canPagesBoxScroll = false
                self.canPageScroll = true
                scrollView.contentOffset.y = targetOffsetY
                return true
            }
            return false
        }
        
        let handleScrollPagesBox = { (pagesBox: QuickSegmentPageListView) in
            if
                lastOffset.y < scrollView.contentOffset.y,
                contentOffsetY >= section.sectionStartPoint.y,
                pagesBox.contentOffset.y < (pagesBox.contentSize.height - pagesBox.bounds.height - pagesBox.adjustedContentInset.top - pagesBox.adjustedContentInset.bottom)
            {
                /// 上拉，目标section已完全展示，且当前可滚动的section还没滚动到底时，不能再滚动了
                let targetY = section.sectionStartPoint.y - scrollView.adjustedContentInset.top
                self.canRootScroll = false
                self.canPagesBoxScroll = true
                self.canPageScroll = false
                scrollView.contentOffset.y = targetY
                return
            }
            if
                lastOffset.y > scrollView.contentOffset.y,
                contentOffsetY <= section.sectionStartPoint.y,
                pagesBox.contentOffset.y > 0
            {
                /// 下拉，目标section已完全展示，且当前可滚动的section还没滚动到顶部时，不能再滚动了
                let targetOffsetY = section.sectionStartPoint.y - scrollView.adjustedContentInset.top
                self.canRootScroll = false
                self.canPagesBoxScroll = true
                self.canPageScroll = false
                scrollView.contentOffset.y = targetOffsetY
            }
        }
        
        /// 判断pages容器的滚动方向
        switch section.pagesItem.pagesScrollDirection {
        case .vertical:
            guard let sectionScrollView = section.currentPageScrollView else {
                guard let pagesBox = section.pagesItem.currentListView else {
                    return
                }
                handleScrollPagesBox(pagesBox)
                return
            }
            guard let pagesBox = section.pagesItem.currentListView else {
                return
            }
            switch sectionScrollView.scrollDirection {
            case .vertical:
                /// pages容器是竖直滚动，且当前page是竖直滚动，则需要处理
                if !handleScrollPage(sectionScrollView) {
                    handleScrollPagesBox(pagesBox)
                }
                return
            case .horizontal:
                /// 容器是竖直滚动，且当前page是水平滚动，则需要处理，让它可以滚动到上/下一个page
                handleScrollPagesBox(pagesBox)
                return
            @unknown default:
                return
            }
        case .horizontal:
            guard
                let sectionScrollView = section.currentPageScrollView,
                sectionScrollView.scrollDirection == .vertical
            else {
                return
            }
            /// pages容器是水平滚动，且当前page是竖直滚动，则需要处理
            _ = handleScrollPage(sectionScrollView)
            return
        default:
            return
        }
    }
    
    /// 处理子列表的容器的滚动
    override func pagesBoxScrollViewDidScroll(_ scrollView: QuickSegmentPageListView, at section: QuickSegmentSection, from lastOffset: CGPoint) {
        switch scrollView.scrollDirection {
        case .horizontal:
            if !canPagesBoxScroll || scrollView.scrollDirection != currentScrollDirection {
                scrollView.contentOffset.x = CGFloat(section.currentPageIndex) * (scrollView.bounds.width - scrollView.adjustedContentInset.left - scrollView.adjustedContentInset.right)
                return
            }
            if self.rootScrollView?.scrollDirection != currentScrollDirection {
                if let pageScrollView = section.currentPageScrollView, pageScrollView.scrollDirection == .horizontal {
                    if
                        scrollView.contentOffset.x > lastOffset.x,
                        pageScrollView.contentOffset.x < (pageScrollView.contentSize.width - pageScrollView.bounds.width + pageScrollView.adjustedContentInset.right)
                    {
                        canPagesBoxScroll = false
                        canPageScroll = true
                        /// 当前子列表可以滚动
                        scrollView.contentOffset.x = CGFloat(section.currentPageIndex) * (scrollView.bounds.width - scrollView.adjustedContentInset.left - scrollView.adjustedContentInset.right)
                        return
                    }
                    if
                        scrollView.contentOffset.x < lastOffset.x,
                        pageScrollView.contentOffset.x > 0
                    {
                        canPagesBoxScroll = false
                        canPageScroll = true
                        /// 当前子列表可以滚动
                        scrollView.contentOffset.x = CGFloat(section.currentPageIndex) * (scrollView.bounds.width - scrollView.adjustedContentInset.left - scrollView.adjustedContentInset.right)
                        return
                    }
                }
            } else {
                if scrollView.contentOffset.x < 0 {
                    canPagesBoxScroll = false
                    canRootScroll = true
                    scrollView.contentOffset.x = 0
                    return
                }
                if scrollView.contentOffset.x > (scrollView.contentSize.width - scrollView.bounds.width + scrollView.adjustedContentInset.right) {
                    canPagesBoxScroll = false
                    canRootScroll = true
                    scrollView.contentOffset.x = scrollView.contentSize.width - scrollView.bounds.width + scrollView.adjustedContentInset.right
                    return
                }
            }
        case .vertical:
            if !canPagesBoxScroll || scrollView.scrollDirection != currentScrollDirection {
                scrollView.contentOffset.y = CGFloat(section.currentPageIndex) * (scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom)
                return
            }
            if self.rootScrollView?.scrollDirection != currentScrollDirection {
                if let pageScrollView = section.currentPageScrollView, pageScrollView.scrollDirection == .vertical {
                    if
                        scrollView.contentOffset.y > lastOffset.y,
                        pageScrollView.contentOffset.y < (pageScrollView.contentSize.height - pageScrollView.bounds.height + pageScrollView.adjustedContentInset.bottom)
                    {
                        canPagesBoxScroll = false
                        canPageScroll = true
                        /// 当前子列表可以滚动
                        scrollView.contentOffset.y = CGFloat(section.currentPageIndex) * (scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom)
                        return
                    }
                    if
                        scrollView.contentOffset.y < lastOffset.y,
                        pageScrollView.contentOffset.y > 0
                    {
                        canPagesBoxScroll = false
                        canPageScroll = true
                        /// 当前子列表可以滚动
                        scrollView.contentOffset.y = CGFloat(section.currentPageIndex) * (scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom)
                        return
                    }
                }
            } else {
                if scrollView.contentOffset.y < 0 {
                    canPagesBoxScroll = false
                    canRootScroll = true
                    scrollView.contentOffset.y = 0
                    return
                }
                if scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.bounds.height + scrollView.adjustedContentInset.bottom) {
                    canPagesBoxScroll = false
                    canRootScroll = true
                    scrollView.contentOffset.y = scrollView.contentSize.height - scrollView.bounds.height + scrollView.adjustedContentInset.bottom
                    return
                }
            }
        @unknown default:
            return
        }
    }
    
    /// 处理子列表滚动
    override func scrollablePageScrollViewDidScroll(_ scrollView: QuickSegmentPageScrollViewType, from lastOffset: CGPoint) {
        guard scrollView.scrollDirection == currentScrollDirection else {
            /// 处于中间位置时，禁止滚动，超出去的部分允许bounds动画完成
            switch scrollView.scrollDirection {
            case .horizontal:
                if lastOffset.x < 0 || scrollView.contentOffset.x < 0 {
                    scrollView.contentOffset.x = 0
                } else {
                    let maxX = scrollView.contentSize.width - scrollView.bounds.width - scrollView.adjustedContentInset.left - scrollView.adjustedContentInset.right
                    if
                        lastOffset.x > maxX || scrollView.contentOffset.x > maxX
                    {
                        scrollView.contentOffset.x = maxX
                    } else {
                        scrollView.contentOffset.x = lastOffset.x
                    }
                }
            case .vertical:
                if lastOffset.y < 0 || scrollView.contentOffset.y < 0 {
                    scrollView.contentOffset.y = 0
                } else {
                    let maxY = scrollView.contentSize.height - scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom
                    if lastOffset.y > maxY || scrollView.contentOffset.y > maxY {
                        scrollView.contentOffset.y = maxY
                    } else {
                        scrollView.contentOffset.y = lastOffset.y
                    }
                }
            @unknown default:
                return
            }
            return
        }
        switch scrollView.scrollDirection {
        case .horizontal:
            horizontalPageScrollViewDidScroll(scrollView, from: lastOffset)
        case .vertical:
            verticalPageScrollViewDidScroll(scrollView, from: lastOffset)
        default:
            return
        }
    }
    
    func horizontalPageScrollViewDidScroll(_ scrollView: QuickSegmentPageScrollViewType, from lastOffset: CGPoint) {
        guard let rootScrollView = self.rootScrollView else {
            return
        }
        let rootContentOffsetY = rootScrollView.contentOffset.y + rootScrollView.adjustedContentInset.top
        
        let targetOffset = scrollView.contentOffset
        if !canPageScroll {
            if targetOffset.x <= 0 {
                scrollView.contentOffset.x = 0
                if
                    let currentSection = self.scrollableSection,
                    currentSection.pagesItem.currentListView?.scrollDirection == .horizontal
                {
                    canPagesBoxScroll = true
                }
            } else if targetOffset.x >= (scrollView.contentSize.width - scrollView.bounds.width - scrollView.adjustedContentInset.left - scrollView.adjustedContentInset.right) {
                scrollView.contentOffset.x = scrollView.contentSize.width - scrollView.bounds.width - scrollView.adjustedContentInset.left - scrollView.adjustedContentInset.right
                if
                    let currentSection = self.scrollableSection,
                    currentSection.pagesItem.currentListView?.scrollDirection == .horizontal
                {
                    canPagesBoxScroll = true
                }
            } else if
                lastOffset.x == 0,
                targetOffset.x > 0
            {
                if
                    let currentSection = self.scrollableSection,
                    rootContentOffsetY >= currentSection.sectionStartPoint.y
                {
                    canPagesBoxScroll = false
                    canPageScroll = true
                } else {
                    scrollView.contentOffset.x = 0
                }
            } else if
                lastOffset.x == (scrollView.contentSize.width - scrollView.bounds.width - scrollView.adjustedContentInset.left - scrollView.adjustedContentInset.right),
                targetOffset.x < lastOffset.x
            {
                if
                    let currentSection = self.scrollableSection,
                    rootContentOffsetY <= currentSection.sectionStartPoint.y
                {
                    canPagesBoxScroll = false
                    canPageScroll = true
                } else {
                    scrollView.contentOffset.x = lastOffset.x
                }
            }
            return
        }
        if targetOffset.x <= 0, lastOffset.x > targetOffset.x {
            /// 下拉，目标值小于0时，不能再滚动了
            scrollView.contentOffset.x = 0
            canPagesBoxScroll = true
            canPageScroll = false
            return
        }
        if
            targetOffset.x >= (scrollView.contentSize.width - scrollView.bounds.width - scrollView.adjustedContentInset.left - scrollView.adjustedContentInset.right),
            lastOffset.x < targetOffset.x
        {
            /// 上拉，到底时，不能再滚动
            scrollView.contentOffset.x = scrollView.contentSize.width - scrollView.bounds.width - scrollView.adjustedContentInset.left - scrollView.adjustedContentInset.right
            canPagesBoxScroll = true
            canPageScroll = false
            return
        }
    }
    
    func verticalPageScrollViewDidScroll(_ scrollView: QuickSegmentPageScrollViewType, from lastOffset: CGPoint) {
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
            /// 右滑，目标值小于0时，不能再滚动了
            scrollView.contentOffset.y = 0
            canRootScroll = true
            canPageScroll = false
            return
        }
        if
            targetOffset.y >= (scrollView.contentSize.height - scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom),
            lastOffset.y < targetOffset.y
        {
            /// 左滑，到底时，不能再滚动
            scrollView.contentOffset.y = scrollView.contentSize.height - scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom
            canRootScroll = true
            canPageScroll = false
            return
        }
    }
}

