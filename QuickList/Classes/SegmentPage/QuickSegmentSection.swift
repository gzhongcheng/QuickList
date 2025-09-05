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
    public enum MenuWidthType {
        case fixed(width: CGFloat)
        case auto(maxWidth: CGFloat)
    }
    
    var menuWidthType: MenuWidthType
    var menuItemLineSpace: CGFloat
    var menuListInsets: UIEdgeInsets
    var menuBackground: UIView?
    var menuBackgroundDecoration: UIView?
    var menuSelectedItemDecoration: UIView?
    
    public init(
        menuWidthType: MenuWidthType = .fixed(width: 200),
        menuItemLineSpace: CGFloat = 10,
        menuListInsets: UIEdgeInsets = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16),
        menuBackground: UIView? = nil,
        menuBackgroundDecoration: UIView? = nil,
        menuSelectedItemDecoration: UIView? = nil
    ) {
        self.menuWidthType = menuWidthType
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
        _ initializer: ((QuickSegmentSection) -> Void)? = nil
    ) {
        self.init()
        
        self.pageViewControllers = pageViewControllers
        self.pageContainerHeight = pageContainerHeight
        self.scrollManager = scrollManager
        
        switch scrollManager.rootDirection {
        case .vertical:
            if let horizontalMenuConfig = menuConfig as? QuickSegmentHorizontalMenuConfig {
                configHorizontalMenuHeader(menuConfig: horizontalMenuConfig)
            } else if let verticalMenuConfig = menuConfig as? QuickSegmentVerticalMenuConfig {
                configVerticalMenuItem(menuConfig: verticalMenuConfig, pageContainerHeight: pageContainerHeight)
            }
        case .horizontal:
            if let horizontalMenuConfig = menuConfig as? QuickSegmentHorizontalMenuConfig {
                configHorizontalMenuItem(menuConfig: horizontalMenuConfig, pageContainerHeight: pageContainerHeight)
            } else if let verticalMenuConfig = menuConfig as? QuickSegmentVerticalMenuConfig {
                configVerticalMenuHeader(menuConfig: verticalMenuConfig)
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
        self.pagesItem.menuHeight = menuConfig.menuHeight
        
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
        self.reloadMenu(itemSpace: menuConfig.menuItemSpace)
    }
    
    private func configVerticalMenuHeader(
        menuConfig: QuickSegmentVerticalMenuConfig
    ) {
        self.pagesItem.menuType = .header
        self.pagesItem.pagesScrollDirection = .vertical
        
        self.menuTabList.scrollDirection = .vertical
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
        
        var menuWidth: CGFloat?
        if let width = self.reloadMenu(itemSpace: menuConfig.menuItemLineSpace) {
            menuWidth = width + menuConfig.menuListInsets.left + menuConfig.menuListInsets.right
        }
        
        switch menuConfig.menuWidthType {
        case .fixed(let width):
            self.header?.height = { _, _, _ in
                width
            }
            self.pagesItem.menuHeight = width
        case .auto(let maxWidth):
            let headerWidth = Swift.min(menuWidth ?? 0, maxWidth)
            self.header?.height = { _, _, _ in
                headerWidth
            }
            self.pagesItem.menuHeight = headerWidth
        }
    }

    
    private func configHorizontalMenuItem(
        menuConfig: QuickSegmentHorizontalMenuConfig,
        pageContainerHeight: CGFloat?
    ) {
        self.layout = QuickYogaLayout(alignment: .flexStart, lineAlignment: .flexStart)
        
        self.pagesItem.menuType = .item
        self.pagesItem.pagesScrollDirection = .horizontal
        self.pagesItem.menuHeight = menuConfig.menuHeight
        
        self.menuTabList.form.selectedItemDecoration = menuConfig.menuSelectedItemDecoration
        self.menuTabList.form.backgroundDecoration = menuConfig.menuBackgroundDecoration
        self.menuTabList.form.contentInset = menuConfig.menuListInsets
        
        let menuItem = QuickSegmentHorizontalMenuItem(
            identifier: "MenuItem_\(self.index ?? 0)",
            pageContainerHeight: pageContainerHeight,
            config: menuConfig,
            menuTabList: self.menuTabList
        )
        self.reloadMenu(itemSpace: menuConfig.menuItemSpace)
        
        self.append(menuItem)
    }
    
    private func configVerticalMenuItem(
        menuConfig: QuickSegmentVerticalMenuConfig,
        pageContainerHeight: CGFloat?
    ) {
        self.layout = QuickYogaLayout(alignment: .flexStart, lineAlignment: .flexStart)
        
        self.pagesItem.menuType = .item
        self.pagesItem.pagesScrollDirection = .vertical
        
        self.menuTabList.scrollDirection = .vertical
        self.menuTabList.form.selectedItemDecoration = menuConfig.menuSelectedItemDecoration
        self.menuTabList.form.backgroundDecoration = menuConfig.menuBackgroundDecoration
        self.menuTabList.form.contentInset = menuConfig.menuListInsets

        let menuItem = QuickSegmentVerticalMenuItem(
            identifier: "MenuItem_\(self.index ?? 0)",
            pageContainerHeight: pageContainerHeight,
            config: menuConfig,
            menuTabList: self.menuTabList
        )
        var menuWidth: CGFloat?
        if let width = self.reloadMenu(itemSpace: menuConfig.menuItemLineSpace) {
            let totalWidth = width + menuConfig.menuListInsets.left + menuConfig.menuListInsets.right
            menuItem.maxItemWidth = totalWidth
            menuWidth = totalWidth
        }
        switch menuConfig.menuWidthType {
        case .fixed(let width):
            self.pagesItem.menuHeight = width
        case .auto(let maxWidth):
            let headerWidth = Swift.min(menuWidth ?? 0, maxWidth)
            self.pagesItem.menuHeight = headerWidth
        }
        
        self.append(menuItem)
    }
    
    /// 菜单列表Tab
    public let menuTabList: QuickListView = {
        let listView = QuickListView()
        listView.scrollDirection = .horizontal
        listView.form.singleSelection = true
        return listView
    }()
    
    
    internal weak var currentPageScrollView: QuickSegmentScrollViewType?
    
    /// 页面item
    public lazy var pagesItem: QuickSegmentPagesItem = {
        let item = QuickSegmentPagesItem(pageViewControllers: self.pageViewControllers, pageContainerHeight: self.pageContainerHeight)
        item.delegate = self
        return item
    }()
    
    @discardableResult
    func reloadMenu(itemSpace: CGFloat) -> CGFloat? {
        let section = Section { section in
            section.lineSpace = itemSpace
        }
        var maxItemWidth: CGFloat = 0
        for (index, pageVC) in self.pageViewControllers.enumerated() {
            pageVC.listScrollView()?.isQuickSegmentSubPage = true
            if let manager = self.scrollManager {
                pageVC.listScrollView()?.scrollManager = manager
            }
            pageVC.pageTabItem.isSelected = index == 0
            pageVC.pageTabItem.callbackCellOnSelection = { [weak self] in
                guard let self = self else { return }
                self.pagesItem.scrollToPage(index: index, animated: true)
                self.currentPageIndex = index
                self.scrollManager?.pageDidChanged(in: self, fromMenu: true)
            }
            if let itemSize = pageVC.pageTabItem.representableItem()?.sizeForItem(pageVC.pageTabItem, with: CGSize(width: 1000, height: 40), in: self.menuTabList, layoutType: .horizontal) {
                maxItemWidth = Swift.max(maxItemWidth, itemSize.width)
            }
            section.append(pageVC.pageTabItem)
        }
        self.menuTabList.form.removeAll()
        self.menuTabList.form.append(section)
        self.menuTabList.reload()
        return maxItemWidth > 0 ? maxItemWidth : nil
    }
    
    func didSetCurrentPage() {
        self.currentPageScrollView = self.pageViewControllers[self.currentPageIndex].listScrollView()
    }
}

extension QuickSegmentSection: QuickSegmentPagesItemDelegate {
    public func segmentPagesItem(_ item: QuickSegmentPagesItem, didScrollTo index: CGFloat) {
        self.menuTabList.handler.updateSelectedItemDecorationTo(position: index)
        
        let floorIndex: Int = Int(floor(index))
        let ceilIndex: Int = Int(ceil(index))
        if floorIndex == ceilIndex, floorIndex != currentPageIndex {
            self.currentPageIndex = floorIndex
            self.scrollManager?.pageDidChanged(in: self, fromMenu: false)
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
