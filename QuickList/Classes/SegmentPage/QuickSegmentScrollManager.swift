//
//  QuickSegmentScrollManager.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/8/27.
//

import Foundation

public protocol QuickSegmentPageScrollViewType: UIScrollView {
    var scrollOffsetObserve: NSKeyValueObservation? { get set }
    var scrollLastOffset: CGPoint { get set }
    var isQuickSegmentSubPage: Bool { get set }
    var scrollDirection: UICollectionView.ScrollDirection { get set }
    
    func observeScrollViewContentOffset(to manager: QuickSegmentScrollManager)
    func removeObserveScrollViewContentOffset()
    
    func setContentOffset(_ contentOffset: CGPoint, animated: Bool)
}

public class QuickSegmentPageScrollView: UIScrollView, QuickSegmentPageScrollViewType {
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

public class QuickSegmentPageListView: QuickListView, QuickSegmentPageScrollViewType {
    public var scrollOffsetObserve: NSKeyValueObservation?
    public var scrollLastOffset: CGPoint = .zero
    public var isQuickSegmentSubPage: Bool = false
    
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

extension QuickSegmentPageScrollView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if isQuickSegmentSubPage {
            return true
        }
        return false
    }
}

extension QuickSegmentPageListView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        /// 如果正在滚动的过程中，强行停止滚动
        if
            gestureRecognizer.state == .possible,
            self.isDecelerating
        {
            self.setContentOffset(self.scrollLastOffset, animated: false)
        }
        
        /// 获取点击的位置所在的section
        let touchPoint = gestureRecognizer.location(in: self)
        if !self.bounds.contains(touchPoint) {
            return false
        }
        if self.isQuickSegmentSubPage {
            return true
        }
        var touchSectionIndex: Int?
        for (i, attr) in self.handler.layout.sectionAttributes {
            switch self.scrollDirection {
            case .vertical:
                if attr.startPoint.y <= touchPoint.y, touchPoint.y <= attr.endPoint.y {
                    touchSectionIndex = i
                }
            case .horizontal:
                if attr.startPoint.x <= touchPoint.x, touchPoint.x <= attr.endPoint.x {
                    touchSectionIndex = i
                }
            @unknown default:
                return false
            }
            if touchSectionIndex != nil {
                break
            }
        }
        guard
            let sectionIndex = touchSectionIndex,
            sectionIndex < self.form.count,
            let section = self.form[sectionIndex] as? QuickSegmentSection,
            let scrollManager = section.scrollManager
        else {
            return false
        }
        if section.otherPageGestureRecognizers.contains(otherGestureRecognizer) {
            return false
        }
        if gestureRecognizer.state == .possible {
            scrollManager.touchSection = section
        }
        return true
    }
}

public class QuickSegmentScrollManager {
    /// 阻尼效果
    public enum BouncesType {
        /// 总列表
        case root
        /// 子列表（当总列表滚动到顶部/底部后，子列表可以继续滚动）
        case pageWhenRootTop
        /// 子列表（手势在子列表中触发时，始终是子列表进行滚动）
        case pageWhenTouchInPage
    }
    public var bouncesType: BouncesType = .root
    
    /// 当前触摸的Section
    fileprivate var touchSection: QuickSegmentSection? {
        didSet {
            currentScrollDirection = nil
            resetStatus()
        }
    }
    /// 当前滚动方向
    private var currentScrollDirection: UICollectionView.ScrollDirection?
    /// 所有的可滚动的Section
    private var allScrollableSections: [QuickSegmentSection] = []
    /// 当前展示区域的可滚动的Section
    private var visibleSections: [QuickSegmentSection] = []
    /// 当前可滚动的目标Section
    private var scrollableSection: QuickSegmentSection?
    
    /// 总列表
    public weak var rootScrollView: QuickSegmentPageListView?
    /// 总表的滚动方向
    public var rootDirection: UICollectionView.ScrollDirection = .vertical
    
    /// 标记位
    private var canRootScroll: Bool = true
    private var canPagesBoxScroll: Bool = false
    private var canPageScroll: Bool = false
    
    /// 重置标志位状态
    private func resetStatus() {
        guard let rootScrollView = self.rootScrollView else { return }
        let contentOffsetY = rootScrollView.contentOffset.y + rootScrollView.adjustedContentInset.top
        let contentOffsetX = rootScrollView.contentOffset.x + rootScrollView.adjustedContentInset.left
        
        self.findScrollableView(to: rootScrollView, from: rootScrollView.contentOffset)
        
        switch rootDirection {
        case .vertical:
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
        case .horizontal:
            guard let firstSection = visibleSections.first, let lastSection = visibleSections.last else {
                canRootScroll = true
                canPageScroll = false
                return
            }
            if contentOffsetX <= firstSection.sectionStartPoint.x || contentOffsetX + rootScrollView.bounds.width - rootScrollView.adjustedContentInset.right >= lastSection.sectionEndPoint.x {
                canRootScroll = true
                canPageScroll = false
            } else {
                canRootScroll = false
                canPageScroll = true
            }
        default:
            canRootScroll = true
            canPageScroll = false
        }
    }
    
    
    /// 初始化
    /// - Parameters:
    ///  - rootScrollView: 总列表
    ///  - bouncesType: 阻尼效果，默认总列表
    ///  - observeDirection: 监听的滚动方向，默认垂直方向
    public init(
        rootScrollView: QuickSegmentPageListView? = nil,
        bouncesType: BouncesType = .root,
        rootDirection: UICollectionView.ScrollDirection = .vertical
    ) {
        self.rootScrollView = rootScrollView
        rootScrollView?.handler.layout.add(self)
        self.bouncesType = bouncesType
        self.rootDirection = rootDirection
        rootScrollView?.observeScrollViewContentOffset(to: self)
    }
    
    deinit {
        rootScrollView?.removeObserveScrollViewContentOffset()
    }
    
    func scrollViewDidScroll(_ scrollView: QuickSegmentPageScrollViewType, from lastOffset: CGPoint) {
        if currentScrollDirection == nil {
            currentScrollDirection = abs(scrollView.contentOffset.x - lastOffset.x) > abs(scrollView.contentOffset.y - lastOffset.y) ? .horizontal : .vertical
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
        print("未知的scrollView滚动")
    }
    
    /// 查找目标滚动Section
    func findScrollableView(to rootView: QuickSegmentPageListView, from lastOffset: CGPoint) {
        let contentOffsetY = rootView.contentOffset.y + rootView.adjustedContentInset.top
        let contentOffsetX = rootView.contentOffset.x + rootView.adjustedContentInset.left
        
        let visibleRect = CGRect(
            x: rootView.contentOffset.x + rootView.adjustedContentInset.left,
            y: rootView.contentOffset.y + rootView.adjustedContentInset.top,
            width: rootView.bounds.width - rootView.adjustedContentInset.left - rootView.adjustedContentInset.right,
            height: rootView.bounds.height - rootView.adjustedContentInset.top - rootView.adjustedContentInset.bottom
        )
        
        visibleSections = []
        switch rootView.scrollDirection {
        case .vertical:
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
        case .horizontal:
            for i in 0 ..< rootView.handler.layout.sectionAttributes.count {
                guard let attr = rootView.handler.layout.sectionAttributes[i] else { continue }
                let sectionRect = CGRect(
                    x: attr.startPoint.x,
                    y: attr.startPoint.y,
                    width: attr.endPoint.x - attr.startPoint.x,
                    height: rootView.bounds.height
                )
                if
                    visibleRect.intersects(sectionRect),
                    let section = rootView.form[i] as? QuickSegmentSection
                {
                    visibleSections.append(section)
                }
            }
            
            self.scrollableSection = touchSection
        @unknown default:
            self.scrollableSection = nil
            return
        }
        
        if scrollableSection?.currentPageScrollView == nil {
            self.scrollableSection = nil
        }
    }
    
    func rootScrollViewDidScroll(_ scrollView: QuickSegmentPageScrollViewType, from lastOffset: CGPoint) {
        guard let rootScrollView = self.rootScrollView else { return }
        let contentOffsetY = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
        let contentOffsetX = scrollView.contentOffset.x + scrollView.adjustedContentInset.left
        let oldContentOffsetY = lastOffset.y + scrollView.adjustedContentInset.top
        let oldContentOffsetX = lastOffset.x + scrollView.adjustedContentInset.left
        
        findScrollableView(to: rootScrollView, from: lastOffset)
        if scrollableSection == nil {
            self.canRootScroll = true
            self.canPageScroll = false
        }
        
        switch bouncesType {
        case .root:
            switch rootDirection {
            case .vertical:
                if !canRootScroll || scrollView.scrollDirection != currentScrollDirection {
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
            case .horizontal:
                if !canRootScroll || scrollView.scrollDirection != currentScrollDirection {
                    scrollView.contentOffset.x = lastOffset.x
                } else if
                    let section = scrollableSection,
                    contentOffsetX >= section.sectionStartPoint.x,
                    lastOffset.x < scrollView.contentOffset.x
                {
                    /// 右滑，目标值大于等于pageStartOffset时，不能再滚动了
                    scrollView.contentOffset.x = section.sectionStartPoint.x - scrollView.adjustedContentInset.left
                    canRootScroll = false
                    canPageScroll = true
                }
            @unknown default:
                return
            }
        case .pageWhenRootTop:
            switch rootDirection {
            case .vertical:
                if !canRootScroll || scrollView.scrollDirection != currentScrollDirection {
                    scrollView.contentOffset.x = 0
                } else if scrollView.contentOffset.y <= 0, lastOffset.y > scrollView.contentOffset.y {
                    /// 下拉，目标值小于0时，不能再滚动了
                    scrollView.contentOffset.y = 0
                    canRootScroll = false
                }
            case .horizontal:
                if !canRootScroll || scrollView.scrollDirection != currentScrollDirection {
                    scrollView.contentOffset.x = 0
                } else if scrollView.contentOffset.x <= 0, lastOffset.x > scrollView.contentOffset.x {
                    /// 右滑，目标值小于0时，不能再滚动了
                    scrollView.contentOffset.x = 0
                    canRootScroll = false
                }
            @unknown default:
                return
            }
        case .pageWhenTouchInPage:
            return
        }
    }
    
    func pagesBoxScrollViewDidScroll(_ scrollView: QuickSegmentPageListView, at section: QuickSegmentSection, from lastOffset: CGPoint) {
//        guard let rootScrollView = self.rootScrollView, let currentSection = self.scrollableSection else { return }
//        let rootContentOffsetY = rootScrollView.contentOffset.y + rootScrollView.adjustedContentInset.top
//        let rootContentOffsetX = rootScrollView.contentOffset.x + rootScrollView.adjustedContentInset.left
        switch scrollView.scrollDirection {
        case .horizontal:
            if scrollView.scrollDirection != currentScrollDirection {
                scrollView.contentOffset.x = CGFloat(section.currentPageIndex) * (scrollView.bounds.width - scrollView.adjustedContentInset.left - scrollView.adjustedContentInset.right)
            }
        case .vertical:
            if scrollView.scrollDirection != currentScrollDirection {
                scrollView.contentOffset.y = CGFloat(section.currentPageIndex) * (scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom)
            }
        @unknown default:
            return
        }
    }
    
    /// 容器内页面更新
    func pageDidChanged(of section: QuickSegmentSection) {
        guard let rootScrollView = self.rootScrollView else { return }
        
        switch rootDirection {
        case .vertical:
            if
                let scrollableView = section.currentPageScrollView
            {
                scrollableView.contentOffset = .zero
                scrollableView.scrollLastOffset = .zero
                scrollableView.layoutIfNeeded()
            }
            if section.shouldScrollToTopWhenSelectedTab {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    rootScrollView.setContentOffset(CGPoint(x: rootScrollView.contentOffset.x, y: section.sectionStartPoint.y - rootScrollView.adjustedContentInset.top), animated: true)
                }
            }
        case .horizontal:
            if section.shouldScrollToTopWhenSelectedTab {
                rootScrollView.setContentOffset(CGPoint(x: section.sectionStartPoint.x - rootScrollView.adjustedContentInset.left, y: rootScrollView.contentOffset.y), animated: true)
            }
            if
                let scrollableView = section.currentPageScrollView
            {
                scrollableView.setContentOffset(.zero, animated: false)
            }
        @unknown default:
            return
        }
    }
    
    func unScrollablePageScrollViewDidScroll(_ scrollView: QuickSegmentPageScrollViewType, from lastOffset: CGPoint) {
        /// 当前子列表不允许滚动
        switch rootDirection {
        case .vertical:
            scrollView.contentOffset.y = lastOffset.y
        case .horizontal:
            scrollView.contentOffset.x = lastOffset.x
        @unknown default:
            break
        }
    }
    
    func scrollablePageScrollViewDidScroll(_ scrollView: QuickSegmentPageScrollViewType, from lastOffset: CGPoint) {
        guard let rootScrollView = self.rootScrollView else {
            return
        }
        let rootContentOffsetY = rootScrollView.contentOffset.y + rootScrollView.adjustedContentInset.top
        let rootContentOffsetX = rootScrollView.contentOffset.x + rootScrollView.adjustedContentInset.left
        
        let targetOffset = scrollView.contentOffset
        
        switch bouncesType {
        case .root:
            switch rootDirection {
            case .vertical:
                if !canPageScroll || scrollView.scrollDirection != currentScrollDirection {
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
                } else if targetOffset.y <= 0, lastOffset.y > targetOffset.y {
                    /// 下拉，目标值小于0时，不能再滚动了
                    scrollView.contentOffset.y = 0
                    canRootScroll = true
                    canPageScroll = false
                } else if
                    targetOffset.y >= (scrollView.contentSize.height - scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom),
                    lastOffset.y < targetOffset.y
                {
                    /// 上拉，到底时，不能再滚动
                    scrollView.contentOffset.y = scrollView.contentSize.height - scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom
                    canRootScroll = true
                    canPageScroll = false
                }
            case .horizontal:
                if !canPageScroll || scrollView.scrollDirection != currentScrollDirection {
                    scrollView.contentOffset.x = 0
                } else if
                    targetOffset.x <= 0,
                    lastOffset.x > targetOffset.x
                {
                    /// 左滑，目标值小于0时，不能再滚动了
                    scrollView.contentOffset.x = 0
                    canRootScroll = true
                    canPageScroll = false
                } else if
                    targetOffset.x >= (scrollView.contentSize.width - scrollView.bounds.width - scrollView.adjustedContentInset.left - scrollView.adjustedContentInset.right),
                    lastOffset.x < targetOffset.x
                {
                    /// 右滑，到底时，不能再滚动
                    scrollView.contentOffset.x = scrollView.contentSize.width - scrollView.bounds.width - scrollView.adjustedContentInset.left - scrollView.adjustedContentInset.right
                    canRootScroll = true
                    canPageScroll = false
                }
            @unknown default:
                return
            }
        case .pageWhenRootTop:
            switch rootDirection {
            case .vertical:
                if !canPageScroll || scrollView.scrollDirection != currentScrollDirection {
                    scrollView.contentOffset.y = 0
                } else if scrollView.contentOffset.y <= 0, lastOffset.y > scrollView.contentOffset.y, rootContentOffsetY <= 0 {
                    canRootScroll = false
                    canPageScroll = true
                } else if
                    scrollView.contentOffset.y <= 0,
                    lastOffset.y <= scrollView.contentOffset.y,
                    let currentSection = self.scrollableSection,
                    rootContentOffsetY <= currentSection.sectionStartPoint.y
                {
                    canRootScroll = true
                    canPageScroll = false
                    scrollView.contentOffset.y = 0
                } else if
                    scrollView.contentOffset.y >= 0,
                    lastOffset.y <= scrollView.contentOffset.y,
                    let currentSection = self.scrollableSection,
                    rootContentOffsetY >= currentSection.sectionStartPoint.y
                {
                    canRootScroll = false
                    canPageScroll = true
                }
            case .horizontal:
                if !canPageScroll || scrollView.scrollDirection != currentScrollDirection {
                    scrollView.contentOffset.x = 0
                } else if scrollView.contentOffset.x <= 0, lastOffset.x > scrollView.contentOffset.x, rootContentOffsetX <= 0 {
                    canRootScroll = false
                    canPageScroll = true
                } else if
                    scrollView.contentOffset.x <= 0,
                    lastOffset.x <= scrollView.contentOffset.x,
                    let currentSection = self.scrollableSection,
                    rootContentOffsetX <= currentSection.sectionStartPoint.x
                {
                    canRootScroll = true
                    canPageScroll = false
                    scrollView.contentOffset.x = 0
                } else if
                    scrollView.contentOffset.x >= 0,
                    lastOffset.x <= scrollView.contentOffset.x,
                    let currentSection = self.scrollableSection,
                    rootContentOffsetX >= currentSection.sectionStartPoint.x
                {
                    canRootScroll = false
                    canPageScroll = true
                }
            @unknown default:
                return
            }
        case .pageWhenTouchInPage:
            break
        }
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
