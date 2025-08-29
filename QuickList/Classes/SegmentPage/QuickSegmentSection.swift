//
//  QuickSegmentSection.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/3/28.
//

import UIKit
import SnapKit

public protocol QuickSegmentTabProtocol {
    var scrollDirection: UICollectionView.ScrollDirection { get set }
    var menuHeight: CGFloat { get set }
    var menuListInsets: UIEdgeInsets { get set }
    var menuItemSpace: CGFloat { get set }
    
    func reloadMenu(to pageViewControllers: [QuickSegmentPageViewDelegate])
    /// 更新选中状态到指定位置
    func updateSelectedDecorationTo(position: CGFloat)
}

public class QuickSegmentSection: Section {
    /// 选择tab时是否置顶
    public var shouldScrollToTopWhenSelectedTab: Bool = true
    
    /// 页面是否可以滚动切换，默认false
    public var pageScrollEnable: Bool {
        set {
            self.pagesItem.scrollEnable = newValue
        }
        get {
            return self.pagesItem.scrollEnable
        }
    }
    
    /// 菜单高度
    var menuHeight: CGFloat = 44 {
        didSet {
            self.header?.height = { [weak self] _, _, _ in
                return self?.menuHeight ?? 44
            }
        }
    }
    /// 菜单列表的边距
    var menuListInsets: UIEdgeInsets = .zero {
        didSet {
            self.menuTabList.form.contentInset = menuListInsets
        }
    }
    /// 菜单Item间距
    var menuItemSpace: CGFloat = 30
    
    /// 页面控制器列表
    var pageViewControllers: [QuickSegmentPageViewDelegate] = []
    
    /// 页面控制器容器高度(默认为nil，表示和父视图扣去菜单高度后的剩余区域等高)
    var pageContainerHeight: CGFloat?
    
    var scrollManager: QuickSegmentScrollManager?
    
    var currentPageIndex: Int = 0
    
    var sectionStartPoint: CGPoint = .zero
    var sectionEndPoint: CGPoint = .zero
    
    public override var form: Form? {
        didSet {
            self.form?.delegate?.formView?.handler.layout.add(self)
        }
    }
    
    /**
    初始化一个分段页面Section
     - Parameters:
        - menuHeight: 菜单高度，默认44
        - menuBackground: 菜单背景视图，默认为nil
        - menuItemSpace: 菜单Item间距，默认30
        - menuListInsets: 菜单列表的边距，默认UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        - menuBackgroundDecoration: 菜单背景装饰视图，默认nil
        - menuSelectedItemDecoration: 菜单选中Item装饰视图，默认nil
        - pageViewControllers: 页面控制器列表
        - pageContainerHeight: 页面控制器容器高度(默认为nil，表示和父视图扣去菜单高度后的剩余区域等高)
        - pageScrollEnable: 页面是否可以滚动切换，默认false
        - initializer: 初始化配置完成回调
     */
    public convenience init(
        menuHeight: CGFloat = 44,
        menuBackground: UIView? = nil,
        menuItemSpace: CGFloat = 30,
        menuListInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20),
        menuBackgroundDecoration: UIView? = nil,
        menuSelectedItemDecoration: UIView? = nil,
        pageViewControllers: [QuickSegmentPageViewDelegate],
        pageContainerHeight: CGFloat? = nil,
        pageScrollEnable: Bool = true,
        scrollManager: QuickSegmentScrollManager,
        _ initializer: ((Section) -> Void)? = nil
    ) {
        self.init()
        
        self.pageViewControllers = pageViewControllers
        self.pageContainerHeight = pageContainerHeight
        self.scrollManager = scrollManager
        
        self.menuTabList.form.selectedItemDecoration = menuSelectedItemDecoration
        self.menuTabList.form.backgroundDecoration = menuBackgroundDecoration
        self.menuTabList.form.contentInset = menuListInsets
        self.header = SectionHeaderFooterView<UICollectionReusableView>({[weak self] view, section in
            guard let self = self else { return }
            if let menuBackground = menuBackground {
                view.addSubview(menuBackground)
                menuBackground.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
            view.addSubview(self.menuTabList)
            self.menuTabList.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        })
        self.header?.shouldSuspension = true
        self.header?.height = { _, _, _ in
            menuHeight
        }
        self.menuItemSpace = menuItemSpace
        self.reloadMenu()
        
        self.pagesItem.scrollManager = scrollManager
        self.pagesItem.scrollEnable = pageScrollEnable
        self.append(self.pagesItem)
        
        initializer?(self)
    }
    
    /// 菜单列表Tab
    public let menuTabList: QuickListView = {
        let listView = QuickListView()
        listView.scrollDirection = .horizontal
        listView.form.singleSelection = true
        return listView
    }()
    
    
    internal weak var currentPageScrollView: QuickSegmentPageScrollViewType?
    internal var otherPageGestureRecognizers: [UIGestureRecognizer] = []
    /// 页面item
    public lazy var pagesItem: QuickSegmentPagesItem = {
        let item = QuickSegmentPagesItem(pageViewControllers: self.pageViewControllers, menuHeight: self.menuHeight, pageContainerHeight: self.pageContainerHeight)
        item.delegate = self
        return item
    }()
    
    func reloadMenu() {
        let section = Section { section in
            section.lineSpace = self.menuItemSpace
        }
        for (index, pageVC) in self.pageViewControllers.enumerated() {
            pageVC.listScrollView()?.isQuickSegmentSubPage = true
            pageVC.pageTabItem.isSelected = index == 0
            pageVC.pageTabItem.callbackCellOnSelection = { [weak self] in
                guard let self = self else { return }
                self.pagesItem.scrollToPage(index: index, animated: true)
                self.currentPageIndex = index
                /// 切换监听的scrollView
                /// 如果当前的scrollView正在滚动，先停止滚动
                self.currentPageScrollView?.setContentOffset(self.currentPageScrollView?.contentOffset ?? .zero, animated: false)
                self.currentPageScrollView?.removeObserveScrollViewContentOffset()
                self.currentPageScrollView = self.pageViewControllers[self.currentPageIndex].listScrollView()
                self.scrollManager?.pageDidChanged(of: self)
                if let gestureRecognizersInPageScrollView = self.currentPageScrollView?.gestureRecognizers {
                    otherPageGestureRecognizers = gestureRecognizersInPageScrollView
                }
                guard let scrollManager = self.scrollManager else { return }
                self.currentPageScrollView?.observeScrollViewContentOffset(to: scrollManager)
            }
            section.append(pageVC.pageTabItem)
        }
        self.menuTabList.form.removeAll()
        self.menuTabList.form.append(section)
        self.menuTabList.reload()
    }
    
    func setCurrentPage() {
        self.currentPageScrollView?.removeObserveScrollViewContentOffset()
        self.currentPageScrollView = self.pageViewControllers[self.currentPageIndex].listScrollView()
        if let gestureRecognizersInPageScrollView = self.currentPageScrollView?.gestureRecognizers {
            otherPageGestureRecognizers = gestureRecognizersInPageScrollView
        }
        guard let scrollManager = self.scrollManager else { return }
        self.currentPageScrollView?.observeScrollViewContentOffset(to: scrollManager)
    }
    
    deinit {
        self.currentPageScrollView?.removeObserveScrollViewContentOffset()
    }
}

extension QuickSegmentSection: QuickSegmentPagesItemDelegate {
    public func segmentPagesItem(_ item: QuickSegmentPagesItem, didScrollTo index: CGFloat) {
        self.menuTabList.handler.updateSelectedItemDecorationTo(position: index)
        
        let floorIndex: Int = Int(floor(index))
        let ceilIndex: Int = Int(ceil(index))
        if floorIndex == ceilIndex {
            self.currentPageIndex = floorIndex
            /// 完全滑动到某个位置， 切换监听的scrollView
            self.setCurrentPage()
        }
    }
}

extension QuickSegmentSection: QuickListCollectionLayoutDelegate {
    public func collectionLayoutDidFinishLayout(_ layout: QuickListCollectionLayout) {
        setCurrentPage()
        guard let index = self.index else { return }
        self.sectionStartPoint = layout.sectionAttributes[index]?.startPoint ?? .zero
        self.sectionEndPoint = layout.sectionAttributes[index]?.endPoint ?? .zero
    }
}
