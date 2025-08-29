//
//  QuickSegmentScrollManager.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/8/27.
//

import Foundation

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
    var touchSection: QuickSegmentSection? {
        didSet {
            currentScrollDirection = nil
            resetStatus()
        }
    }
    /// 当前滚动方向
    var currentScrollDirection: UICollectionView.ScrollDirection?
    /// 所有的可滚动的Section
    var allScrollableSections: [QuickSegmentSection] = []
    /// 当前展示区域的可滚动的Section
    var visibleSections: [QuickSegmentSection] = []
    /// 当前可滚动的目标Section
    var scrollableSection: QuickSegmentSection?
    
    /// 总列表
    public weak var rootScrollView: QuickSegmentPageListView?
    /// 总表的滚动方向
    public var rootDirection: UICollectionView.ScrollDirection = .vertical
    
    /// 标记位
    var canRootScroll: Bool = true
    var canPagesBoxScroll: Bool = false
    var canPageScroll: Bool = false
    
    public static func create(
        rootScrollView: QuickSegmentPageListView? = nil,
        bouncesType: BouncesType = .root,
        rootDirection: UICollectionView.ScrollDirection = .vertical
    ) -> QuickSegmentScrollManager {
        switch bouncesType {
        case .root:
            switch rootDirection {
            case .vertical:
                return QuickSegmentVerticalRootScrollManager(rootScrollView: rootScrollView)
            case .horizontal:
                return QuickSegmentScrollManager(rootScrollView: rootScrollView)
            default:
                return QuickSegmentScrollManager(rootScrollView: rootScrollView)
            }
        case .pageWhenRootTop:
            switch rootDirection {
            case .vertical:
                return QuickSegmentVerticalRootScrollManager(rootScrollView: rootScrollView)
            case .horizontal:
                return QuickSegmentScrollManager(rootScrollView: rootScrollView)
            default:
                return QuickSegmentScrollManager(rootScrollView: rootScrollView)
            }
        case .pageWhenTouchInPage:
            switch rootDirection {
            case .vertical:
                return QuickSegmentVerticalRootScrollManager(rootScrollView: rootScrollView)
            case .horizontal:
                return QuickSegmentScrollManager(rootScrollView: rootScrollView)
            default:
                return QuickSegmentScrollManager(rootScrollView: rootScrollView)
            }
        }
    }
    
    private init() {
    }
    
    /// 初始化
    /// - Parameters:
    ///  - rootScrollView: 总列表
    internal init(
        rootScrollView: QuickSegmentPageListView? = nil
    ) {
        self.rootScrollView = rootScrollView
        rootScrollView?.handler.layout.add(self)
        rootScrollView?.observeScrollViewContentOffset(to: self)
    }
    
    
    /// 重置标志位状态
    private func resetStatus() {
        guard let rootScrollView = self.rootScrollView else { return }
        self.findScrollableView(to: rootScrollView, from: rootScrollView.contentOffset)
        resetStatus(for: rootScrollView)
    }
    
    func resetStatus(for rootScrollView: QuickSegmentPageListView) {
        assertionFailure("必须在子类中重写此方法")
    }
    
    /// 处理滚动事件
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
    }
    
    /// 查找目标滚动Section
    func findScrollableView(to rootView: QuickSegmentPageListView, from lastOffset: CGPoint) {
        assertionFailure("必须在子类中重写此方法")
    }
    
    /// 总列表滚动
    func rootScrollViewDidScroll(_ scrollView: QuickSegmentPageScrollViewType, from lastOffset: CGPoint) {
        assertionFailure("必须在子类中重写此方法")
    }
    
    /// 容器内页面更新
    func pageDidChanged(of section: QuickSegmentSection) {
        assertionFailure("必须在子类中重写此方法")
    }
    
    /// 当前可滚动的子列表滚动
    func scrollablePageScrollViewDidScroll(_ scrollView: QuickSegmentPageScrollViewType, from lastOffset: CGPoint) {
        assertionFailure("必须在子类中重写此方法")
    }
    
    /// 非当前可滚动的子列表滚动
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
    
    /// 子列表容器滚动
    func pagesBoxScrollViewDidScroll(_ scrollView: QuickSegmentPageListView, at section: QuickSegmentSection, from lastOffset: CGPoint) {
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
    
    deinit {
        rootScrollView?.removeObserveScrollViewContentOffset()
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
