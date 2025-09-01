//
//  QuickSegmentSection.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/3/28.
//

import Foundation
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

public protocol QuickSegmentMenuConfig {
}

public struct QuickSegmentHorizontalMenuConfig: QuickSegmentMenuConfig {
    var menuHeight: CGFloat
    var menuItemSpace: CGFloat
    var menuListInsets: UIEdgeInsets
    var menuBackground: UIView?
    var menuBackgroundDecoration: UIView?
    var menuSelectedItemDecoration: UIView?
    
    public init(
        menuHeight: CGFloat = 44,
        menuItemSpace: CGFloat = 30,
        menuListInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20),
        menuBackground: UIView? = nil,
        menuBackgroundDecoration: UIView? = nil,
        menuSelectedItemDecoration: UIView? = nil
    ) {
        self.menuHeight = menuHeight
        self.menuItemSpace = menuItemSpace
        self.menuListInsets = menuListInsets
        self.menuBackground = menuBackground
        self.menuBackgroundDecoration = menuBackgroundDecoration
        self.menuSelectedItemDecoration = menuSelectedItemDecoration
    }
}

public struct QuickSegmentVerticalMenuConfig: QuickSegmentMenuConfig {
    var menuItemMinHeight: CGFloat
    var menuItemMaxWidth: CGFloat
    var menuItemLineSpace: CGFloat
    var menuListInsets: UIEdgeInsets
    var menuBackground: UIView?
    var menuBackgroundDecoration: UIView?
    var menuSelectedItemDecoration: UIView?
    
    public init(
        menuItemMinHeight: CGFloat = 44,
        menuItemMaxWidth: CGFloat = 200,
        menuItemLineSpace: CGFloat = 10,
        menuListInsets: UIEdgeInsets = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16),
        menuBackground: UIView? = nil,
        menuBackgroundDecoration: UIView? = nil,
        menuSelectedItemDecoration: UIView? = nil
    ) {
        self.menuItemMinHeight = menuItemMinHeight
        self.menuItemMaxWidth = menuItemMaxWidth
        self.menuItemLineSpace = menuItemLineSpace
        self.menuListInsets = menuListInsets
        self.menuBackground = menuBackground
        self.menuBackgroundDecoration = menuBackgroundDecoration
        self.menuSelectedItemDecoration = menuSelectedItemDecoration
    }
}

public class QuickSegmentSection: Section {
    /// 选择tab时是否置顶
    public var shouldScrollToTopWhenSelectedTab: Bool = true {
        didSet {
            self.pagesItem.shouldScrollToTopWhenPageDisappear = shouldScrollToTopWhenSelectedTab
        }
    }
    
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
    
    /// 菜单Item间距
    var menuItemSpace: CGFloat = 30
    
    /// 页面控制器列表
    var pageViewControllers: [QuickSegmentPageViewDelegate] = []
    
    /// 页面控制器容器高度(默认为nil，表示和父视图扣去菜单高度后的剩余区域等高)
    var pageContainerHeight: CGFloat?
    
    var scrollManager: QuickSegmentScrollManager?
    
    var currentPageIndex: Int = 0 {
        didSet {
            didSetCurrentPage()
        }
    }
    
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
        - menuConfig: 菜单配置
        - pageViewControllers: 页面控制器列表
        - pageContainerHeight: 页面控制器容器高度(默认为nil，表示和父视图扣去菜单高度后的剩余区域等高)
        - pageScrollEnable: 页面是否可以滚动切换，默认false
        - initializer: 初始化配置完成回调
     */
    public convenience init(
        menuConfig: QuickSegmentMenuConfig,
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
        
        switch scrollManager.rootDirection {
        case .vertical:
            if let horizontalMenuConfig = menuConfig as? QuickSegmentHorizontalMenuConfig {
                configHorizontalMenuHeader(menuConfig: horizontalMenuConfig)
            }
        case .horizontal:
            if let horizontalMenuConfig = menuConfig as? QuickSegmentHorizontalMenuConfig {
                configHorizontalMenuItem(menuConfig: horizontalMenuConfig, pageContainerHeight: pageContainerHeight)
            }
        @unknown default:
            assertionFailure("未处理的滚动方向")
        }
        
        self.pagesItem.scrollManager = scrollManager
        self.pagesItem.scrollEnable = pageScrollEnable
        self.append(self.pagesItem)
        
        initializer?(self)
    }
    
    private func configHorizontalMenuHeader(
        menuConfig: QuickSegmentHorizontalMenuConfig
    ) {
        self.pagesItem.menuType = .header
        self.pagesItem.pagesScrollDirection = .horizontal
        
        self.menuTabList.form.selectedItemDecoration = menuConfig.menuSelectedItemDecoration
        self.menuTabList.form.backgroundDecoration = menuConfig.menuBackgroundDecoration
        self.menuTabList.form.contentInset = menuConfig.menuListInsets
        self.header = SectionHeaderFooterView<UICollectionReusableView>({[weak self] view, section in
            guard let self = self else { return }
            if let menuBackground = menuConfig.menuBackground {
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
            menuConfig.menuHeight
        }
        self.menuItemSpace = menuConfig.menuItemSpace
        self.reloadMenu()
    }
    
    private func configHorizontalMenuItem(
        menuConfig: QuickSegmentHorizontalMenuConfig,
        pageContainerHeight: CGFloat?
    ) {
        self.layout = QuickYogaLayout(alignment: .flexStart, lineAlignment: .flexStart)
        
        self.pagesItem.menuType = .item
        self.pagesItem.pagesScrollDirection = .horizontal
        
        self.menuTabList.form.selectedItemDecoration = menuConfig.menuSelectedItemDecoration
        self.menuTabList.form.backgroundDecoration = menuConfig.menuBackgroundDecoration
        self.menuTabList.form.contentInset = menuConfig.menuListInsets
        
        let menuItem = QuickSegmentHorizontalMenuItem(
            identifier: "MenuItem_\(self.index ?? 0)",
            pageContainerHeight: pageContainerHeight,
            config: menuConfig,
            menuTabList: self.menuTabList
        )
        self.menuItemSpace = menuConfig.menuItemSpace
        self.reloadMenu()
        
        self.append(menuItem)
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
                self.scrollManager?.pageDidChanged(in: self)
            }
            section.append(pageVC.pageTabItem)
        }
        self.menuTabList.form.removeAll()
        self.menuTabList.form.append(section)
        self.menuTabList.reload()
    }
    
    func didSetCurrentPage() {
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
        if floorIndex == ceilIndex, floorIndex != currentPageIndex {
            self.currentPageIndex = floorIndex
            self.scrollManager?.pageDidChanged(in: self)
        }
    }
}

extension QuickSegmentSection: QuickListCollectionLayoutDelegate {
    public func collectionLayoutDidFinishLayout(_ layout: QuickListCollectionLayout) {
        didSetCurrentPage()
        guard let index = self.index else { return }
        self.sectionStartPoint = layout.sectionAttributes[index]?.startPoint ?? .zero
        self.sectionEndPoint = layout.sectionAttributes[index]?.endPoint ?? .zero
    }
}
