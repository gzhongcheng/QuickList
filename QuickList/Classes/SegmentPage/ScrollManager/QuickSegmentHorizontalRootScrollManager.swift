//
//  QuickSegmentHorizontalRootScrollManager.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/8/29.
//

import Foundation

/// 分段页面滚动管理器
/// 对应的总表的滚动方向为竖直
/// 对应bouncesType为.root
class QuickSegmentHorizontalRootScrollManager: QuickSegmentScrollManager {
    /// 重置标志位状态
    override func resetStatus(for rootScrollView: QuickSegmentRootListView) {
        let contentOffsetX = rootScrollView.contentOffset.x + rootScrollView.adjustedContentInset.left
        
        if let section = self.scrollableSection {
            if contentOffsetX <= section.sectionStartPoint.x || contentOffsetX + rootScrollView.bounds.width - rootScrollView.adjustedContentInset.right >= section.sectionEndPoint.x {
                canRootScroll = true
                canPagesBoxScroll = false
                canPageScroll = false
            } else {
                /// 判断pages容器的滚动方向
                switch section.pagesItem.pagesScrollDirection {
                case .horizontal:
                    guard let currentPage = section.currentPageScrollView else {
                        canRootScroll = false
                        canPagesBoxScroll = true
                        canPageScroll = false
                        return
                    }
                    switch currentPage.scrollDirection {
                    case .horizontal:
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
        if contentOffsetX <= firstSection.sectionStartPoint.x || contentOffsetX + rootScrollView.bounds.width - rootScrollView.adjustedContentInset.right >= lastSection.sectionEndPoint.x {
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
    override func findScrollableView(to rootView: QuickSegmentRootListView, from lastOffset: CGPoint) {
        let contentOffsetX = rootView.contentOffset.x + rootView.adjustedContentInset.left
        
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
                        targetSection.sectionStartPoint.x >= contentOffsetX,
                        let targetPage = targetSection.currentPageScrollView,
                        let targetPagesBox = targetSection.pagesItem.currentListView,
                        targetPagesBox.contentOffset.x > 0 || targetPage.contentOffset.x > 0
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
                        targetSection.sectionEndPoint.x <= contentOffsetX + rootView.bounds.width - rootView.adjustedContentInset.right,
                        let targetPage = targetSection.currentPageScrollView,
                        let targetPagesBox = targetSection.pagesItem.currentListView,
                        targetPagesBox.contentOffset.x < (targetPagesBox.contentSize.width - targetPagesBox.bounds.width + targetPagesBox.adjustedContentInset.left + targetPagesBox.adjustedContentInset.right) || targetPage.contentOffset.x < (targetPage.contentSize.width - targetPage.bounds.width + targetPage.adjustedContentInset.left + targetPage.adjustedContentInset.right)
                    {
                        return targetSection
                    }
                }
                return nil
            }
            
            if let sectionScrollView = touchSection.currentPageScrollView {
                if
                    lastOffset.x < rootView.contentOffset.x,
                    sectionScrollView.contentOffset.x >= (sectionScrollView.contentSize.width - sectionScrollView.bounds.width - sectionScrollView.adjustedContentInset.left - sectionScrollView.adjustedContentInset.right),
                    pagesBox.contentOffset.x >= (pagesBox.contentSize.width - pagesBox.bounds.width - pagesBox.adjustedContentInset.left - pagesBox.adjustedContentInset.right)
                {
                    /// 左滑，且当前触摸的section已经滚动到底部，就需要切换到下一个section
                    if let nextSection = findNextSection() {
                        self.scrollableSection = nextSection
                    } else {
                        self.scrollableSection = touchSection
                    }
                } else if
                    lastOffset.x > rootView.contentOffset.x,
                    sectionScrollView.contentOffset.x <= 0,
                    pagesBox.contentOffset.x <= 0
                {
                    /// 右滑，且当前触摸的section已经滚动到顶部，就需要切换到上一个section
                    if let lastSection = findLastSection() {
                        self.scrollableSection = lastSection
                    } else {
                        self.scrollableSection = touchSection
                    }
                } else {
                    self.scrollableSection = touchSection
                }
            } else if
                lastOffset.x < rootView.contentOffset.x,
                pagesBox.contentOffset.x >= (pagesBox.contentSize.width - pagesBox.bounds.width - pagesBox.adjustedContentInset.left - pagesBox.adjustedContentInset.right)
            {
                /// 左滑，且当前触摸的section已经滚动到底部，就需要切换到下一个section
                if let nextSection = findNextSection() {
                    self.scrollableSection = nextSection
                } else {
                    self.scrollableSection = touchSection
                }
            } else if
                lastOffset.x > rootView.contentOffset.x,
                pagesBox.contentOffset.x <= 0
            {
                /// 右滑，且当前触摸的section已经滚动到顶部，就需要切换到上一个section
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
    override func rootScrollViewDidScroll(_ scrollView: QuickSegmentScrollViewType, from lastOffset: CGPoint) {
        guard scrollView.scrollDirection == currentScrollDirection else {
            scrollView.contentOffsetX = lastOffset.x
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
        let contentOffsetX = scrollView.contentOffset.x + scrollView.adjustedContentInset.left
        
        findScrollableView(to: rootScrollView, from: lastOffset)
        if scrollableSection == nil {
            self.canRootScroll = true
            self.canPageScroll = false
        }
        if !canRootScroll {
            guard let section = scrollableSection else {
                scrollView.contentOffsetX = lastOffset.x
                return
            }
            let handleScrollPage = { (sectionScrollView: QuickSegmentScrollViewType) in
                if
                    lastOffset.x < scrollView.contentOffset.x,
                    contentOffsetX >= section.sectionStartPoint.x,
                    sectionScrollView.contentOffset.x < (sectionScrollView.contentSize.width - sectionScrollView.bounds.width - sectionScrollView.adjustedContentInset.left - sectionScrollView.adjustedContentInset.right)
                {
                    /// 左滑，目标section已完全展示，且当前可滚动的section还没滚动到底时，不能再滚动了
                    scrollView.contentOffsetX = section.sectionStartPoint.x - scrollView.adjustedContentInset.left
                    return true
                }
                if
                    lastOffset.x > scrollView.contentOffset.x,
                    contentOffsetX <= section.sectionStartPoint.x,
                    sectionScrollView.contentOffset.x > 0
                {
                    /// 右滑，目标section已完全展示，且当前可滚动的section还没滚动到顶部时，不能再滚动了
                    let targetOffsetX = section.sectionStartPoint.x - scrollView.adjustedContentInset.left
                    scrollView.contentOffsetX = targetOffsetX
                    return true
                }
                return false
            }
            
            let handleScrollPagesBox = { (pagesBox: QuickSegmentPagesListView) in
                if
                    lastOffset.x < scrollView.contentOffset.x,
                    contentOffsetX >= section.sectionStartPoint.x,
                    pagesBox.contentOffset.x < (pagesBox.contentSize.width - pagesBox.bounds.width - pagesBox.adjustedContentInset.left - pagesBox.adjustedContentInset.right)
                {
                    /// 左滑，目标section已完全展示，且当前可滚动的section还没滚动到底时，不能再滚动了
                    let targetX = section.sectionStartPoint.x - scrollView.adjustedContentInset.left
                    self.canPagesBoxScroll = true
                    self.canPageScroll = false
                    scrollView.contentOffsetX = targetX
                    return true
                }
                if
                    lastOffset.x > scrollView.contentOffset.x,
                    contentOffsetX <= section.sectionStartPoint.x,
                    pagesBox.contentOffset.x > 0
                {
                    /// 右滑，目标section已完全展示，且当前可滚动的section还没滚动到顶部时，不能再滚动了
                    let targetOffsetX = section.sectionStartPoint.x - scrollView.adjustedContentInset.left
                    self.canPagesBoxScroll = true
                    self.canPageScroll = false
                    scrollView.contentOffsetX = targetOffsetX
                    return true
                }
                return false
            }
            
            /// 判断pages容器的滚动方向
            switch section.pagesItem.pagesScrollDirection {
            case .vertical:
                guard
                    let sectionScrollView = section.currentPageScrollView,
                    sectionScrollView.scrollDirection == .horizontal
                else {
                    scrollView.contentOffsetX = lastOffset.x
                    return
                }
                /// pages容器是竖直滚动，且当前page是水平滚动，则需要处理
                if !handleScrollPage(sectionScrollView) {
                    scrollView.contentOffsetX = lastOffset.x
                }
                return
            case .horizontal:
                guard let sectionScrollView = section.currentPageScrollView else {
                    guard let pagesBox = section.pagesItem.currentListView else {
                        scrollView.contentOffsetX = lastOffset.x
                        return
                    }
                    if !handleScrollPagesBox(pagesBox) {
                        scrollView.contentOffsetX = lastOffset.x
                    }
                    return
                }
                switch sectionScrollView.scrollDirection {
                case .vertical:
                    guard let pagesBox = section.pagesItem.currentListView else {
                        scrollView.contentOffsetX = lastOffset.x
                        return
                    }
                    /// 容器是水平滚动，且当前page是竖直滚动，则需要处理，让它可以滚动到上/下一个page
                    if !handleScrollPagesBox(pagesBox) {
                        scrollView.contentOffsetX = lastOffset.x
                    }
                    return
                case .horizontal:
                    /// pages容器是水平滚动，且当前page是水平滚动，则需要处理
                    if !handleScrollPage(sectionScrollView) {
                        guard let pagesBox = section.pagesItem.currentListView else {
                            scrollView.contentOffsetX = lastOffset.x
                            return
                        }
                        if !handleScrollPagesBox(pagesBox) {
                            scrollView.contentOffsetX = lastOffset.x
                        }
                    }
                    return
                @unknown default:
                    scrollView.contentOffsetX = lastOffset.x
                    return
                }
            default:
                scrollView.contentOffsetX = lastOffset.x
                return
            }
        }
        
        guard let section = scrollableSection else {
            return
        }
        let handleScrollPage = { (sectionScrollView: QuickSegmentScrollViewType) in
            if
                lastOffset.x < scrollView.contentOffset.x,
                contentOffsetX >= section.sectionStartPoint.x,
                sectionScrollView.contentOffset.x < (sectionScrollView.contentSize.width - sectionScrollView.bounds.width - sectionScrollView.adjustedContentInset.left - sectionScrollView.adjustedContentInset.right)
            {
                /// 左滑，目标section已完全展示，且当前可滚动的section还没滚动到底时，不能再滚动了
                let targetOffsetX = section.sectionStartPoint.x - scrollView.adjustedContentInset.left
                self.canRootScroll = false
                self.canPageScroll = false
                self.canPageScroll = true
                scrollView.contentOffsetX = targetOffsetX
                return true
            } else if
                lastOffset.x > scrollView.contentOffset.x,
                contentOffsetX <= section.sectionStartPoint.x,
                sectionScrollView.contentOffset.x > 0
            {
                /// 右滑，目标section已完全展示，且当前可滚动的section还没滚动到顶部时，不能再滚动了
                let targetOffsetX = section.sectionStartPoint.x - scrollView.adjustedContentInset.left
                self.canRootScroll = false
                self.canPagesBoxScroll = false
                self.canPageScroll = true
                scrollView.contentOffsetX = targetOffsetX
                return true
            }
            return false
        }
        
        let handleScrollPagesBox = { (pagesBox: QuickSegmentPagesListView) in
            if
                lastOffset.x < scrollView.contentOffset.x,
                contentOffsetX >= section.sectionStartPoint.x,
                pagesBox.contentOffset.x < (pagesBox.contentSize.width - pagesBox.bounds.width - pagesBox.adjustedContentInset.left - pagesBox.adjustedContentInset.right)
            {
                /// 左滑，目标section已完全展示，且当前可滚动的section还没滚动到底时，不能再滚动了
                let targetX = section.sectionStartPoint.x - scrollView.adjustedContentInset.left
                self.canRootScroll = false
                self.canPagesBoxScroll = true
                self.canPageScroll = false
                scrollView.contentOffsetX = targetX
                return
            }
            if
                lastOffset.x > scrollView.contentOffset.x,
                contentOffsetX <= section.sectionStartPoint.x,
                pagesBox.contentOffset.x > 0
            {
                /// 右滑，目标section已完全展示，且当前可滚动的section还没滚动到顶部时，不能再滚动了
                let targetOffsetX = section.sectionStartPoint.x - scrollView.adjustedContentInset.left
                self.canRootScroll = false
                self.canPagesBoxScroll = true
                self.canPageScroll = false
                scrollView.contentOffsetX = targetOffsetX
            }
        }
        
        /// 判断pages容器的滚动方向
        switch section.pagesItem.pagesScrollDirection {
        case .vertical:
            guard
                let sectionScrollView = section.currentPageScrollView,
                sectionScrollView.scrollDirection == .horizontal
            else {
                return
            }
            /// pages容器是竖直滚动，且当前page是水平滚动，则需要处理
            _ = handleScrollPage(sectionScrollView)
            return
        case .horizontal:
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
                /// 容器是水平滚动，且当前page是竖直滚动，则需要处理，让它可以滚动到上/下一个page
                handleScrollPagesBox(pagesBox)
                return
            case .horizontal:
                /// pages容器是水平滚动，且当前page是水平滚动，则需要处理
                if !handleScrollPage(sectionScrollView) {
                    handleScrollPagesBox(pagesBox)
                }
                return
            @unknown default:
                return
            }
        default:
            return
        }
    }
    
    /// 处理子列表的容器的滚动
    override func pagesBoxScrollViewDidScroll(_ scrollView: QuickSegmentPagesListView, at section: QuickSegmentSection, from lastOffset: CGPoint) {
        switch scrollView.scrollDirection {
        case .horizontal:
            var targetPageIndex = section.currentPageIndex
            /// 获取点击位置所在的page
            if scrollView.panGestureRecognizer.numberOfTouches == 1 {
                let point = scrollView.panGestureRecognizer.location(in: scrollView)
                let pageHeight = scrollView.bounds.width
                let index = Int(point.x / pageHeight)
                if index >= 0 && index < section.pageViewControllers.count {
                    targetPageIndex = index
                }
            }
            if (!canPagesBoxScroll && self.rootScrollView?.scrollDirection == currentScrollDirection) || scrollView.scrollDirection != currentScrollDirection {
                if !canPageScroll {
                    canRootScroll = true
                    canPagesBoxScroll = false
                }
                scrollView.contentOffsetX = CGFloat(targetPageIndex) * (scrollView.bounds.width - scrollView.adjustedContentInset.left - scrollView.adjustedContentInset.right)
                return
            }
            if self.rootScrollView?.scrollDirection != currentScrollDirection {
                if let pageScrollView = section.pageViewControllers[targetPageIndex].listScrollView(), pageScrollView.scrollDirection == .horizontal {
                    if
                        scrollView.contentOffset.x > lastOffset.x,
                        pageScrollView.contentOffset.x < (pageScrollView.contentSize.width - pageScrollView.bounds.width + pageScrollView.adjustedContentInset.right)
                    {
                        canPagesBoxScroll = false
                        canPageScroll = true
                        /// 当前子列表可以滚动
                        scrollView.contentOffsetX = CGFloat(targetPageIndex) * (scrollView.bounds.width - scrollView.adjustedContentInset.left - scrollView.adjustedContentInset.right)
                        return
                    }
                    if
                        scrollView.contentOffset.x < lastOffset.x,
                        pageScrollView.contentOffset.x > 0
                    {
                        canPagesBoxScroll = false
                        canPageScroll = true
                        /// 当前子列表可以滚动
                        scrollView.contentOffsetX = CGFloat(targetPageIndex) * (scrollView.bounds.width - scrollView.adjustedContentInset.left - scrollView.adjustedContentInset.right)
                        return
                    }
                }
            } else {
                if scrollView.contentOffset.x < 0 {
                    canPagesBoxScroll = false
                    canRootScroll = true
                    scrollView.contentOffsetX = 0
                    return
                }
                if scrollView.contentOffset.x > (scrollView.contentSize.width - scrollView.bounds.width + scrollView.adjustedContentInset.right) {
                    canPagesBoxScroll = false
                    canRootScroll = true
                    scrollView.contentOffsetX = scrollView.contentSize.width - scrollView.bounds.width + scrollView.adjustedContentInset.right
                    return
                }
            }
        case .vertical:
            var targetPageIndex = section.currentPageIndex
            /// 获取点击位置所在的page
            if scrollView.panGestureRecognizer.numberOfTouches == 1 {
                let point = scrollView.panGestureRecognizer.location(in: scrollView)
                let pageHeight = scrollView.bounds.height
                let index = Int(point.y / pageHeight)
                if index >= 0 && index < section.pageViewControllers.count {
                    targetPageIndex = index
                }
            }
            if (!canPagesBoxScroll && self.rootScrollView?.scrollDirection == currentScrollDirection) || scrollView.scrollDirection != currentScrollDirection {
                if !canPageScroll {
                    canRootScroll = true
                    canPagesBoxScroll = false
                }
                scrollView.contentOffsetY = CGFloat(targetPageIndex) * (scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom)
                return
            }
            if self.rootScrollView?.scrollDirection != currentScrollDirection {
                if let pageScrollView = section.pageViewControllers[targetPageIndex].listScrollView(), pageScrollView.scrollDirection == .vertical {
                    if
                        scrollView.contentOffset.y > lastOffset.y,
                        pageScrollView.contentOffset.y < (pageScrollView.contentSize.height - pageScrollView.bounds.height + pageScrollView.adjustedContentInset.bottom)
                    {
                        canPagesBoxScroll = false
                        canPageScroll = true
                        /// 当前子列表可以滚动
                        scrollView.contentOffsetY = CGFloat(targetPageIndex) * (scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom)
                        return
                    }
                    if
                        scrollView.contentOffset.y < lastOffset.y,
                        pageScrollView.contentOffset.y > 0
                    {
                        canPagesBoxScroll = false
                        canPageScroll = true
                        /// 当前子列表可以滚动
                        scrollView.contentOffsetY = CGFloat(targetPageIndex) * (scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom)
                        return
                    }
                }
            } else {
                if scrollView.contentOffset.y < 0 {
                    canPagesBoxScroll = false
                    canRootScroll = true
                    scrollView.contentOffsetY = 0
                    return
                }
                if scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.bounds.height + scrollView.adjustedContentInset.bottom) {
                    canPagesBoxScroll = false
                    canRootScroll = true
                    scrollView.contentOffsetY = scrollView.contentSize.height - scrollView.bounds.height + scrollView.adjustedContentInset.bottom
                    return
                }
            }
        @unknown default:
            return
        }
    }
    
    /// 处理子列表滚动
    override func scrollablePageScrollViewDidScroll(_ scrollView: QuickSegmentScrollViewType, from lastOffset: CGPoint) {
        guard scrollView.scrollDirection == currentScrollDirection else {
            /// 处于中间位置时，禁止滚动，超出去的部分允许bounds动画完成
            switch scrollView.scrollDirection {
            case .horizontal:
                if lastOffset.x < 0 || scrollView.contentOffset.x < 0 {
                    scrollView.contentOffsetX = 0
                } else {
                    let maxX = scrollView.contentSize.width - scrollView.bounds.width - scrollView.adjustedContentInset.left - scrollView.adjustedContentInset.right
                    if
                        lastOffset.x > maxX || scrollView.contentOffset.x > maxX
                    {
                        scrollView.contentOffsetX = maxX
                    } else {
                        scrollView.contentOffsetX = lastOffset.x
                    }
                }
            case .vertical:
                if lastOffset.y < 0 || scrollView.contentOffset.y < 0 {
                    scrollView.contentOffsetY = 0
                } else {
                    let maxY = scrollView.contentSize.height - scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom
                    if lastOffset.y > maxY || scrollView.contentOffset.y > maxY {
                        scrollView.contentOffsetY = maxY
                    } else {
                        scrollView.contentOffsetY = lastOffset.y
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
    
    func horizontalPageScrollViewDidScroll(_ scrollView: QuickSegmentScrollViewType, from lastOffset: CGPoint) {
        guard let rootScrollView = self.rootScrollView else {
            return
        }
        let rootContentOffsetX = rootScrollView.contentOffset.x + rootScrollView.adjustedContentInset.left
        
        let targetOffset = scrollView.contentOffset
        if !canPageScroll {
            if targetOffset.x <= 0 {
                scrollView.contentOffsetX = 0
            } else if targetOffset.x >= (scrollView.contentSize.width - scrollView.bounds.width - scrollView.adjustedContentInset.left - scrollView.adjustedContentInset.right) {
                scrollView.contentOffsetX = scrollView.contentSize.width - scrollView.bounds.width - scrollView.adjustedContentInset.left - scrollView.adjustedContentInset.right
            } else if
                lastOffset.x == 0,
                targetOffset.x > 0
            {
                if
                    let currentSection = self.scrollableSection,
                    rootContentOffsetX >= currentSection.sectionStartPoint.x
                {
                    canRootScroll = false
                } else {
                    scrollView.contentOffsetX = 0
                }
            } else if
                lastOffset.x == (scrollView.contentSize.width - scrollView.bounds.width - scrollView.adjustedContentInset.left - scrollView.adjustedContentInset.right),
                targetOffset.x < lastOffset.x
            {
                if
                    let currentSection = self.scrollableSection,
                    rootContentOffsetX <= currentSection.sectionStartPoint.x
                {
                    canRootScroll = false
                    canPageScroll = true
                } else {
                    scrollView.contentOffsetX = lastOffset.x
                }
            }
            return
        }
        if targetOffset.x <= 0, lastOffset.x > targetOffset.x {
            /// 右滑，目标值小于0时，不能再滚动了
            scrollView.contentOffsetX = 0
            canRootScroll = true
            canPageScroll = false
            return
        }
        if
            targetOffset.x >= (scrollView.contentSize.width - scrollView.bounds.width - scrollView.adjustedContentInset.left - scrollView.adjustedContentInset.right),
            lastOffset.x < targetOffset.x
        {
            /// 左滑，到底时，不能再滚动
            scrollView.contentOffsetX = scrollView.contentSize.width - scrollView.bounds.width - scrollView.adjustedContentInset.left - scrollView.adjustedContentInset.right
            canRootScroll = true
            canPageScroll = false
            return
        }
    }
    
    func verticalPageScrollViewDidScroll(_ scrollView: QuickSegmentScrollViewType, from lastOffset: CGPoint) {
        guard let rootScrollView = self.rootScrollView else {
            return
        }
        let rootContentOffsetX = rootScrollView.contentOffset.x + rootScrollView.adjustedContentInset.left
        
        let targetOffset = scrollView.contentOffset
        if !canPageScroll {
            if targetOffset.y <= 0 {
                scrollView.contentOffsetY = 0
                if
                    let currentSection = self.scrollableSection,
                    currentSection.pagesItem.currentListView?.scrollDirection == .vertical
                {
                    canPagesBoxScroll = true
                }
            } else if targetOffset.y >= (scrollView.contentSize.height - scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom) {
                scrollView.contentOffsetY = scrollView.contentSize.height - scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom
                if
                    let currentSection = self.scrollableSection,
                    currentSection.pagesItem.currentListView?.scrollDirection == .vertical
                {
                    canPagesBoxScroll = true
                }
            } else if
                lastOffset.y == 0,
                targetOffset.y > 0
            {
                if
                    let currentSection = self.scrollableSection,
                    rootContentOffsetX >= currentSection.sectionStartPoint.x
                {
                    canPagesBoxScroll = false
                    canPageScroll = true
                } else {
                    scrollView.contentOffsetY = 0
                }
            } else if
                lastOffset.y == (scrollView.contentSize.height - scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom),
                targetOffset.y < lastOffset.y
            {
                if
                    let currentSection = self.scrollableSection,
                    rootContentOffsetX <= currentSection.sectionStartPoint.x
                {
                    canPagesBoxScroll = false
                    canPageScroll = true
                } else {
                    scrollView.contentOffsetY = lastOffset.y
                }
            }
            return
        }
        if targetOffset.y <= 0, lastOffset.y > targetOffset.y {
            /// 下拉，目标值小于0时，不能再滚动了
            scrollView.contentOffsetY = 0
            canPagesBoxScroll = true
            canPageScroll = false
            return
        }
        if
            targetOffset.y >= (scrollView.contentSize.height - scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom),
            lastOffset.y < targetOffset.y
        {
            /// 上拉，到底时，不能再滚动
            scrollView.contentOffsetY = scrollView.contentSize.height - scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom
            canPagesBoxScroll = true
            canPageScroll = false
            return
        }
    }
}

